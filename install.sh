#!/usr/bin/env bash
# bash-it installer

source "$BASH_IT/lib/colors.bash"

echo "\n[INFO] ${YELLOW}Getting bash version .... ${NC}\n"
bash --version
# Show how to use this installer
function show_usage() {
  echo "${RED}bash-it Help${NC}"
  echo "${YELLOW}Description: Install bash-it framework\n${NC}"
  echo "Arguments:"
  echo "\t --help (-h): Display this help message"
  echo "\t --silent (-s): Install default settings without prompting for input";
  echo "\t --interactive (-i): Interactively choose plugins"
  echo "\t --no-modify-config (-n): Do not modify existing config file"
}

# enable a thing
function load_one() {
  file_type=$1
  file_to_enable=$2
  mkdir -p "$BASH_IT/${file_type}/enabled"

  dest="${BASH_IT}/${file_type}/enabled/${file_to_enable}"
  if [ ! -e "${dest}" ]; then
    ln -sf "../available/${file_to_enable}" "${dest}"
  else
    echo "File ${dest} exists, skipping"
  fi
}

# Interactively enable several things
function load_some() {
  file_type=$173
  single_type=$(echo "$file_type" | sed -e "s/aliases$/alias/g" | sed -e "s/plugins$/plugin/g")
  enable_func="_enable-$single_type"
  [ -d "$BASH_IT/$file_type/enabled" ] || mkdir "$BASH_IT/$file_type/enabled"
  for path in "$BASH_IT/${file_type}/available/"[^_]*
  do
    file_name=$(basename "$path")
    while true
    do
      just_the_name="${file_name%%.*}"
      read -e -n 1 -p "Would you like to enable the $just_the_name $file_type? [y/N] " RESP
      case $RESP in
      [yY])
        $enable_func $just_the_name
        break
        ;;
      [nN]|"")
        break
        ;;
      *)
        echo "${MAGENTA}Please choose y or n.${NC}"
        ;;
      esac
    done
  done
}

# Back up existing profile and create new one for bash-it
function backup_new() {
  test -w "$HOME/$CONFIG_FILE" &&
  cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
  echo "${WHITE}Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak${NC}"
  sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
  echo "${WHITE}Copied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it${NC}"
}

for param in "$@"; do
  shift
  case "$param" in
    "--help")               set -- "$@" "-h" ;;
    "--silent")             set -- "$@" "-s" ;;
    "--interactive")        set -- "$@" "-i" ;;
    "--no-modify-config")   set -- "$@" "-n" ;;
    *)                      set -- "$@" "$param"
  esac
done

OPTIND=1
while getopts "hsin" opt
do
  case "$opt" in
  "h") show_usage; exit 0 ;;
  "s") silent=true ;;
  "i") interactive=true ;;
  "n") no_modify_config=true ;;
  "?") show_usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1)

if [[ $silent ]] && [[ $interactive ]]; then
  echo "${RED}Options --silent and --interactive are mutually exclusive. Please choose one or the other.${NC}"
  exit 1;
fi

[ -z "$BASH_IT" ] && BASH_IT="$(cd "$(dirname "$0")" && pwd)"

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

BACKUP_FILE=$CONFIG_FILE.bak
printf "

██████╗  █████╗ ███████╗██╗  ██╗      ██╗████████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║      ██║╚══██╔══╝
██████╔╝███████║███████╗███████║█████╗██║   ██║   
██╔══██╗██╔══██║╚════██║██╔══██║╚════╝██║   ██║   
██████╔╝██║  ██║███████║██║  ██║      ██║   ██║   
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝      ╚═╝   ╚═╝   
                                                  
${CYAN}Installing bash-it ..${NC}
\n
"
if ! [[ $silent ]] && ! [[ $no_modify_config ]]; then
  if [ -e "$HOME/$BACKUP_FILE" ]; then
    echo "${YELLOW}Backup file already exists. Make sure to backup your .bashrc before running this installation.${NC}" >&2
    while ! [ $silent ];  do
      echo "Would you like to overwrite the existing backup?"
      read -e -n 1 -r -p "This will delete your existing backup file ($HOME/$BACKUP_FILE) [y/N] " RESP
      case $RESP in
      [yY])
        break
        ;;
      [nN]|"")
        echo "${RED}Installation aborted. Please come back soon!${NC}"
        exit 1
        ;;
      *)
        echo "${MAGENTA}Please choose y or n.${NC}"
        ;;
      esac
    done
  fi

  while ! [ $silent ]; do
    echo ""
    read -e -n 1 -r -p "Would you like to keep your $CONFIG_FILE and append bash-it templates at the end? [y/N] " choice
    case $choice in
    [yY])
      test -w "$HOME/$CONFIG_FILE" &&
      cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
      echo "${WHITE}Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak${NC}"

      (sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
      echo "${WHITE}Bash-it template has been added to your $CONFIG_FILE${NC}"
      break
      ;;
    [nN]|"")
      backup_new
      break
      ;;
    *)
      echo "${MAGENTA}Please choose y or n.${NC}"
      ;;
    esac
  done
elif [[ $silent ]] && ! [[ $no_modify_config ]]; then
  # backup/new by default
  backup_new
fi

# Load dependencies for enabling components
source "$BASH_IT/lib/composure.bash"
cite _about _param _example _group _author _version
source "$BASH_IT/lib/helpers.bash"

if [[ $interactive ]] && ! [[ $silent ]] ;
then
  for type in "aliases" "plugins" "completion"
  do
    echo "${GREEN}Enabling $type${NC}"
    load_some $type
  done
else
  echo ""
  echo "${YELLOW}Enabling reasonable defaults${NC}"
  _enable-completion bash-it
  _enable-completion system
  _enable-plugin base
  _enable-plugin alias-completion
  _enable-alias general
fi

echo ""
echo "${CYAN}Installation finished successfully! Enjoy bash-it!${NC}"
echo "${CYAN}To start using it, open a new tab or 'source "$HOME/$CONFIG_FILE"'.${NC}"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  bash-it show aliases"
echo "  bash-it show completions"
echo "  bash-it show plugins"
echo ""
echo "To avoid issues and to keep your shell clean, please enable only features you really want to use."
echo "Enabling everything can lead to issues."
