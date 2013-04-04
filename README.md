# zshuery
jQuery did this for JS, we're doing it for zsh. Simplest zsh configuration framework ever. Based on the "Explicit is better than implicit" paradigm (is it one?) from the Zen of Python, so (almost) nothing gets loaded when you source the file.

## What's wrong with [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)?
It's a big ass thing which loads a lot of files → pretty slow on HDDs (don't worry, I have an SSD now!). I've got tired of it and made my own framework. You're looking at it now :)

## What's inside?

- Checks: functions `is_mac`, `is_linux`, `is_freebase`, `has_brew`, `has_apt`, `has_yum` for your if statements (variables like `IS_MAC` are deprecated)
- Some common defaults
- **Plug&play support for Ubuntu's command-not-found, [hub](http://chriswanstrath.com/hub/), RubyGems on Debian/Ubuntu, [rvm](http://rvm.beginrescueend.com), [rbenv](https://github.com/sstephenson/rbenv), [jump](https://github.com/afriggeri/jump)**
- Prompt setting aliases (for better readability) and "prompts" command which just sets both left and right prompts
- Neat stuff for your prompt: [virtualenv](http://www.virtualenv.org/) info, smart prompt character (by [Steve Losh](http://stevelosh.com). ± when you're in a Git repo, ☿ in a Mercurial repo, $ otherwise), rvm/rbenv ruby version
- Aliases, including [LOLSPEAK](http://aur.archlinux.org/packages/lolbash/lolbash/lolbash.sh) ones (loaded separately)
- Completion for a lot of stuff
- Correction
- Current directory in title support: add `update_terminal_cwd` to your chpwd(). In OS X Lion Terminal.app, this'll be draggable!

### Functions & aliases

- `last_modified` pretty self-explanatory
- `ex` extract archives
- `mcd` mkdir + cd
- `..`, `....` cd-ing .. and ../..
- `beep`
- `pj` pretty-print JSON
- `cj` curl and pretty-print JSON
- `md5`, `sha1`, `sha256`, `sha512`, `rot13`, `rot47`, `urldecode`, `urlencode` of a string
- `gimme` install packages ([Homebrew](http://mxcl.github.com/homebrew/) on Mac OS X, apt/yum on Linux)
- `pinst` install python package from current dir and remove build, dist and egg-info folders
- `s_http` serve current folder via http
- `s_smtp` launch an SMTP test server for development, on port 1025
- `lst` ls tree-style
- `up` find a file in parent dirs
- `path` pretty-print $PATH (with colors! yay!)

#### For OS X only

- `vol` get/set sound volume
- `locatemd` search with Spotlight
- `ql` open something in Quick Look
- `oo` open current dir in Finder
- `cdf` cd to the current path of the frontmost Finder window
- `pman` open man pages in Preview
- `mailapp` creates a message in Mail.app from the first arg as a string or stdin if there are no args (eg. you can pipe stuff into it)
- `sparrow` same for Sparrow.app
- `evernote` same with a note in Evernote.app
- `quit`, `relaunch` OS X GUI apps
- `selected` Finder items

## Example zshrc
```sh
source $yourdotfiles/zshuery/zshuery.sh
load_defaults
load_aliases
load_lol_aliases
load_completion $yourdotfiles/zshuery/completion
load_correction

prompts '%{$fg_bold[green]%}$(COLLAPSED_DIR)%{$reset_color%}$(virtualenv_info) %{$fg[yellow]%}$(prompt_char)%{$reset_color%} ' '%{$fg[red]%}$(ruby_version)%{$reset_color%}'

if is_mac; then
    export EDITOR='mvim'
else
    export EDITOR='vim'
fi

chpwd() {
    update_terminal_cwd
}
```
