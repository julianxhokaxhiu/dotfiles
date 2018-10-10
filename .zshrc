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

# NPM without sudo
##################

NPM_PACKAGES="${HOME}/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"

# Use this way to configure NPM in order to avoid pushing .npmrc by mistake with token credentials
export NPM_CONFIG_PREFIX=${NPM_PACKAGES}

# Inherit man files from the NPM packages folder
export MANPATH="$NPM_PACKAGES/share/man:/usr/local/man:$MANPATH"

# NPX
#####
source <(npx --shell-auto-fallback zsh)

# Arch: Pacman Helper
#####################

# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Removing_unused_packages_.28orphans.29
alias pacman_clean_orphans='sudo bash -c "pacman -Rns $(pacman -Qtdq)"'
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
