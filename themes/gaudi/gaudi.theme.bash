#!/usr/bin/env bash

GAUDI_ROOT="${HOME}/.bash_it/themes/gaudi"
GAUDI_FIRST_RUN=true

source "$GAUDI_ROOT/gaudi.configs.bash"
source "$GAUDI_ROOT/lib/utils.bash"
source "$GAUDI_ROOT/lib/colors.bash"
source "$GAUDI_ROOT/lib/scm.bash"
source "$GAUDI_ROOT/lib/hooks.bash"

# Do not load if not an interactive shell
# Reference: https://github.com/nojhan/liquidprompt/issues/161
test -z "$TERM" -o "x$TERM" = xdumb && return

# Check for recent enough version of bash.
if test -n "${BASH_VERSION-}" -a -n "$PS1" ; then
  bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
  if (( bmajor < 4 || ( bmajor == 4 && bminor < 0 ) )); then
    echo "The current bash version ${bash} is not supported by Gaudi [ 4.0+ ]"
    unset bash bmajor bminor
    return
  fi
fi

gaudi::prompt() {

  # Must be captured before any other command in prompt is executed
  # Must be the very first line in all entry prompt functions, or the value
  # will be overridden by a different command execution - do not move this line!
  RETVAL=$?
  
  # Terminal runs something like login -pfl your-username /bin/bash -c exec -la bash <bash path> 
  # when you create a new shell which lacks the -q flag. The problem is that when opening a new tab 
  # with "Same Working Directory" enabled, the current directory is searched for .hushlogin. 
  # Unless you put a .hushlogin in every single directory, it will only see ~/.hushlogin if you open a new tab when you're in ~.
  # This is in direct conflict with the feature of preserving the current working directory
  # This checks if we are using the MacOSX Terminal app and clear the screen before that
  if [[ $TERM_PROGRAM == "Apple_Terminal" ]]  && [[ $GAUDI_FIRST_RUN == true ]] && [[ $GAUDI_ENABLE_HUSHLOGIN == true ]]; then
    # Clears and reset the lines printed in the terminal
    printf '\033\143'
    unset GAUDI_FIRST_RUN
  fi

  # Check and kill any irreelvant background jobs
  # Outdated background jobs are any gaudi::async_render executed on folders
  # other than the current working directory $PWD
  gaudi::kill_outdated_asyncRender  

  # Source the prompt char configuration
  source "$GAUDI_ROOT/segments/char.bash"
  
  local PROMPT_CHAR="$(gaudi_char)"
  local COMPENSATE=53

  local LEFT_PROMPT="$(gaudi::render_prompt GAUDI_PROMPT_LEFT[@])"
  local RIGHT_PROMPT="$(gaudi::render_prompt GAUDI_PROMPT_RIGHT[@])"
  
  # Check if we need to activate the two side theme split (LEFT_PROMPT ------ RIGHT RIGHT)
  # Or we need to have the whole prompt in one line where (RIGHT_PROMPT LEFT_PROMPT)
  if [[ $GAUDI_SPLIT_PROMPT == false ]]; then
    PS1=$(printf "\n%b%b\n\n%b" "$RIGHT_PROMPT" "$LEFT_PROMPT" "$PROMPT_CHAR")
  else
    if [[ "$TERM" =~ "screen".* ]]; then
      tmux set-option -g default-command bash
      COMPENSATE=45
    fi
    [[ $GAUDI_SPLIT_PROMPT_TWO_LINES == true ]] && line_separator="\n" || line_separator="\r"
    PS1=$(printf "\n%*b%s%b\n\n%b" "$(($(tput cols) + $COMPENSATE))" "$RIGHT_PROMPT" "$line_separator" "$LEFT_PROMPT" "$PROMPT_CHAR")
  fi;

  # Render the async part of the prompt .. lazy lazy
  gaudi::render_async() {
    
    local ASYNC_PROMPT="$(gaudi::render_prompt GAUDI_PROMPT_ASYNC[@])"
    
    tput sc && tput cuu1 && tput cuu1 
    if [[ $GAUDI_SPLIT_PROMPT == false ]]; then 
      echo -e -n "\r$RIGHT_PROMPT$LEFT_PROMPT$ASYNC_PROMPT"
    else
      echo -e -n "\r$LEFT_PROMPT$ASYNC_PROMPT"
    fi;
    tput rc
  }

  # Load the PS2 continuation bash configuration
  source "$GAUDI_ROOT/segments/continuation.bash"
  # PS2 – Continuation interactive prompt
  PS2=$(gaudi_continuation)
  
  # The PS4 defined below in the ps4.sh has the following two codes:
  #   $0 – indicates the name of script
  #   $LINENO – displays the current line number within the script
  PS4='$0.$LINENO+ '
  
  # Check the async side of the prompt if available
  set +m
  gaudi::render_async &

  ## cleanup
  unset LEFT_PROMPT RIGHT_PROMPT ASYNC_PROMPT
}

gaudi::safe_append_prompt_command gaudi::prompt
