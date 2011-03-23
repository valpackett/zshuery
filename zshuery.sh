# jQuery did this for JS, we're doing it for zsh

# Checks
if [[ $(uname) = 'Linux' ]]; then
    IS_LINUX=1
fi
if [[ $(uname) = 'Darwin' ]]; then
    IS_MAC=1
fi
which -s brew >& /dev/null
if [ $? -eq 0 ]; then
    HAS_BREW=1
fi
which -s apt-get >& /dev/null
if [ $? -eq 0 ]; then
    HAS_APT=1
fi
which -s yum >& /dev/null
if [ $? -eq 0 ]; then
    HAS_YUM=1
fi

# Settings
autoload colors; colors;
load_defaults() {
    setopt auto_name_dirs
    setopt auto_pushd
    setopt pushd_ignore_dups
    setopt prompt_subst
    setopt no_beep
    setopt auto_cd
    setopt multios
    setopt cdablevarS
    autoload -U url-quote-magic
    zle -N self-insert url-quote-magic
    autoload -U zmv
    bindkey "^[m" copy-prev-shell-word
    HISTFILE=$HOME/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt hist_ignore_dups
    setopt share_history
    setopt append_history
    setopt hist_verify
    setopt inc_append_history
    setopt extended_history
    setopt hist_expire_dups_first
    setopt hist_ignore_space
}

# Plug and play
if [ -f /etc/zsh_command_not_found ]; then
    source /etc/zsh_command_not_found # installed in Ubuntu
fi
if [ -x `which hub` ]; then
    eval $(hub alias -s zsh)
fi
if [ -d /var/lib/gems/1.8/bin ]; then # oh Debian/Ubuntu
    export PATH=$PATH:/var/lib/gems/1.8/bin
fi

# Prompt aliases for readability
USERNAME='%n'
HOSTNAME='%m'
DIR='%~'
COLLAPSED_DIR() { # by Steve Losh
    echo $(pwd | sed -e "s,^$HOME,~,")
}

# Functions
prompt() { PS1=$1 }
prompt_char() { # by Steve Losh
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '$'
}
virtualenv_info() {
    [ $VIRTUAL_ENV ] && echo ' ('`basename $VIRTUAL_ENV`')'
}
last_modified() { # by Ryan Bates
    ls -t $* 2> /dev/null | head -n 1
}
ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar $1;;
          *.gz) gunzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *.dmg) hdiutul mount $1;; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}
mcd() { mkdir -p "$1" && cd "$1"; }
cdf() { eval cd "`osascript -e 'tell app "Finder" to return the quoted form of the POSIX path of (target of window 1 as alias)' 2>/dev/null`" }
pman() { man $1 -t | open -f -a Preview } # open man pages in OS X Preview
pj() { python -mjson.tool } # pretty-print JSON
cj() { curl -sS $@ | pj } # curl JSON
md5() { echo -n $1 | openssl md5 /dev/stdin }
sha1() { echo -n $1 | openssl sha1 /dev/stdin }
if [ $HAS_BREW -eq 1 ]; then
    gimme() { brew install $1 }
    _gimme() { reply=(`brew search`) }
elif [ $HAS_APT -eq 1 ]; then
    gimme() { sudo apt-get install $1 }
elif [ $HAS_YUM -eq 1 ]; then
    gimme() { su -c 'yum install $1' }
fi

# Aliases
load_aliases() {
    alias ..='cd ..'
    alias oo='open .' # open current dir in OS X Finder
    alias la='ls -la'
    alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
    alias clr='clear'
    alias s_http='python -m SimpleHTTPServer' # serve current folder via HTTP
    alias s_smtp='python -m smtpd -n -c DebuggingServer localhost:1025' # SMTP test server, outputs to console
    alias wget='wget --no-check-certificate'
    alias pinst='sudo python setup.py install && sudo rm -r build && sudo rm -r dist && sudo rm -r *egg-info' # install a Python package
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
_fab() { reply=(`fab --shortlist`) }
_teamocil() { reply=(`ls ~/.teamocil | sed 's/.yml//'`) }
_cap_does_task_list_need_generating() {
  if [ ! -f .cap_tasks~ ]; then return 0;
  else
    accurate=$(stat -f%m .cap_tasks~)
    changed=$(stat -f%m config/deploy.rb)
    return $(expr $accurate '>=' $changed)
  fi
}
_cap() {
  if [ -f config/deploy.rb ]; then
    if _cap_does_task_list_need_generating; then
      echo "\nGenerating .cap_tasks~..." > /dev/stderr
      cap show_tasks -q | cut -d " " -f 1 | sed -e '/^ *$/D' -e '1,2D'
> .cap_tasks~
    fi
    compadd `cat .cap_tasks~`
  fi
}
load_completion() { # thanks to Oh My Zsh and the internets
    autoload -U compinit
    fpath=($* $fpath)
    fignore=(.DS_Store $fignore)
    compinit -i
    zmodload -i zsh/complist
    setopt complete_in_word
    unsetopt always_to_end
    compctl -K _fab fab
    compctl -K _teamocil teamocil
    compctl -K _cap cap
    if [ $HAS_BREW -eq 1 ]; then
        compctl -K _gimme gimme
    fi
    [ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
    [ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
    hosts=("$_ssh_hosts[@]" "$_etc_hosts[@]" `hostname` localhost)
    zstyle ':completion:*' insert-tab pending
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*:hosts' hosts $hosts
    zstyle ':completion::complete:*' use-cache 1
    zstyle ':completion::complete:*' cache-path ./cache/
    zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
    zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
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
    SPROMPT="$fg[red]%R →$reset_color $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "
}
