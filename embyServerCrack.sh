#!/bin/sh

VER=1.0
USERNAME="qcgzxw"
PROJECT_NAME="emby-server-crack"
BRANCH="main"
GITHUB_CDN="https://cdn.jsdelivr.net/gh"
CRACK_FILE_DIR="${GITHUB_CDN}/${USERNAME}/${PROJECT_NAME}@${BRANCH}/crack"
CRACK_CONFIG=".config"

EMBY_VERSION_FILE="lastversion.txt"
DOCKER_EMBY_CONFIG_PATH="/config"
DOCKER_EMBY_SYSTEM_PATH="/system"
LINUX_EMBY_CONFIG_PATH="/var/lib/emby"
LINUX_EMBY_SYSTEM_PATH="/opt/emby-server/system"
PLATFORM_DOCKER="docker"
PLATFORM_LINUX="linux"


emby_platform=""
emby_version=""
emby_system_path=""
emby_config_path=""

crack_config_path=""

__green() {
  printf '\33[1;32m%b\33[0m' "$1"
    return
}

__red() {
  printf '\33[1;31m%b\33[0m' "$1"
    return
}
error() {
  __red "$1\n"
  exit
}
success() {
  __green "$1\n"
}

checkEmby() {
  [ "$(whoami)" != "root" ] && error "You must be root to run this script"
  if [ -d "$DOCKER_EMBY_CONFIG_PATH" ]; then
      emby_platform="${PLATFORM_DOCKER}"
      emby_config_path="${DOCKER_EMBY_CONFIG_PATH}"
      emby_system_path="${DOCKER_EMBY_SYSTEM_PATH}"

  elif [ -d "$LINUX_EMBY_CONFIG_PATH" ]; then
      emby_platform="${PLATFORM_LINUX}"
      emby_config_path="${LINUX_EMBY_CONFIG_PATH}"
      emby_system_path="${LINUX_EMBY_SYSTEM_PATH}"
  fi

  lastVersionFilePath="${emby_config_path}/data/${EMBY_VERSION_FILE}"
  if [ -f "$lastVersionFilePath" ]; then
    emby_version=$(cat "${lastVersionFilePath}")
  fi

  if [ "$emby_version" = "" ] || [ "$emby_config_path" = "" ] || [ "$emby_system_path" = "" ] || [ ! -d "$emby_config_path" ] || [ ! -d "$emby_system_path" ]; then
    error "failed."
  fi
}
getCrackConfig() {
  if [ "$emby_version" = "" ]; then
    read -r -p 'please input your emby version manually: ' input
    if [ "$input" = "" ]; then
      error "Unknown version"
    else
      emby_version="$input"
    fi
  fi
  crack_config_url="${CRACK_FILE_DIR}/${emby_version}/${CRACK_CONFIG}"
  crack_config_path="$(mktemp)"
  wget --no-check-certificate -q "${crack_config_url}" -O "${crack_config_path}";
  if [ "$?" != "0" ] || [ ! -f "$crack_config_path" ]; then
    error "Config download failed"
  fi
}
downloadCrackFile() {
  dirname=${1%/*}
  if [ ! -d "$dirname" ]; then
    mkdir "$dirname"
  fi
  success "File ${1} is downloading..."
  wget --no-check-certificate -q -O "$1" "$2"
  if [ "$?" != "0" ] || [ ! -f "$1" ]; then
    error "Crack files download failed"
  fi
  if [ "$3" != "" ]; then
    chmod "$3" "$1"
  fi
}
crack() {
  clear
  checkEmby
  getCrackConfig
  success "Emby info:"
  success "    platform: ${emby_platform}"
  success "    version: ${emby_version}"
  success "    system path: ${emby_system_path}"
  success "    config path: ${emby_config_path}"
  success
  success "File downloading..."
  while read -r line || [ -n "$line" ];
  do
    perm=""
    eval "$(echo "$line" | awk '{ printf("path=%s;url=%s;perm=%s",$1,$2,$3) }')"
    path=$(echo "$path" | sed "s|__CONFIG__|${emby_config_path}|g;s|__SYSTEM__|${emby_system_path}|g")
    url="${CRACK_FILE_DIR}/${emby_version}/${url}"
    downloadCrackFile "$path" "$url" "$perm"
  done < "$crack_config_path"
  success
  success 'Congratulations, your emby server has been cracked.'
  success
  success 'You may restart your emby server and check if is cracked.'
}

crack
