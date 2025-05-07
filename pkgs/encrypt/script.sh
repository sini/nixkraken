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
  echo "Encrypt GitKraken secret file."
  echo
  echo -e "${bold}Usage:${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} DATA [--help]"
  echo
  echo -e "${bold}Arguments:${no_color}"
  cat <<EOF | column -ts '|'
    DATA|JSON data to encrypt
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
    die "config file is not readable: ${config_file}"
  fi
}

# Ensure valid JSON data is provided
# Arguments:
#   $1 - JSON object (string)
ensure_json() {
  local data="${1:-}"

  if [ -z "${data}" ]; then
    error "${script_name} requires data to encrypt"
    usage
    die
  fi

  # Validate JSON using jq
  if ! jq '.' <<<"${data}" >/dev/null 2>&1; then
    die "invalid JSON data"
  fi
}

# Encrypt secret data (adapted from original GitKraken's prettified main.bundle.js, using unix tools)
# Arguments:
#   $1 - JSON object (string)
encrypt_secret() {
  local data="${1:-}"
  local app_id

  # Extract appId from config file
  app_id=$(jq -r '.appId' "${config_file}") || die "failed to read appId from config file"

  if [ -z "${app_id}" ] || [ "${app_id}" = "null" ]; then
    die "invalid or empty appId in config file"
  fi

  # Encrypt JSON using OpenSSL (AES-256-CBC, MD5 key derivation, no salt)
  jq -jr '.' <<<"${data}" | openssl enc -aes-256-cbc -md md5 -e -k "${app_id}" -nosalt 2>/dev/null
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
  ensure_json "$@"
  encrypt_secret "$@"
}

# Handle interruptions gracefully
trap 'echo "Script interrupted" >&2; exit 1' INT TERM

main "$@"
