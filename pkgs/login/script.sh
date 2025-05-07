#!/usr/bin/env bash

set -euo pipefail

####################
# GLOBAL VARIABLES #
####################

script_name="$(basename "$0")"
config_dir=${HOME}/.gitkraken
config_file="${config_dir}/config"
tmp_config="${config_file}.tmp"

# Available providers mapping
declare -ar providers=(
  "github"
  "gitlab"
  "bitbucket"
  "azure"
  "google"
)

# Color codes
no_color="\e[0m"
bold="\e[1m"
dim="\e[2m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"

#####################
# UTILITY FUNCTIONS #
#####################

# Print error message to stderr
error() {
  >&2 echo -e " ${red}×${no_color} $*"
}

# Print warning message to stderr
warn() {
  >&2 echo -e " ${yellow}⚠${no_color} $*"
}

# Print debug message to stderr if debug is enabled
debug() {
  if [ -n "${debug_enabled}" ]; then
    >&2 echo -e " ${dim}▶ $*${no_color}"
  fi
}

# Print success message to stdout
success() {
  echo -e " ${green}✓${no_color} $*"
}

# Exit script with optional error message
die() {
  if [ "$#" -gt 0 ]; then
    error "$*"
  fi

  exit 1
}

# Print error similar to getopts and exit if an option is missing its required argument (used for long options)
needs_arg() {
  if [ -z "${OPTARG:-}" ]; then
    >&2 echo "$0: option requires an argument -- ${OPT}"
    usage
    die
  fi
}

# Print usage
usage() {
  echo
  echo "Login to your GitKraken account from the command line."
  echo
  echo -e "${bold}Usage:${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} --provider=<provider> [--profile=<profile-id>] [--debug]"
  echo
  echo -e "${bold}Options:${no_color}"
  cat <<EOF | column -ts '|'
    -P, --profile|Profile ID to use
    |Defaults to default profile
    -p, --provider|Provider to login with
    |Available providers: $(echo "${providers[@]}" | tr ' ' ',')
    --debug|Output debug information
    -h, --help|Show this help message
EOF
  echo
}

########################
# CORE LOGIC FUNCTIONS #
########################

# Ensure a valid provider is specified and supported
ensure_provider() {
  debug "checking provider"

  if [ -z "${provider}" ]; then
    error "${script_name} requires a provider"
    usage
    die
  fi

  # Validate provider against supported list
  if ! [[ "${provider}" =~ ^($(printf "%s|" "${providers[@]}"))$ ]]; then
    error "provider '${provider}' is invalid"

    echo
    echo "Available providers: $(echo "${providers[@]}" | tr ' ' ',')"
    die
  fi

  debug "using provider: '${provider}'"
}

# Ensure a profile ID is set, or use the default profile ID
ensure_profile() {
  if [ -z "${profile}" ]; then
    warn "no profile ID set, using default profile ID"
    profile="d6e5a8ca26e14325a4275fc33b17e16f"
  fi

  debug "using profile: '${profile}'"
}

# Ensure the main config file exists and is readable, and the profile directory exists
ensure_config() {
  debug "checking config file"

  if ! [ -f "${config_file}" ]; then
    die "config file not found - is GitKraken installed?"
  fi

  if ! [ -r "${config_file}" ]; then
    die "config file is not readable"
  fi

  debug "config file found"

  profile_dir="${config_dir}/profiles/${profile}/${provider}"

  # Create profile directory if it doesn't exist
  if ! [ -d "${profile_dir}" ]; then
    mkdir -p "${profile_dir}" || die "failed to create profile directory: ${profile_dir}"
    debug "created profile directory: ${profile_dir}"
  else
    debug "using existing profile directory: ${profile_dir}"
  fi
}

# Open the default web browser to the GitKraken OAuth login page for the selected provider
open_browser() {
  local url="https://api.gitkraken.com/oauth/${provider}/login?action=login&in_app=true"

  echo -e "${bold}Opening web browser to login to GitKraken account...${no_color}"
  echo -e "${dim}If browser doesn't open automatically, use this URL: ${url}${no_color}"
  xdg-open "${url}" &>/dev/null || warn "failed to open browser automatically, please open the URL manually"
}

# Prompt the user to enter the OAuth access token, validate it, and store it in oauth_token
set_token() {
  local token=""
  local max_attempts=3
  local attempt=1

  while [ "${attempt}" -le "${max_attempts}" ]; do
    echo "Enter access token:"
    read -rsp "> " token
    echo

    if [ -z "${token}" ]; then
      error "access token cannot be empty"
    elif ! base64 -d <<<"${token}" >/dev/null 2>&1; then
      error "invalid access token format (expected base64 encoded string)"
    else
      oauth_token="${token}"
      return 0
    fi

    ((attempt++))
  done

  die "maximum token entry attempts exceeded"
}

# Extract API and provider tokens from the base64-encoded, zlib-compressed access token
# api_token is for global config
# provider_token is for profile config
extract_token() {
  debug "extracting tokens from access token"

  if [ -z "${oauth_token}" ]; then
    die "missing access token"
  fi

  debug "expanding zlib compressed access token"
  local expanded_token

  if ! expanded_token=$(base64 -d <(echo "${oauth_token}") | pigz -d 2>/dev/null); then
    die "failed to expand access token"
  fi

  debug "extracting API and provider tokens from expanded access token"
  api_token=$(jq -r '.accessToken // empty' <<<"${expanded_token}")
  provider_token=$(jq -r '.providerToken.access_token // empty' <<<"${expanded_token}")

  if [ -z "${api_token}" ]; then
    die "failed to extract API token"
  fi

  if [ -z "${provider_token}" ]; then
    die "failed to extract provider token"
  fi

  debug "tokens successfully extracted"
}

# Merge two JSON objects using jq
# Arguments:
#   $1 - current JSON object (string)
#   $2 - update JSON object (string)
merge_json() {
  local current=${1:-"{}"}
  local update=${2:-"{}"}

  if ! jq -s '.[0] * .[1]' <(echo "${current}") <(echo "${update}") 2>/dev/null; then
    die "failed to merge JSON data"
  fi
}

# Encrypt the API token and store it in the global secret file
encrypt_api_token() {
  local secret_file="${config_dir}/secFile"
  local secret_content="{}"
  local update='{"GitKraken":{"api-accessToken":"'"${api_token}"'"}}'

  debug "encrypting API token to ${secret_file}"

  if [ -f "${secret_file}" ]; then
    debug "decrypting existing secret file"

    if ! secret_content=$(gk-decrypt "${secret_file}"); then
      die "failed to decrypt existing secret file"
    fi
  fi

  debug "merging existing secret data with new API token"
  local merged_content

  if ! merged_content=$(merge_json "${secret_content}" "${update}"); then
    die "failed to save new API token"
  fi

  debug "saving encrypted file in place"
  if ! gk-encrypt "${merged_content}" > "${secret_file}"; then
    die "failed to encrypt API token"
  fi
}

# Encrypt the provider token and store it in the profile-specific secret file
encrypt_provider_token() {
  local provider_secret_file="${profile_dir}/secFile"
  debug "encrypting provider token to ${provider_secret_file}"

  if ! gk-encrypt '{"GitKraken":{"accessToken":"'"${provider_token}"'"}}' > "${provider_secret_file}"; then
    die "failed to encrypt provider token"
  fi
}

# Update the main config file with registration data
update_config() {
  debug "updating config file with registration data"

  local current
  local update

  if ! current=$(cat "${config_file}"); then
    die "failed to read config file"
  fi

  update='{"registration":{"status":"activated","loginType":"'"${provider}"'","date":"'$(date -u +%Y-%m-%dT%H:%M:%S)'.'$(date -u +%N | head -c3)'Z"},"userMilestones":{"firstLoginRegister":true}}'

  if ! merge_json "${current}" "${update}" > "${tmp_config}"; then
    die "failed to merge config data"
  fi

  mv "${tmp_config}" "${config_file}"
}

# Remove temporary files on exit
cleanup() {
  rm -f "${tmp_config}" 2>/dev/null || true
}

########
# MAIN #
########

main() {
  # Initialize flag variables
  profile=""
  provider=""
  debug_enabled=""

  # Initialize variables used by multiple functions
  profile_dir=""
  oauth_token=""
  api_token=""
  provider_token=""

  # Parse command-line options
  while getopts 'hp:P:-:' OPT; do
    # Support for long options (https://stackoverflow.com/a/28466267/519360)
    if [ "${OPT}" = "-" ]; then # Long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}" # Extract long option name
      # shellcheck disable=SC2295
      OPTARG="${OPTARG#$OPT}" # Extract long option argument (may be empty)
      OPTARG="${OPTARG#=}" # If long option argument, remove assigning `=`
    fi

    # Handle flags
    case "${OPT}" in
      p | provider )
        needs_arg
        provider="${OPTARG}"
        ;;
      P | profile )
        needs_arg
        profile="${OPTARG}"
        ;;
      debug )
        debug_enabled="true"
        ;;
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

  debug "starting GitKraken login process"
  debug "using ${config_dir} as root directory"

  ensure_provider
  ensure_profile
  ensure_config
  open_browser
  set_token
  extract_token
  encrypt_api_token
  encrypt_provider_token
  update_config

  success "GitKraken authentication successful!"
  echo "Please restart or start GitKraken for changes to take effect."
}

# Trap cleanup on exit and handle interruptions gracefully
trap cleanup EXIT
trap 'echo "Script interrupted" >&2; exit 1' INT TERM

main "$@"
