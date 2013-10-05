# jQuery did this for JS, we're doing it for zsh

# Checks
is_mac() { [[ $OSTYPE == darwin* ]] }
is_freebsd() { [[ $OSTYPE == freebsd* ]] }
is_linux() { [[ $OSTYPE == linux-gnu ]] }

has_brew() { [[ -n ${commands[brew]} ]] }
has_apt() { [[ -n ${commands[apt-get]} ]] }
has_yum() { [[ -n ${commands[yum]} ]] }

# DEPRECATED (!)
IS_MAC=`is_mac && echo 1 || echo 0`
IS_LINUX=`is_linux && echo 1 || echo 0`
HAS_BREW=`has_brew && echo 1 || echo 0`
HAS_APT=`has_apt && echo 1 || echo 0`
HAS_YUM=`has_yum && echo 1 || echo 0`

# Settings
autoload colors; colors;
load_defaults() {
    setopt auto_name_dirs
    setopt pushd_ignore_dups
    setopt prompt_subst
    setopt no_beep
    setopt auto_cd
    setopt multios
    setopt cdablevarS
    setopt transient_rprompt
    setopt extended_glob
    autoload -U url-quote-magic
    zle -N self-insert url-quote-magic
    autoload -U zmv
    bindkey "^[m" copy-prev-shell-word
    HISTFILE=$HOME/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt hist_ignore_dups
    setopt hist_reduce_blanks
    setopt share_history
    setopt append_history
    setopt hist_verify
    setopt inc_append_history
    setopt extended_history
    setopt hist_expire_dups_first
    setopt hist_ignore_space
}

# Plug and play
if [[ -f /etc/zsh_command_not_found ]]; then
    source /etc/zsh_command_not_found # installed in Ubuntu
fi
if [[ -n ${commands[hub]} ]]; then
    function git(){hub $@}
fi
if [[ -n ${commands[jump]} ]]; then
    jump() {
        cd $(JUMPPROFILE=1 command jump $@)
    }
    alias j="jump -a"
fi
if [[ -d /var/lib/gems/1.8/bin ]]; then # oh Debian/Ubuntu
    export PATH=$PATH:/var/lib/gems/1.8/bin
fi
# RVM or rbenv
if [[ -s $HOME/.rvm/scripts/rvm ]]; then
    source $HOME/.rvm/scripts/rvm
    RUBY_VERSION_PREFIX='r'
    ruby_version() {
        if [[ $RUBY_VERSION != "" ]]; then
            echo $RUBY_VERSION_PREFIX$RUBY_VERSION | sed s/ruby-//
        else echo ''; fi
    }
elif [[ -d $HOME/.rbenv ]]; then
    export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
    if [[ -f $HOME/.rbenv/completions/rbenv.zsh ]]; then
      source $HOME/.rbenv/completions/rbenv.zsh
    fi
    rbenv rehash 2>/dev/null
    ruby_version() { rbenv version-name }
else
    ruby_version() { echo '' }
fi
# Current directory in title
if [[ $TERM_PROGRAM == "Apple_Terminal" ]]; then
    update_terminal_cwd() {
        printf '\e]7;%s\a' "file://$HOST$(pwd | sed -e 's/ /%20/g')"
    }
else
    case $TERM in
        sun-cmd)
            update_terminal_cwd() { print -Pn "\e]l%~\e\\" };;
        *xterm*|rxvt|(dt|k|E)term)
            update_terminal_cwd() { print -Pn "\e]2;%~\a" };;
        *)
            update_terminal_cwd() {};;
    esac
fi
# Prompt aliases for readability
USER_NAME='%n'
HOST_NAME='%m'
DIR='%~'
COLLAPSED_DIR() { # by Steve Losh
    echo $(pwd | sed -e "s,^$HOME,~,")
    local PWD_URL="file://$HOST_NAME${PWD// /%20}"
}

# Functions
prompts() {
    PROMPT=$1
    RPROMPT=$2
    PS2=$3
}
prompt_char() { # by Steve Losh
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    if (( $# == 0 )); then
      echo '$'
    else
      echo $1
    fi
}

# Aliases
load_aliases() {
    alias ..='cd ..'
    alias ....='cd ../..'
    alias la='ls -la'
    if is_mac; then
        alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
        alias oo='open .' # open current dir in OS X Finder
    fi
    alias clr='clear'
    alias s_http='python -m SimpleHTTPServer' # serve current folder via HTTP
    alias s_smtp='python -m smtpd -n -c DebuggingServer localhost:1025' # SMTP test server, outputs to console
    alias wget='wget --no-check-certificate'
    alias pinst='sudo python setup.py install && sudo rm -r build && sudo rm -r dist && sudo rm -r *egg-info' # install a Python package
    alias beep='echo -n "\a"'
    alias lst="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
}
load_lol_aliases() {
    # Source: http://aur.archlinux.org/packages/lolbash/lolbash/lolbash.sh
    alias wtf='dmesg'
    alias onoz='cat /var/log/errors.log'
    alias rtfm='man'
    alias visible='echo'
    alias invisible='cat'
    alias moar='more'
    alias icanhas='mkdir'
    alias donotwant='rm'
    alias dowant='cp'
    alias gtfo='mv'
    alias hai='cd'
    alias plz='pwd'
    alias inur='locate'
    alias nomz='ps aux | less'
    alias nomnom='killall'
    alias cya='reboot'
    alias kthxbai='halt'
}

# Completion
load_completion() {
    # http://www.reddit.com/r/commandline/comments/kbeoe/you_can_make_readline_and_bash_much_more_user/
    # https://wiki.archlinux.org/index.php/Zsh
    autoload -U compinit
    fpath=($* $fpath)
    fignore=(.DS_Store $fignore)
    compinit -i
    zmodload -i zsh/complist
    setopt complete_in_word
    setopt auto_remove_slash
    unsetopt always_to_end
    has_brew && compctl -K _gimme gimme
    [[ -f ~/.ssh/known_hosts ]] && hosts=(`awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' `)
    [[ -f ~/.ssh/config ]] && hosts=($hosts `grep '^Host' ~/.ssh/config | sed s/Host\ // | egrep -v '^\*$'`)
    [[ -f /var/lib/misc/ssh_known_hosts ]] && hosts=($hosts `awk -F "[, ]" '{print $1}' /var/lib/misc/ssh_known_hosts | sort -u`)
    zstyle ':completion:*' insert-tab pending
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    highlights='${PREFIX:+=(#bi)($PREFIX:t)(?)*==31=1;32}':${(s.:.)LS_COLORS}}
    highlights2='=(#bi) #([0-9]#) #([^ ]#) #([^ ]#) ##*($PREFIX)*==1;31=1;35=1;33=1;32=}'
    zstyle -e ':completion:*' list-colors 'if [[ $words[1] != kill && $words[1] != strace ]]; then reply=( "'$highlights'" ); else reply=( "'$highlights2'" ); fi'
    unset highlights
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*' squeeze-slashes true
    zstyle ':completion:*' expand 'yes'
    zstyle ':completion:*:match:*' original only
    zstyle ':completion:*:approximate:*' max-errors 1 numeric
    zstyle ':completion:*:hosts' hosts $hosts
    zstyle ':completion::complete:*' use-cache 1
    zstyle ':completion::complete:*' cache-path ./cache/
    zstyle ':completion:*:cd:*' ignore-parents parent pwd
    zstyle ':completion:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
    zstyle ':completion:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
    zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    zstyle ':completion:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

}

# Correction
load_correction() {
    setopt correct_all
    alias man='nocorrect man'
    alias mv='nocorrect mv'
    alias mysql='nocorrect mysql'
    alias mkdir='nocorrect mkdir'
    alias erl='nocorrect erl'
    alias curl='nocorrect curl'
    alias rake='nocorrect rake'
    alias make='nocorrect make'
    alias cake='nocorrect cake'
    alias lessc='nocorrect lessc'
    alias lunchy='nocorrect lunchy'
    SPROMPT="$fg[red]%R →$reset_color $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "
}
