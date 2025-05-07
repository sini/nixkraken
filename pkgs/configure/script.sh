#!/usr/bin/env bash

set -euo pipefail

####################
# GLOBAL VARIABLES #
####################

script_name="$(basename "$0")"
config_dir="$HOME/.gitkraken"
config_file="${config_dir}/config"

# Color codes
no_color="\e[0m"
bold="\e[1m"
dim="\e[2m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"

#####################
# UTILITY FUNCTIONS #
#####################

# Log a message, respecting dry-run and verbose modes (for Home Manager integration)
_log() {
  local prefix=""

  if [ -n "${DRY_RUN:-}" ]; then
    prefix="[dry-run]"
  fi

  if [ -n "${DRY_RUN:-}" ] || [ -n "${VERBOSE:-}" ]; then
    echo -e "${bold}${prefix}${no_color}$*"
  fi
}

# Print error message to stderr (always shown)
error() {
  >&2 echo -e " ${red}×${no_color}" "$*"
}

# Print warning message to stderr (shown in dry-run/verbose)
warn() {
  >&2 _log " ${yellow}⚠${no_color} $*"
}

# Print information message to stdout (shown in dry-run/verbose)
info() {
  _log " ${blue}i${no_color} $*"
}

# Print success message to stdout (never shown in dry-run)
success() {
  if [ -z "${DRY_RUN:-}" ]; then
    _log " ${green}✓${no_color} $*"
  fi
}

# Execute a command only if not in dry-run mode
_do() {
  if [ -z "${DRY_RUN:-}" ]; then
    "$@"
  fi
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
  echo "GitKraken configuration generator."
  echo
  echo -e "${bold}Usage:${no_color}"
  echo -e "    ${dim}Configure application${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} --config='<JSON>' [--dry-run] [--verbose] [--help]"
  echo
  echo -e "    ${dim}Configure profile${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} --config='<JSON>' --profile=<id> [--git-binary=true|false] [--hm-profile=<directory>] [--dry-run] [--verbose] [--help]"
  echo
  echo -e "${bold}Options:${no_color}"
  cat <<EOF | column -ts '|'
    -c, --config|Configuration content in JSON format
    -p, --profile|Operate on given profile configuration
    --git-binary|Use git executable
    |Only with --profile
    --hm-profile|Path to Home Manager profile
    |Setting this option will add Home Manager profile directory to the git executable search path
    |Only with --profile and --git-binary
    --dry-run|Only print what would be done
    -v, --verbose|Enable verbose output
    -h, --help|Show this help message
EOF
  echo
}

########################
# CORE LOGIC FUNCTIONS #
########################

# Validate that the provided string is valid JSON using jq
# Arguments:
#   $1 - JSON object (string)
validate_json() {
  local json="${1:-}"

  if ! jq '.' <<<"${json}" >/dev/null 2>&1; then
    die "invalid JSON format"
  fi
}

# Generate a unique appId based on the MAC address of the first active network interface
#
# Adapted from original GitKraken's prettified main.bundle.js (comments added):
# // Blacklisted app IDs
# const Ur = ["8149453d12fde3c987f5ceb011360abe56307d17", "a76a6cbfb93cbb6daa4c4836544564fb777a0803", "4433e1caaca0b97ba94ef3e0772e5931f792fa9b", "b14e824ad9cd8a3e95493d48e6132ecce40e0e47"],
#   // Function to generate app ID if not already set
#   ensureAppId = (I, re) => ({
#     saga: function* ensureAppIdSaga() {
#       // Do not generate an app ID if it already exist in configuration
#       if (yield (0, ge.call)([I, I.getSetting], "appId")) return;
#
#       // Create hexadecimal digest of SHA1 hash of 'I' argument using Node.js Crypto API
#       const getSha1 = (I) => (0, le.createHash)("sha1").update(I, "utf8").digest("hex");
#
#       // Flag '--random-app-id' was given on GitKraken launch
#       if (re) {
#         // Generate random UUIDv4
#         const re = yield (0, ge.call)(Ve.v4);
#
#         // Set app ID to hex digest of generated UUID
#         yield (0, ge.call)([I, I.setSetting], "appId", getSha1(re));
#       } else
#         try {
#           // ge.call is likely redux-saga call method
#           // pe.default is the getmac npm module
#           const re = getSha1(yield (0, ge.call)(pe.default));
#
#           // Exclude known bad app IDs
#           if (Ur.includes(re)) throw new Error("Generated Known Bad AppId");
#
#           // Set app ID to hex digest of first proper MAC address
#           yield (0, ge.call)([I, I.setSetting], "appId", re);
#         } catch {
#           // If blacklisted app ID was generated, fallback to app ID using random UUID
#           const re = yield (0, ge.call)(Ve.v4);
#           yield (0, ge.call)([I, I.setSetting], "appId", getSha1(re));
#         }
#
#       // Sentry stuff (irrelevant)
#       const ne = yield (0, ge.call)([I, I.getSetting], "appId");
#       yield (0, ge.call)([ve, ve.setTag], "appId", ne);
#     },
#   });
gen_appid() {
  local blacklisted_appids=(
    "8149453d12fde3c987f5ceb011360abe56307d17"
    "a76a6cbfb93cbb6daa4c4836544564fb777a0803"
    "4433e1caaca0b97ba94ef3e0772e5931f792fa9b"
    "b14e824ad9cd8a3e95493d48e6132ecce40e0e47"
  )
  local generated_appid

  get_sha1() {
    openssl sha1 -hex -r <<<"$1" | awk '{print $1}'
  }

  get_mac() {
    ip -o link show | grep -Pom1 '(?<=state UP).*(?<=ether )\K[0-9a-f:]+'
  }

  generated_appid=$(get_sha1 "$(get_mac)")

  for id in "${blacklisted_appids[@]}"; do
    if [ "${generated_appid}" = "${id}" ]; then
      generated_appid=$(get_sha1 "$(uuidgen)")
      break
    fi
  done

  echo "${generated_appid}"
}

# Detect git binary location, with fallback if not found
detect_git() {
  local git_paths=()

  if [ -n "${hm_profile_directory}" ]; then
    git_paths+=("${hm_profile_directory}/bin/git")
  fi

  git_paths+=(
    "/run/current-system/sw/bin/git"
    "$(command -v git 2>/dev/null || true)"
  )

  for path in "${git_paths[@]}"; do
    if [ -x "${path}" ]; then
      echo "${path}"
      return 0
    fi
  done

  warn "failed to detect git binary, falling back to bundled git"
  echo "\$packaged"
}

# Create or merge JSON file with given content
# Arguments:
#   $1 - target file path (string)
#   $2 - update JSON content (string)
create_or_merge_json() {
  local target_file=${1}
  local update=${2:-"{}"}
  local current="{}"
  local tmp_file

  # Validate input JSON
  validate_json "${update}"

  # Create temporary file
  tmp_file=$(mktemp)
  # shellcheck disable=SC2064
  trap "rm -f ${tmp_file}" EXIT

  # Read existing content if file exists and is not empty
  if [ -s "${target_file}" ]; then
    if ! current="$(cat "${target_file}")"; then
      die "failed to read existing configuration file"
    fi
    validate_json "${current}"
  fi

  # Merge JSON
  if ! jq -s '.[0] * .[1]' <(echo "${current}") <(echo "${update}") > "${tmp_file}"; then
    die "failed to merge JSON data"
  fi

  # Move temporary file to target
  if ! mv "${tmp_file}" "${target_file}"; then
    die "failed to update configuration file"
  fi
}

########
# MAIN #
########

main() {
  config_content=""
  hm_profile_directory=""
  profile=""
  target="app"
  use_git_exec=""

  # Parse command-line options
  while getopts 'c:hp:v-:' OPT; do
    # Support long options (https://stackoverflow.com/a/28466267/519360)
    if [ "${OPT}" = "-" ]; then # Long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}" # Extract long option name
      # shellcheck disable=SC2295
      OPTARG="${OPTARG#$OPT}" # Extract long option argument (may be empty)
      OPTARG="${OPTARG#=}" # If long option argument, remove assigning `=`
    fi

    # Handle flags
    case "${OPT}" in
      c | config )
        needs_arg
        validate_json "${OPTARG}"
        config_content="${OPTARG}"
        ;;
      p | profile )
        needs_arg
        target="profile"
        profile="${OPTARG}"
        ;;
      "git-binary" )
        needs_arg
        [ "${OPTARG}" = "true" ] && use_git_exec=1
        ;;
      "hm-profile" )
        needs_arg
        hm_profile_directory="${OPTARG}"
        ;;
      "dry-run" )
        DRY_RUN=1
        ;;
      v | verbose )
        VERBOSE=1
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

  info "starting GitKraken configuration generation"

  if [ -z "${config_content}" ]; then
    error "configuration is missing"
    usage
    die
  else
    info "configuration content: $(jq -r '.' <<<"${config_content}")"
  fi

  info "target: ${target}"

  if [ "${target}" = "profile" ]; then
    if [ -z "${profile}" ]; then
      error "profile identifier is required"
      usage
      die
    fi

    config_dir="${config_dir}/profiles/${profile}"
    config_file="${config_dir}/profile"
  elif [ -n "${profile}" ]; then
    warn "profile option is set although target is not a profile"
  fi

  info "using configuration file at: ${config_file}"

  _do mkdir -p "${config_dir}"

  info "merging configuration content with configuration file"
  _do create_or_merge_json "${config_file}" "${config_content}"

  # Handle app ID
  if [ "${target}" = "app" ]; then
    if [ -e "${config_file}" ] && [ "$(jq -r '.appId' "${config_file}")" == "null" ]; then
      info "updating app ID"
      appid="$(gen_appid)"
      info "generated app ID: ${appid}"
      _do create_or_merge_json "${config_file}" '{"appId":"'"${appid}"'"}'
    elif [ -e "${config_file}" ]; then
      info "keep existing app ID"
    fi
  else
    if [ -n "${use_git_exec}" ]; then
      local detected_git
      detected_git="$(detect_git)"

      info "updating profile configuration with detected git: ${detected_git}"
      _do create_or_merge_json "${config_file}" '{"git":{"selectedGitPath":"'"${detected_git}"'"}}'
    fi
  fi

  success "configuration successfully generated"
}

# Handle interruptions gracefully
trap 'echo "Script interrupted" >&2; exit 1' INT TERM

main "$@"
