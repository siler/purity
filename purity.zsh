# Purity
# by Kevin Lanni
# https://github.com/therealklanni/purity
# MIT License

# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)

prompt_purity_preexec() {
    # shows the current dir and executed command in the title when a process is active
    print -Pn "\e]0;"
    echo -nE "$PWD:t: $2"
    print -Pn "\a"
}

# string length ignoring ansi escapes
prompt_purity_string_length() {
    echo ${#${(S%%)1//(\%([KF1]|)\{*\}|\%[Bbkf])}}
}

prompt_purity_precmd() {
    if (( $+functions[git-info] )); then
        git-info
    fi

    # shows the full path in the title
    print -Pn '\e]0;%~\a'
}

prompt_purity_setup() {
    # prevent percentage showing up
    # if output doesn't end with a newline
    export PROMPT_EOL_MARK=''

    prompt_opts=(cr subst percent)

    zmodload zsh/datetime
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd prompt_purity_precmd
    add-zsh-hook preexec prompt_purity_preexec

    # show username@host if logged in through SSH
    [[ "$SSH_CONNECTION" != '' ]] && prompt_purity_username='%n@%m '

    zstyle ':prezto:module:git:info' verbose 'yes'

    zstyle ':prezto:module:git:info:branch' format '%b'
    zstyle ':prezto:module:git:info:position' format '%p'
    zstyle ':prezto:module:git:info:commit' format '%c'

    zstyle ':prezto:module:git:info:added' format '%F{green}✓%f'
    zstyle ':prezto:module:git:info:modified' format '%F{blue}✶%f'
    zstyle ':prezto:module:git:info:deleted' format '%F{red}✗%f'
    zstyle ':prezto:module:git:info:renamed' format '%F{magenta}➜%f'
    zstyle ':prezto:module:git:info:unmerged' format '%F{yellow}═%f'
    zstyle ':prezto:module:git:info:untracked' format '%F{cyan}✩%f'

    zstyle ':prezto:module:git:info:keys' format \
        'prompt' ' %F{cyan}git%f:%F{yellow}$(coalesce "%b" "%p" "%c")%f %a%m%d%r%U%u' \
        'rprompt' ''

    # prompt turns red if the previous command didn't exit with 0
    PROMPT='%F{blue}${PWD/#$HOME/~}${git_info:+${(e)git_info[prompt]}} %(?.%F{green}.%F{red})❯%f '
}

prompt_purity_setup "$@"
