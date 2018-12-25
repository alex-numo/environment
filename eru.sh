#!/usr/bin/env bash
#
################################################################################
#
# Of the theme that I have declared to you, I will now that ye make in harmony
# together a Great Music. And since I have kindled you with the Flame
# Imperishable, ye shall show forth your powers in adorning this theme, each
# with his own thoughts and devices, if he will. But I win sit and hearken, and
# be glad that through you great beauty has been wakened into song.
#
#   John Ronald Reuel Tolkien (c)
#
################################################################################
#
# Run this script to install all dependencies and configurations. If you wish to
# perform only specific task or tasks pass them as arguments, space-separated.
#
#   ./eru.sh [theme] [theme] ...
#
# For example,
#
#   ./eru.sh linking repositories packages
#

#
# Hi, my name is
#

fellow="d12frosted"

#
# Fast failure
#

set -e

#
# Get the OS info
#

KERNEL_NAME=$(uname -s | awk '{print tolower($0)}')
OS_NAME="unknown"
case $KERNEL_NAME in
  darwin)
    OS_NAME=macos
    ;;
  linux)
    if [[ "$(uname -r)" == *"arch"* ]]; then
      OS_NAME="arch"
    fi
    ;;
  *)
    ;;
esac

#
# Logging
#

function error() {
  echo -e "\033[0;31m$*\033[0m"
}

function intro() {
  echo -e "\033[0;34m$*\033[0m"
}

function log() {
  echo -e "$*"
}

function section() {
  echo -e "\033[0;34m=> $*\033[0m"
}

function theme() {
  echo -e "\033[1;32m=> $1 Theme :: ${@:2}\033[0m"
}

function optional_theme() {
  echo -e "\033[1;32m-> $1 Theme :: ${@:2}\033[0m"
}

function inactive_theme() {
  echo -e "\033[1;37m-> $1 Theme :: ${@:2}\033[0m"
}

#
# Greetings
#

intro "Of the theme that I have declared to you, I will now that ye make in harmony
together a Great Music. And since I have kindled you with the Flame
Imperishable, ye shall show forth your powers in adorning this theme, each with
his own thoughts and devices, if he will. But I win sit and hearken, and be glad
that through you great beauty has been wakened into song."
intro

log "Kernel:           $KERNEL_NAME"
log "Operating system: $OS_NAME"
log

#
# Helpers
#

theme "Supporting" "Defining helpers"

function theme_guard() {
  key=$(echo "$1" | awk '{print tolower($0)}')
  guard=$(eval echo "\$guard_$key")
  if [[ "$ALL" = "true" || "$guard" = "true" ]]; then
    optional_theme "$1" "${@:2}"
    return 0
  else
    inactive_theme "$1" "${@:2}"
    return 1
  fi
}

function macos_guard() {
  [[ "$OS_NAME" == "macos" ]]
  return
}

function arch_guard() {
  [[ "$OS_NAME" == "arch" ]]
  return
}

function qualify_repo_url() {
  if [[ "$1" = "https://"* || "$1" = "git@"* ]]; then
    echo "$1"
  elif [[ "$USE_HTTPS" = "true" ]]; then
    echo  "https://github.com/$1.git"
  else
    echo "git@github.com:$1.git"
  fi
}

function git_lg() {
  git --no-pager \
      log \
      --graph \
      --pretty=format:'%Cred%h%Creset %C(bold blue)<%an> -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' \
      "$*"
}

function sync_repo() {
  section "sync_repo $*"

  remote=origin
  wd=$(eval echo "$1")
  url=$(qualify_repo_url "$2")
  branch="$3"
  if [[ $branch = "" ]]; then
    branch="master"
  fi

  if [[ -d "$wd/.git" ]]; then
    log "$wd already exists"
  else
    git clone "$url" "$wd" -b "$branch"
  fi

  cd "$wd" && {
    git diff-index --quiet HEAD -- || {
      error "Your working directory is not clean."
      error "Please commit or stash all changes before proceeding."
      return 1
    }

    current_branch=$(git symbolic-ref --short HEAD)
    if [[ $branch != "$current_branch" ]]; then
      log "Switching from $current_branch to $branch"
      git checkout "$branch"
    fi

    if [[ -d .git/refs/remotes/$remote ]]; then
      current_url=$(git remote get-url $remote)
      if [[ $current_url != "$url" ]]; then
        log "Remote '$branch' has wrong url, so updating it"
        log "  $current_url -> $url"
        git remote set-url $remote "$url"
      fi
    else
      log "Could not find remote '$remote', so adding it"
      git remote add $remote "$url"
    fi

    log "fetch $remote"
    git fetch $remote
    if [[ $(git rev-parse HEAD) == $(git rev-parse $remote/$branch) ]]; then
      log "Everything up-to-date"
      return 0
    fi

    if [ `git rev-list HEAD..$remote/$branch --count` != 0 ]; then
      log "Fetched changes:"
      git_lg HEAD..$remote/$branch
      log
    fi

    log "rebase onto $remote/$branch"
    git rebase $remote/$branch

    if [[ "$url" = *"$fellow"* ]]; then
      if [ `git rev-list $remote/$branch..HEAD --count` != 0 ]; then
        log "Changes to push:"
        git_lg $remote/$branch..HEAD
        log
      fi

      log "pushing changes"
      git push $remote $branch
    fi
  }
}

function ensure_dir() {
  if [[ ! -d "$1" ]]; then
    log "create $1"
    mkdir -p "$1"
  fi
}

function check() {
  command -v "$1" >/dev/null 2>&1
}

function safe_link() {
  f=$(eval echo $1)
  s="$target/$f"
  shift
  t="${*/#\~/$HOME}"
  d=$(dirname "$t")

  if [[ ! -f "$s" && ! -d "$s" ]]; then
    error "can not link '$s' as it does not exist"
    exit 1
  fi

  if [[ ! -d $d ]]; then
    log "create $d"
    mkdir -p "$d"
  fi

  if [[ -L "$t" ]]; then
    log "relink $s -> $t"
    rm "$t"
  else
    log "link $s -> $t"
  fi

  ln -s "$s" "$t"
}

function map_lines() {
  if [[ -f "$2" ]]; then
    while IFS='' read -r line || [[ -n "$line" ]]; do
      $1 $line
    done < "$2"
  fi
}

function download_bin() {
  fp="$HOME/.local/bin/$1"
  curl --silent -o "$fp" "$2"
  chmod a+x "$HOME/.local/bin/$1"
  hash -r
}

#
# Setup variables
#

theme "Supporting" "Defining variables"

target=$XDG_CONFIG_HOME
if [[ "$target" = "" ]]; then
  target="$HOME/.config"
fi
XDG_CONFIG_HOME=$target

if [[ "$XDG_CONFIG_CACHE" = "" ]]; then
  XDG_CONFIG_CACHE="$HOME/.cache"
fi

DEVELOPER=$HOME/Developer
if [[ "$USER" != "$fellow" ]]; then
  DEVELOPER=$HOME/Developer/personal
fi

ALL="true"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  if [[ "$1" != "" ]]; then
    key=$(echo "$1" | awk '{print tolower($0)}')
    declare -r "guard_$key=true"
    ALL="false"
  fi
  shift
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ "$INTERACTIVE" = "" ]]; then
  INTERACTIVE=true
fi

#
# Actual bootstrap
#

theme "Guardian" "Ensure all directories exists"
ensure_dir "$HOME/.local/bin"
ensure_dir "$DEVELOPER"
ensure_dir "$HOME/Dropbox/Apps/Emacs"

# TODO: make it working on Linux from command line
macos_guard && theme_guard "SSH" "Checking SSH keys" && {
  if [[ "$INTERACTIVE" = "true" ]]; then
    ssh_key_add_url="https://github.com/settings/ssh/new"
    ssh_key_path="$HOME/.ssh/id_rsa"
    ssh_key_pub_path="${ssh_key_path}.pub"
    ssh_config_path="$HOME/.ssh/config"

    if [[ -f "$ssh_key_path" ]]; then
      log "SSH key found at $ssh_key_path."
    else
      log "No SSH key found."
      mkdir -p $(dirname "$ssh_key_path")
      ssh-keygen -t rsa -b 4096 -C "$USER" -f "$ssh_key_path"
      log "SSH key was generated."
    fi

    log "Starting ssh-agent"
    eval "$(ssh-agent -s)"

    macos_guard && {
      log "Automatically load SSH key and use Keychain"
      echo "Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile $ssh_key_path" > "$ssh_config_path"
    }

    log "Add SSH key to ssh-agent"
    ssh-add -K ~/.ssh/id_rsa

    log "Make sure to add SSH key to GitHub"
    pbcopy < "$ssh_key_pub_path"
    open "$ssh_key_add_url"
    read -p "Press enter to continue"
  fi
}

theme_guard "Repositories" "Sync environment repository" && {
  sync_repo "$XDG_CONFIG_HOME" "d12frosted/environment" || true
}

theme_guard "Repositories" "Sync repositories from Repofiles" && {
  map_lines sync_repo "$target/Repofile" || true
  map_lines sync_repo "$XDG_CONFIG_CACHE/eru/Repofile" || true
}

theme_guard "Linking" "Link all files as defined in Linkfiles" && {
  map_lines safe_link "$target/Linkfile"
  map_lines safe_link "$target/${KERNEL_NAME}/Linkfile" || true
  map_lines safe_link "$target/${OS_NAME}/Linkfile" || true
  map_lines sync_link "$XDG_CONFIG_CACHE/eru/Linkfile" || true
}

arch_guard && {
  theme_guard "packages" "Bootstrap Arch Linux" && {
    section "Install crutial dependenices"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed base-devel
    sudo pacman -S --noconfirm git pacman-contrib

    section "Rank mirrors for pacman"
    mirrorlist="/etc/pacman.d/mirrorlist"
    mirrorlist_bak="${mirrorlist}.bak"
    if [[ -f "$mirrorlist_bak" ]]; then
      log "Not updating mirrors list, because '$mirrorlist_bak' exists"
      log "Delete in order to re-rank mirrors"
    else
      mirrorlist_tmp=$(mktemp)
      curl -s 'https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=4' \
        | sed -e 's/^#Server/Server/' -e '/^#/d' > "$mirrorlist_tmp"
      sudo cp "$mirrorlist_tmp" "$mirrorlist_bak"
      sudo rankmirrors -n 6 "$mirrorlist_bak" > "$mirrorlist"
    fi

    section "Install yay for simpler AUR access"
    check yay || {
      yay_dir=$(mktemp -d)
      git clone https://aur.archlinux.org/yay.git "$yay_dir"
      cd "$yay_dir" && {
        makepkg -si --noconfirm
      }
    }
  }

  theme_guard "packages" "Install all dependencies" && {
    aurs=$(cat "$target/arch/Aurfile" | tr '\n' ' ')
    yay -Syu --noconfirm $aurs

    # map_lines 'sudo pacman -Syu --noconfirm' "$target/arch/Pacmanfile"
    # is not efficient, so it's better to read whole file and call pacman once
    pkgs=$(cat "$target/arch/Pacmanfile" | tr '\n' ' ')
    sudo pacman -Syu --noconfirm $pkgs
  }

  theme_guard "hardware" "Setup keyboard" && {
    sudo cp $XDG_CONFIG_HOME/xorg/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
  }
  theme_guard "hardware" "Setup touchpad" && {
    sudo cp $XDG_CONFIG_HOME/xorg/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
  }
}

macos_guard && {
  theme_guard "packages" "Ensure brew exists" && {
    check brew || {
      info "Installing brew"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      brew update
    }
  }

  theme_guard "packages" "Install all dependencies" && {
    cd "$target/macos" && brew bundle
  }
}

theme "Fish" "Setup fish variables"
echo "set -U XDG_CONFIG_HOME $target" | fish
echo "set -x XDG_CONFIG_HOME $target" | fish
echo "set -x SPACEMACSDIR $XDG_CONFIG_HOME/emacs" | fish

theme "Git" "Create a local git config file"
touch "$target/git/local.config"

macos_guard && {
  theme_guard "OS" "Write all defaults" && {
    cd "$target/macos" && sudo ./defaults.sh
  }

  theme "skhd" "Patch skhd application PATH" && {
    check skhd && {
      "$target/utils/bin/patch_skhd_path"
    }
  }
}

theme_guard "Emacs" "Refresh Nucleus" && {
  nucleus --yes refresh
}

theme_guard "Guardian" "Check that Emacs runs as expected" && {
  emacs --batch -l "$target/emacs/test.el"
}

true