#!/usr/bin/env bash

set -euo pipefail

####################
# GLOBAL VARIABLES #
####################

script_name="$(basename "$0")"
themes_dir="$HOME/.gitkraken/themes"

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

# Exit script
# shellcheck disable=SC2120
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
  echo "GitKraken themes handler."
  echo
  echo -e "${bold}Usage:${no_color}"
  echo -e "    ${dim}\$${no_color} ${script_name} [--install=<themes>] [--list] [--help]"
  echo
  echo -e "${bold}Options:${no_color}"
  cat <<EOF | column -ts '|'
    -l, --list|List available themes
    -i, --install|Install given themes (comma-separated list of paths to theme files)
    |Note: paths must be absolute
    --dry-run|Only print what would be done
    -v, --verbose|Enable verbose output
    -h, --help|Show this help message
EOF
  echo
}

########################
# CORE LOGIC FUNCTIONS #
########################

jsonc_to_json() {
  sed -e 's/\/\/.*$//' "$1"
}

validate_theme() {
  local theme="${1:-}"

  if [ ! -f "${theme}" ]; then
    error "theme file does not exist: ${theme}"
    return 1
  elif [ ! -r "${theme}" ]; then
    error "theme file is not readable: ${theme}"
    return 1
  elif ! [[ "${theme}" =~ \.jsonc(-default)*$ ]]; then
    error "theme file must use jsonc extension: ${theme}"
    return 1
  elif ! jq '.' <<<"$(jsonc_to_json "${theme}")" >/dev/null 2>&1; then
    error "theme file is not using valid JSON format: ${theme}"
    return 1
  fi
}

list_themes() {
  if ! [ -d "${themes_dir}" ]; then
    warn "themes directory does not exist"
  elif ! [ -r "${themes_dir}" ]; then
    error "themes directory is not readable"
  else
    for theme in "${themes_dir}"/*; do
      local theme_name

      if ! validate_theme "${theme}" 2>/dev/null; then
        continue
      fi

      theme_name="$(jq -r '.meta.name' <<<"$(jsonc_to_json "${theme}")")"

      if [ "${theme_name}" = "null" ] || [ -z "${theme_name}" ]; then
        warn "theme file is not setting '.meta.name': ${theme}"
        continue
      fi

      echo "    ${theme_name}|${theme}"
    done | column -ts '|' -N "Available themes:"
  fi
}

install_theme() {
  local theme="$1"
  local destination

  destination="${themes_dir}/$(basename "${theme}")"

  if ! validate_theme "${theme}"; then
    die
  fi

  info "installing theme '${theme}' at ${destination}"
  _do ln -sf "${theme}" "${destination}"
}

########
# MAIN #
########

main() {
  themes=()

  # Parse command-line options
  while getopts 'hli:v-:' OPT; do
    # Support long options (https://stackoverflow.com/a/28466267/519360)
    if [ "${OPT}" = "-" ]; then # Long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}" # Extract long option name
      # shellcheck disable=SC2295
      OPTARG="${OPTARG#$OPT}" # Extract long option argument (may be empty)
      OPTARG="${OPTARG#=}" # If long option argument, remove assigning `=`
    fi

    # Handle flags
    case "${OPT}" in
      l | list )
        list_themes
        exit 0
        ;;
      i | install )
        needs_arg
        IFS="," read -ra themes <<< "${OPTARG}"
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

  if [ "${#themes[@]}" -eq 0 ]; then
    error "no option specified"
    usage
    die
  fi

  info "handling themes: ${themes[*]}"

  info "creating themes directory: ${themes_dir}"
  _do mkdir -p "${themes_dir}"

  for theme in "${themes[@]}"; do
    install_theme "${theme}"
  done

  success "themes successfully installed"
}

# Handle interruptions gracefully
trap 'echo "Script interrupted" >&2; exit 1' INT TERM

main "$@"
