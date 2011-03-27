# zshuery #
jQuery did this for JS, we're doing it for zsh. Simplest zsh configuration framework ever. Based on the "Explicit is better than implicit" paradigm (?) from the Zen of Python, so (almost) nothing gets loaded when you source the file.

## What's wrong with [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)? ##
It's a big ass thing which loads a lot of files → pretty slow on HDDs. I've got tired of it and made my own framework. You're looking at it now :)

## What's inside? ##

- Checks: variables IS_MAC, IS_LINUX, HAS_BREW, HAS_APT, HAS_YUM for your if statements
- Some common defaults
- Plug&play support for Ubuntu's command-not-found, [hub](http://chriswanstrath.com/hub/), RubyGems on Debian/Ubuntu, rvm
- Prompt setting aliases (for better readability) and "prompts" command which just sets both left and right prompts
- Neat stuff for your prompt: [virtualenv](http://www.virtualenv.org/) info, smart prompt character (by [Steve Losh](http://stevelosh.com). ± when you're in a Git repo, ☿ in a Mercurial repo, $ otherwise)
- Smart ass functions (listed below)
- Aliases, including [LOLSPEAK](http://aur.archlinux.org/packages/lolbash/lolbash/lolbash.sh) ones (loaded separately)
- Completion for a lot of stuff
- Correction

### Functions ###

- `last_modified` pretty self-explanatory
- `ex` extract archives
- `mcd` mkdir + cd
- `cdf` cd to the current path of the frontmost OS X Finder window
- `pman` open man pages in OS X Preview
- `pj` pretty-print JSON
- `cj` curl and pretty-print JSON
- `md5`, `sha1` of a string
- `gimme` install packages ([Homebrew](http://mxcl.github.com/homebrew/) on Mac OS X, apt/yum on Linux)

## Example zshrc ##
    source /your/dotfiles/zshuery/zshuery.sh
    load_defaults
    load_aliases
    load_lol_aliases
    load_completion /your/dotfiles/zshuery/completion
    load_correction

    prompts '%{$fg_bold[green]%}$DIR%{$reset_color%}$(virtualenv_info) %{$fg[yellow]%}$(prompt_char)%{$reset_color%} '

    if [ $IS_LINUX -eq 1 ]; then
        export EDITOR='emacsclient'
        export ALTERNATE_EDITOR='emacs'
    elif [ $IS_MAC -eq 1 ]; then
        export EDITOR='aquamacs'
    fi
