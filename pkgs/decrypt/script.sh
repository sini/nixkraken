#!/usr/bin/env bash

set -euo pipefail

####################
# GLOBAL VARIABLES #
####################

script_name="$(basename "$0")"
config_file=$HOME/.gitkraken/config

# Color codes
no_color="\e[0m"
bold="\e[1m"
dim="\e[2m"
red="\e[31m"

#####################
# UTILITY FUNCTIONS #
#####################

# Print error message to stderr
error() {
  >&2 echo -e " ${red}×${no_color} $*"
}

# Exit script with optional error message
die() {
  if [ "$#" -gt 0 ]; then
    error "$*"
  fi

  exit 1
}

# Print usage
usage() {
  echo
  echo "Decrypt GitKraken secret file."
  echo
  echo -e "${bold}Usage:${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} SECRET_FILE [--help]"
  echo
  echo -e "${bold}Arguments:${no_color}"
  cat <<EOF | column -ts '|'
    SECRET_FILE|Path to the secret file to decrypt
    |Example: \$HOME/.gitkraken/secFile
EOF
  echo
  echo -e "${bold}Options:${no_color}"
  cat <<EOF | column -ts '|'
    -h, --help|Show this help message
EOF
  echo
}

########################
# CORE LOGIC FUNCTIONS #
########################

# Ensure the config file exists and is readable
ensure_config() {
  if ! [ -f "${config_file}" ]; then
    die "config file not found - is GitKraken installed?"
  fi

  if ! [ -r "${config_file}" ]; then
    die "config file is not readable"
  fi
}

# Ensure the secret file is provided, exists, is readable, and is not empty
# Arguments:
#   $1 - secret file path (string)
ensure_secret() {
  local secret_file="${1:-}"

  if [ -z "${secret_file}" ]; then
    error "${script_name} requires a file to decrypt"
    usage
    die
  elif ! [ -f "${secret_file}" ]; then
    die "secret file does not exist: ${secret_file}"
  elif ! [ -r "${secret_file}" ]; then
    die "secret file is not readable: ${secret_file}"
  elif ! [ -s "${secret_file}" ]; then
    die "secret file is empty: ${secret_file}"
  fi
}

# Decrypt secret data (adapted from original GitKraken's prettified main.bundle.js, using unix tools)
# Arguments:
#   $1 - secret file path (string)
decrypt_secret() {
  local secret_file="${1:-}"
  local app_id
  local data

  # Extract appId from config file
  app_id=$(jq -r '.appId' "${config_file}") || die "failed to read appId from config file"

  if [ -z "${app_id}" ] || [ "${app_id}" = "null" ]; then
    die "invalid or empty appId in config file"
  fi

  # Decrypt the secret file using OpenSSL (AES-256-CBC, MD5 key derivation, no salt)
  data=$(openssl enc -aes-256-cbc -md md5 -d -k "${app_id}" -nosalt -in "${secret_file}" 2>/dev/null)

  # Validate that the decrypted data is valid JSON
  if ! jq '.' <<<"${data}" >/dev/null 2>&1; then
    die "decrypted data is not valid JSON"
  fi

  echo "${data}"
}

########
# MAIN #
########

main() {
  # Fix arguments ordering to put all options (starting with -) first
  # This is required so that getopts processes options before script arguments
  local opts=()
  local nonopts=()

  for arg in "$@"; do
    if [[ "${arg}" == -* ]]; then
      opts+=("${arg}")
    else
      nonopts+=("${arg}")
    fi
  done

  set -- "${opts[@]}" "${nonopts[@]}"

  # Parse command-line options
  while getopts 'h-:' OPT; do
    # Support long options (https://stackoverflow.com/a/28466267/519360)
    if [ "${OPT}" = "-" ]; then # Long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}" # Extract long option name
      # shellcheck disable=SC2295
      OPTARG="${OPTARG#$OPT}" # Extract long option argument (may be empty)
      OPTARG="${OPTARG#=}" # If long option argument, remove assigning `=`
    fi

    # Handle flags
    case "${OPT}" in
      h | help )
        usage
        exit 0
        ;;
      ??* ) # bad long option
        error "$0: illegal option -- ${OPT}"
        usage
        die
        ;;
      ? ) # bad short option (error reported via getopts)
        usage
        die
        ;;
    esac
  done

  # Shift processed options
  shift $((OPTIND - 1))

  ensure_config
  ensure_secret "$@"
  decrypt_secret "$@"
}

# Handle interruptions gracefully
trap 'echo "Script interrupted" >&2; exit 1' INT TERM

main "$@"
