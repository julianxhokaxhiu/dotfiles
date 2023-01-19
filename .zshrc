# ~/.zshrc

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

# Spaceship Options
###################
SPACESHIP_PROMPT_ASYNC=false
SPACESHIP_KUBECTL_SHOW=true

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

# Arch: Pacman Helper
#####################

# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Removing_unused_packages_.28orphans.29
alias pacman_clean_orphans="sudo pacman -Rns $(pacman -Qtdq | tr '\n' ' ' | xargs)"
# https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Database_access_speeds + AUR via pacaur
alias pacman_clean_cache="yay -Sc"

# asdf-vm
#########
source /opt/asdf-vm/asdf.sh

# Kubernetes
############
# KubeCtl
source <(kubectl completion zsh)
# KubeAdm
source <(kubeadm completion zsh)
# Helm Package Manager
source <(helm completion zsh)
# Kind
source <(kind completion zsh)
# Tilt
source <(tilt completion zsh)
# ArgoCD
source <(argocd completion zsh)
# Krew
export PATH="${PATH}:${HOME}/.krew/bin"

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
  #COUNTRY=`curl -s -L "http://ip-api.com/line/?fields=countryCode"`
  COUNTRY=all

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

# https://github.com/BlackReloaded/wsl2-ssh-pageant
if [ ! -z "${WSL_DISTRO_NAME}" ]; then
  wsl2_ssh_pageant_bin="$HOME/.ssh/wsl2-ssh-pageant.exe"

  if [ ! -f "$wsl2_ssh_pageant_bin" ]; then
    echo -e ">> WSL2 Detected! Installing wsl2-ssh-pageant and required dependencies"
    # check if socat and ss are installed too
    ubm_ensure_archlinux_package "socat"
    ubm_ensure_archlinux_package "ss"
    # install wsl2 ssh pageant daemon
    wget -O "$wsl2_ssh_pageant_bin" "https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe"
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

# Install/Update wsl-distrod
# wsl_distrod() {
#   set -e
#   pushd /tmp

#   curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
#   chmod +x install.sh
#   sudo ./install.sh $1
#   rm install.sh
#   popd

#   if [ "$1" == "install" ]; then
#     sudo /opt/distrod/bin/distrod enable --start-on-windows-boot
#   fi

#   set +e
# }

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
# $1: the macos distro name ( big-sur, mojave, monterey, ventura, ... ). See https://hub.docker.com/r/sickcodes/docker-osx/tags
docker_run_macos() {
  echo "If you're having issues, make sure you follow this setup first: https://github.com/sickcodes/Docker-OSX#initial-setup"
  echo "Once you're done installing macOS, you can make the VM faster using some tricks you can find here: https://github.com/sickcodes/osx-optimizer"

  MACOS_DISTRO="${1:-ventura}"
  MACOS_IMAGE_NAME="mac_hdd_ng.img"
  MACOS_LOCAL_PATH="$(realpath ~/.local)/docker-osx/${MACOS_DISTRO}"
  MACOS_CONTAINER_PATH="/home/arch/OSX-KVM/persistent"

  mkdir -p "$MACOS_LOCAL_PATH"
  docker pull -q "sickcodes/docker-osx:${MACOS_DISTRO}"

  # If a persistent disk image does not exist copy the initial one from the container
  if [ ! -f "${MACOS_LOCAL_PATH}/${MACOS_IMAGE_NAME}" ]; then
    id=$(docker create sickcodes/docker-osx:${MACOS_DISTRO})
    docker cp "$id:/home/arch/OSX-KVM/${MACOS_IMAGE_NAME}" "${MACOS_LOCAL_PATH}/${MACOS_IMAGE_NAME}"
    docker rm -v $id >/dev/null 2>&1
  fi

  if [ ! -z "${WSL_DISTRO_NAME}" ]; then
    # Run OSX on WSL2
    docker run \
      --rm=true \
      -it \
      --device /dev/kvm \
      -p 50922:10022 \
      -e "CPU=max" \
      -e "BOOT_ARGS=+vmx" \
      -e "DISPLAY=${DISPLAY:-:0.0}" \
      -e "GENERATE_UNIQUE=true" \
      -e "IMAGE_PATH=${MACOS_CONTAINER_PATH}/${MACOS_IMAGE_NAME}" \
      -v "/mnt/wslg/.X11-unix:/tmp/.X11-unix" \
      -v "${MACOS_LOCAL_PATH}:${MACOS_CONTAINER_PATH}" \
      sickcodes/docker-osx:${MACOS_DISTRO}
  else
    # Run OSX on Linux w/Wayland
    docker run \
      --rm=true \
      -it \
      --privileged \
      --device /dev/kvm \
      -p 50922:10022 \
      -e "CPU=max" \
      -e "BOOT_ARGS=+vmx" \
      -e "CLUTTER_BACKEND=wayland" \
      -e "DISPLAY=${DISPLAY:-:0}" \
      -e "GENERATE_UNIQUE=true" \
      -e "GDK_BACKEND=wayland" \
      -e "IMAGE_PATH=${MACOS_CONTAINER_PATH}/${MACOS_IMAGE_NAME}" \
      -e "QT_QPA_PLATFORM=wayland" \
      -e "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}" \
      -e "XDG_RUNTIME_DIR=/tmp" \
      -v "${MACOS_LOCAL_PATH}:${MACOS_CONTAINER_PATH}" \
      -v "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/${WAYLAND_DISPLAY}" \
      sickcodes/docker-osx:${MACOS_DISTRO}
  fi
}

# Delete a current macOS machine using docker
# $1: the macos distro name ( big-sur, mojave, monterey, ventura, ... ). See https://hub.docker.com/r/sickcodes/docker-osx/tags
docker_rm_macos() {
  MACOS_DISTRO="${1:-ventura}"
  MACOS_IMAGE_NAME="mac_hdd_ng.img"
  MACOS_LOCAL_PATH="$(realpath ~/.local)/docker-osx/${MACOS_DISTRO}"

  if [ -f "${MACOS_LOCAL_PATH}/${MACOS_IMAGE_NAME}" ]; then
    echo "Image for macOS ${MACOS_DISTRO} found. Removing..."
    rm -f "${MACOS_LOCAL_PATH}/${MACOS_IMAGE_NAME}"
  fi
}

# Remove macOS docker images
# $1: the macos distro name ( big-sur, mojave, monterey, ventura, ... ). See https://hub.docker.com/r/sickcodes/docker-osx/tags
docker_clean_macos() {
  MACOS_DISTRO="${1:-ventura}"

  docker rmi sickcodes/docker-osx:${MACOS_DISTRO}
}
