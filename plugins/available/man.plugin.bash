cite about-plugin
about-plugin 'Fancify your man pages with some goodies'

<<<<<<< Updated upstream
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# For Konsole and Gnome-terminal
export GROFF_NO_SGR=1

# Get color support for 'less'
export LESS="--RAW-CONTROL-CHARS"

# Display your percentage into the document
export MANPAGER='less -s -M +Gg'
=======
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
>>>>>>> Stashed changes
