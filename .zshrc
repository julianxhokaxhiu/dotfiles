# ~/.zshrc

# Enable to start measuring
# zmodload zsh/zprof

# helpers
##########

###############################################################################
# Install an Arch Linux package only if not installed already
###############################################################################
# Arguments:
# $1: Package name
###############################################################################
function ensure_archlinux_package
{
  _PACKAGE_NAME="$1"

  if ! yay -Qs $_PACKAGE_NAME > /dev/null 2>&1; then
    yay -S $_PACKAGE_NAME
  fi
}

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

# Preferred diff program
export DIFFPROG='meld'

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Zsh Cache directory
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR
fi

## https://getantidote.github.io/
#################################

antidote_dir=${ZDOTDIR:-~}/.antidote
plugins_txt=${ZDOTDIR:-~}/.zsh_plugins.txt
static_file=${ZDOTDIR:-~}/.zsh_plugins.zsh

# Clone antidote if necessary and generate a static plugin file.
if [[ ! $static_file -nt $plugins_txt ]]; then
  [[ -e $antidote_dir ]] ||
    git clone --depth=1 https://github.com/mattmc3/antidote.git $antidote_dir
  (
    source $antidote_dir/antidote.zsh
    [[ -e $plugins_txt ]] || touch $plugins_txt
    antidote bundle <$plugins_txt >$static_file
  )
fi

# Uncomment this if you want antidote commands like `antidote update` available
# in your interactive shell session:
# autoload -Uz $antidote_dir/functions/antidote

# source the static plugins file
source $static_file

# cleanup
unset antidote_dir plugins_txt static_file

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

# Starship Init
###################
eval "$(starship init zsh)"

# GEM without sudo
##################
GEM_PACKAGES="${HOME}/.gem/ruby/2.7.0"
export PATH="$GEM_PACKAGES/bin:$PATH"

# NPM without sudo
##################

NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$NPM_PACKAGES/bin:$PATH"

# Use this way to configure NPM in order to avoid pushing .npmrc by mistake with token credentials
export NPM_CONFIG_PREFIX=${NPM_PACKAGES}

# Inherit man files from the NPM packages folder
export MANPATH="$NPM_PACKAGES/share/man:/usr/local/man:$MANPATH"

# pnpm setup
############

export PNPM_HOME="${HOME}/.pnpm"
export PATH="${PNPM_HOME}:$PATH"

# pipx setup
############

export PIPX_HOME="${HOME}/.pipx"
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export PIPX_MAN_DIR="${PIPX_HOME}/share/man"
export PATH="${PIPX_BIN_DIR}:$PATH"

# make sure you run 'pnpm install-completion zsh' at least once
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && source ~/.config/tabtab/zsh/__tabtab.zsh || true

# Arch: Pacman Helper
#####################

# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Removing_unused_packages_.28orphans.29
command -v pacman &>/dev/null && alias pacman_clean_orphans="sudo pacman -Rns $(pacman -Qtdq | tr '\n' ' ' | xargs)"
# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Database_access_speeds + AUR via pacaur
command -v yay &>/dev/null && alias pacman_clean_cache="yay -Sc"

# asdf-vm
#########
[[ -f /opt/asdf-vm/asdf.sh ]] && source /opt/asdf-vm/asdf.sh

# Kubernetes
############
# KubeCtl
command -v kubectl &>/dev/null && source <(kubectl completion zsh) && export PATH="${HOME}/.krew/bin:${PATH}"
# KubeAdm
command -v kubeadm &>/dev/null && source <(kubeadm completion zsh)
# Helm Package Manager
command -v helm &>/dev/null && source <(helm completion zsh)
# Kind
command -v kind &>/dev/null && source <(kind completion zsh)
# Tilt
command -v tilt &>/dev/null && source <(tilt completion zsh)
# ArgoCD
command -v argocd &>/dev/null && source <(argocd completion zsh)
# Knative
command -v kn &>/dev/null && source <(kn completion zsh)

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
  COUNTRY=$(curl -s -L "http://ip-api.com/line/?fields=country")

  sudo ghostmirror -PoclLS $COUNTRY,Germany,Italy,France /etc/pacman.d/mirrorlist 30 state,outofdate,morerecent,ping
}

# Compacts the VM disk to the minimum size possible ( and shrinks the disk file if you're on VMWare) - Use this script if you're on WSL2: https://gist.github.com/julianxhokaxhiu/8fc7f4eafbaf5498e8265d26ccfcb552
compact_vm_disk() {
  sudo e4defrag /
  dd if=/dev/zero of=wipefile bs=1M; sync; rm wipefile
  which vmware-toolbox-cmd >/dev/null && sudo vmware-toolbox-cmd disk shrinkonly
}

# Flush journalctl logs
flush_vm_logs() {
  sudo journalctl --flush --rotate --vacuum-time=1s
  sudo journalctl --user --flush --rotate --vacuum-time=1s
}

# Cleanup NPM node_modules on the current working directory recursively
cleanup_node_modules() {
  find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}

# Cleanup dead Kubernetes pods
cleanup_kubernetes_pods() {
  kubectl get pods --all-namespaces | grep -E 'ImagePullBackOff|ErrImagePull|Evicted|Error' | awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod
}

# Force cleanup terminated pods
kill_kubernetes_terminating_pods() {
  kubectl get pods --all-namespaces | grep -E 'Terminating' | awk '{print $2 " --force=true --namespace=" $1}' | xargs kubectl delete pod
}

# Bulk rename tool
autoload zmv

# https://github.com/jryberg/wsl2-ssh-pageant
if [ ! -z "${WSL_DISTRO_NAME}" ]; then
  alias xdg-open="cmd.exe /c start"

  wsl2_ssh_pageant_bin="$HOME/.ssh/wsl2-ssh-pageant.exe"

  if [ ! -f "$wsl2_ssh_pageant_bin" ]; then
    echo -e ">> WSL2 Detected! Installing wsl2-ssh-pageant and required dependencies"
    # check if socat and ss are installed too
    ubm_ensure_archlinux_package "socat"
    ubm_ensure_archlinux_package "ss"
    # install wsl2 ssh pageant daemon
    wget -O "$wsl2_ssh_pageant_bin.zip" "https://github.com/jryberg/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe.zip"
    unzip "$wsl2_ssh_pageant_bin.zip"
    rm "$wsl2_ssh_pageant_bin.zip"
    chmod +x "$wsl2_ssh_pageant_bin"
  fi

  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
  if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
    rm -f "$SSH_AUTH_SOCK"
    if test -x "$wsl2_ssh_pageant_bin"; then
      (setsid nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"$wsl2_ssh_pageant_bin" >/dev/null 2>&1 &)
    else
      echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
    fi
    unset wsl2_ssh_pageant_bin
  fi

  # https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/
  WSL_SYSTEMD_ENABLED=$(grep 'systemd=true' /etc/wsl.conf)
  if [ -z "${WSL_SYSTEMD_ENABLED}" ]; then
  echo "Enabling native WSL2 systemd support..."
  sudo tee -a /etc/wsl.conf << EOF
[boot]
systemd=true
EOF
fi
fi


# Measure curl endpoint response times
curl_measure() {
cat << EOF >> /tmp/curl-format.txt
     time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
EOF

  curl -w "@/tmp/curl-format.txt" -o /dev/null -s "$1"
  rm /tmp/curl-format.txt
}

# Visualize certificate chain
# Source: https://stackoverflow.com/a/59412853
seecert() {
  nslookup $1
  (openssl s_client -showcerts -servername $1 -connect $1:443 <<< "Q" | openssl x509 -text | grep -iA2 "Validity")
}

# Get K8s Pods on each node by selector
kubectl_get_pods_in_node() {
  kubectl get nodes -l $1 -o jsonpath="{range .items[*]}spec.nodeName={.metadata.name}{'\n'}{end}" | xargs -t -n1 kubectl get pods --all-namespaces --field-selector
}

# Build docker-compose projects under proxy
docker_compose_build_proxy() {
  docker buildx bake -f docker-compose.yml
}

# Disable proxy in the current environment
disable_proxy() {
  PROXIES=("HTTP" "HTTPS" "FTP" "RTSP" "SOCKS" "Gopher" "NO" "ALL")
  for PROXY in "${PROXIES[@]}"
  do
    :
    unset "${PROXY:l}_proxy"
    unset "${PROXY}_PROXY"
  done
}

### ====================================================================== ###

# Run a macOS machine using docker
# $1: the macos distro name ( big-sur, mojave, monterey, ventura, ... ). See https://github.com/dockur/macos?tab=readme-ov-file#how-do-i-select-the-macos-version
docker_run_macos() {
  echo "Once you're done installing macOS, you can make the VM faster using some tricks you can find here: https://github.com/sickcodes/osx-optimizer"

  MACOS_DISTRO="${1:-tahoe}"
  MACOS_LOCAL_PATH="$(realpath ~/.local)/dockur-macos/${MACOS_DISTRO}"
  MACOS_CONTAINER_PATH="/storage"

  xdg-open http://localhost:8006/

  mkdir -p "$MACOS_LOCAL_PATH"
  docker run \
    --rm=true \
    -it \
    --privileged \
    --device /dev/kvm \
    --stop-timeout 120 \
    -p 8006:8006 \
    -e "VERSION=${MACOS_DISTRO}" \
    -e "DISK_SIZE=64G" \
    -e "RAM_SIZE=4G" \
    -e "CPU_CORES=2" \
    -v "${MACOS_LOCAL_PATH}:${MACOS_CONTAINER_PATH}" \
    dockurr/macos
}

# Delete a current macOS machine using docker
# $1: the macos distro name ( big-sur, mojave, monterey, ventura, ... ). See https://github.com/dockur/macos?tab=readme-ov-file#how-do-i-select-the-macos-version
docker_rm_macos() {
  MACOS_DISTRO="${1:-tahoe}"
  MACOS_LOCAL_PATH="$(realpath ~/.local)/dockur-macos/${MACOS_DISTRO}"

  if [ -d "${MACOS_LOCAL_PATH}" ]; then
    echo "Image for macOS ${MACOS_DISTRO} found. Removing..."
    sudo rm -rf "${MACOS_LOCAL_PATH}"
  fi
}

### ====================================================================== ###

# Run a Linux machine using docker
# $1: the linux distro name ( arch, ubuntu, etc. ) See https://github.com/qemus/qemu#how-do-i-select-the-operating-system
docker_run_linux() {
  LINUX_DISTRO="${1:-arch}"
  LINUX_LOCAL_PATH="$(realpath ~/.local)/qemux-qemu/${LINUX_DISTRO}"
  LINUX_CONTAINER_PATH="/storage"

  xdg-open http://localhost:8006/

  mkdir -p "$LINUX_LOCAL_PATH"
  docker run \
    --rm=true \
    -it \
    --privileged \
    --device=/dev/kvm \
    --device=/dev/net/tun \
    --stop-timeout 120 \
    -p 8006:8006 \
    -p 2222:22 \
    -e "BOOT=${LINUX_DISTRO}" \
    -e "NETWORK=passt" \
    -v "${LINUX_LOCAL_PATH}:${LINUX_CONTAINER_PATH}" \
    qemux/qemu
}

# Delete a current linux machine using docker
# $1: the linux distro name ( arch, ubuntu, etc. ) See https://github.com/qemus/qemu#how-do-i-select-the-operating-system
docker_rm_linux() {
  LINUX_DISTRO="${1:-arch}"
  LINUX_LOCAL_PATH="$(realpath ~/.local)/qemux-qemu/${LINUX_DISTRO}"

  if [ -d "${LINUX_LOCAL_PATH}" ]; then
    echo "Image for linux ${LINUX_DISTRO} found. Removing..."
    sudo rm -rf "${LINUX_LOCAL_PATH}"
  fi
}

### ====================================================================== ###

docker_run_android() {
  echo "See https://github.com/Shmayro/dockerify-android/tree/main?tab=readme-ov-file#%EF%B8%8F-environment-variables for more configurations."

  ANDROID_DISTRO="${1:-emulator_14.0}"
  ANDROID_LOCAL_PATH="$(realpath ~/.local)/dockerify-android/${ANDROID_DISTRO}"

  mkdir -p "$ANDROID_LOCAL_PATH"  
  docker run \
    --rm=true \
    -itd \
    --privileged \
    --device /dev/kvm \
    -e "RAM_SIZE=4096" \
    -e "ROOT_SETUP=0" \
    -e "GAPPS_SETUP=0" \
    -p 5555:5555 \
    -v "${ANDROID_LOCAL_PATH}/data:/data" \
    -v "${ANDROID_LOCAL_PATH}/extras:/extras" \
    shmayro/dockerify-android:latest

  scrcpy -S localhost:5555
}

docker_rm_android() {
  ANDROID_DISTRO="${1:-emulator_14.0}"
  ANDROID_LOCAL_PATH="$(realpath ~/.local)/dockerify-android/${ANDROID_DISTRO}"

  if [ -d "${ANDROID_LOCAL_PATH}" ]; then
    echo "Image for android ${ANDROID_DISTRO} found. Removing..."
    sudo rm -rf "${ANDROID_LOCAL_PATH}"
  fi
}

## --- macOS ---

if [[ "$OSTYPE" == "darwin"* ]]; then
  # keychain env vars helpers
  source "${HOME}/.keychain-environment-variables.sh"

  # brew
  if command -v brew &>/dev/null; then
    # Brew
    export HOMEBREW_REQUIRE_TAP_TRUST=1
    eval "$(brew shellenv)"

    # Brew GNU tools
    export PATH="$(brew --prefix)/opt/make/libexec/gnubin:$PATH"

    # Brew Python
    export PATH="$(brew --prefix python)/libexec/bin:$PATH"

    # Node.js
    BREW_NODE_PREFIX=$(brew --prefix "$(brew list | grep -E '^node(@[0-9]+)?$' | tail -1)" 2>/dev/null)
    export PATH="${BREW_NODE_PREFIX}/bin:$PATH"

    # Google Cloud
    source "$(brew --prefix)/Caskroom/gcloud-cli/latest/google-cloud-sdk/path.zsh.inc"
  fi

  # LM Studio CLI (lms)
  export PATH="${HOME}/.lmstudio/bin:$PATH"
fi

# Enable to dump measurings
# zprof
