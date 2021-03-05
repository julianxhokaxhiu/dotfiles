# ~/.zshrc

# history
##########

# not history command prefixed with space
setopt hist_ignore_space

# no history history command
setopt hist_no_store

# history file
HISTFILE="${HOME}/.zsh_history"

# history file size
HISTSIZE=40000

# saveする量
SAVEHIST=40000

# no memory duplicate history
setopt hist_ignore_dups
setopt hist_ignore_all_dups

# delete unnececally space
setopt hist_reduce_blanks

# share history file
setopt share_history

# history zsh start and end
setopt EXTENDED_HISTORY

# append history file
setopt append_history

# compinit
###########

# Load zsh compinit module
autoload -Uz compinit
if [ ! -f ~/.zcompdump ]; then
  compinit
elif [ $(date +'%j') != $(date -r ~/.zcompdump +'%j') ]; then
  rm ~/.zcompdump
  compinit
else
  compinit -C
fi

# Enable Tab highlight style
zstyle ':completion:*' menu select

# User configuration

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Zsh Cache directory
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR
fi

# Load antibody
source <(antibody init)

# Load zsh plugins
antibody bundle < ~/.zsh_plugins

# zsh-users/zsh-history-substring-search
########################################

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# shift-tab : go backward in menu (invert of tab)
bindkey '^[[Z' reverse-menu-complete

# GEM without sudo
##################
GEM_PACKAGES="${HOME}/.gem/ruby/2.7.0"
PATH="$GEM_PACKAGES/bin:$PATH"

# NPM without sudo
##################

NPM_PACKAGES="${HOME}/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"

# Use this way to configure NPM in order to avoid pushing .npmrc by mistake with token credentials
export NPM_CONFIG_PREFIX=${NPM_PACKAGES}

# Inherit man files from the NPM packages folder
export MANPATH="$NPM_PACKAGES/share/man:/usr/local/man:$MANPATH"

# Arch: Pacman Helper
#####################

# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Removing_unused_packages_.28orphans.29
alias pacman_clean_orphans="sudo pacman -Rns $(pacman -Qtdq | tr '\n' ' ' | xargs)"
# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Database_access_speeds + AUR via pacaur
alias pacman_clean_cache="yay -Sc"

# Kubernetes
############
# KubeCtl
source <(kubectl completion zsh)
# KubeAdm
source <(kubeadm completion zsh)
# Helm Package Manager
source <(helm completion zsh)

# Utilities
###########

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

is_domain_available() {
  whois $1 | egrep -q \
    '^NOT FOUND|^not found|^No match|^AVAILABLE' 2>&1 >&/dev/null

  if [ $? -eq 0 ]; then
    echo "YES! :)"
  else
    echo "NO :("
  fi
}

# Update Arch Mirrorlist based on the best ranked mirror for your current country ( IP Based )
pacman_updatelist() {
  COUNTRY=`curl -s -L "http://ip-api.com/line/?fields=countryCode"`
  #COUNTRY=all

  MIRRORLIST=`curl -s "https://archlinux.org/mirrorlist/?country=$COUNTRY&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' | rankmirrors -n 6 -`

  echo "$MIRRORLIST" | sudo tee /etc/pacman.d/mirrorlist > /dev/null

  if [ $? -eq 0 ]; then
    echo "Pacman mirrorlist updated successfully for country $COUNTRY."
  else
    echo "Something went wrong. Please retry."
  fi
}

# Optimize disk on VMWare
optimize_vmware_disk() {
  sudo e4defrag /
  dd if=/dev/zero of=wipefile bs=1M; sync; rm wipefile
  sudo vmware-toolbox-cmd disk shrinkonly
}

# Cleanup NPM node_modules on the current working directory recursively
cleanup_node_modules() {
  find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}
