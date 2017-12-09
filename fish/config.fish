set -l PRIVATE_FISH_CONFIGS_HOME $HOME/Dropbox/Apps/fish

# private pre-configs
if test -f $PRIVATE_FISH_CONFIGS_HOME/preconfig.fish
  source $PRIVATE_FISH_CONFIGS_HOME/preconfig.fish
end

# variables
set -x SPACEMACSDIR $HOME/.spacemacs
set -x GEM_HOME $HOME/.local/gem
set -x GEM_PATH $HOME/.local/gem
set -x EDITOR "emacsclient"
set fish_greeting ""
set cmd_notification_threshold 8000

# PATH
function __append_to_path -a path
  if test -d $path
    set -x PATH $path $PATH
  end
end
set -x PATH $HOME/.local/bin $PATH
__append_to_path $GEM_HOME/bin
__append_to_path /usr/texbin
__append_to_path /usr/local/sbin

# aliases
alias ghci "stack ghci"
alias ecl "emacsclient"
alias eclt "emacsclient -c"
alias cenv "cd $XDG_CONFIG_HOME"
alias cem  "cd $HOME/.emacs.d"

function em
  emacs -q --load $XDG_CONFIG_HOME/emacs/init.el $argv &
end

function emt
  emacs -nw -q --load $XDG_CONFIG_HOME/emacs/init.el $argv
end

# theme
set fish_color_autosuggestion gray
set fish_color_command purple
set fish_color_comment brown
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_error red
set fish_color_escape cyan
set fish_color_history_current cyan
set fish_color_match cyan
set fish_color_normal normal
set fish_color_operator cyan
set fish_color_param blue
set fish_color_quote green
set fish_color_redirection cyan
set fish_color_search_match \x2d\x2dbackground\x3dblack
set fish_color_selection \x2d\x2dbackground\x3dblack
set fish_color_valid_path \x2d\x2dunderline
set fish_pager_color_completion normal
set fish_pager_color_description yellow
set fish_pager_color_prefix cyan
set fish_pager_color_progress cyan

# private post-configs
if test -f $PRIVATE_FISH_CONFIGS_HOME/postconfig.fish
  source $PRIVATE_FISH_CONFIGS_HOME/postconfig.fish
end

function stack-install -a git_url
  pushd (pwd)
  set -l wd (echo -s "$TMPDIR" (date "+%Y_%m_%d_%H_%M_%S"))
  git clone $git_url $wd
  cd $wd
  stack install
  popd
end
