# prompt

prompt() {
    local COLOR_ACCENT="\[\e[0;$1m\]"
    local COLOR_RESET="\[\e[0m\]"
    echo -ne "${COLOR_ACCENT}[${COLOR_RESET}\w${COLOR_ACCENT}]\$${COLOR_RESET} "
}

PS1="$(prompt 33)"
