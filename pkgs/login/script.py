#!/usr/bin/env python3

import argparse
import base64
import getpass
import json
import os
import signal
import subprocess
import sys
import zlib
from datetime import datetime, timezone
from pathlib import Path
from typing import NoReturn, Optional, Any, Dict, Tuple

try:
    from termcolor import colored, cprint  # pyright: ignore[reportMissingImports]
except ImportError:
    print(
        "Error: termcolor is not installed. Install it with: pip install termcolor",
        file=sys.stderr,
    )
    sys.exit(1)

####################
# GLOBAL VARIABLES #
####################

VERSION = "@version@"
DESCRIPTION = "@description@."
SCRIPT_NAME = Path(__file__).name
CONFIG_DIR = Path.home() / ".gitkraken"
CONFIG_FILE = CONFIG_DIR / "config"
TMP_CONFIG = CONFIG_FILE.with_name(f"{CONFIG_FILE.name}.tmp")

# Available providers
PROVIDERS = ["github", "gitlab", "bitbucket", "azure", "google"]

# Default profile ID
DEFAULT_PROFILE = "d6e5a8ca26e14325a4275fc33b17e16f"

# Maximum attempts to set token from user input
TOKEN_INPUT_MAX_ATTEMPTS = 3

# Supported shells for completion generation
COMPLETION_SHELLS = ["bash", "zsh", "fish"]

######################
# COMPLETION SCRIPTS #
######################


def get_completion_bash() -> str:
    """Generate Bash completion script dynamically"""
    providers_str = " ".join(PROVIDERS)
    shells_str = " ".join(COMPLETION_SHELLS)

    return f"""# bash completion for {SCRIPT_NAME}
# Source this file or copy it to /etc/bash_completion.d/

_{SCRIPT_NAME.replace('-', '_')}_completion() {{
    local cur prev opts
    COMPREPLY=()
    cur="${{COMP_WORDS[COMP_CWORD]}}"
    prev="${{COMP_WORDS[COMP_CWORD-1]}}"

    # All available options
    opts="-p --provider -P --profile --token --token-file --generate-completion --debug -v --version -h --help"

    # Context-aware completion based on previous word
    case "${{prev}}" in
        -p|--provider)
            # Complete with providers
            COMPREPLY=( $(compgen -W "{providers_str}" -- "${{cur}}") )
            return 0
            ;;
        -P|--profile)
            # Complete with profile IDs from ~/.gitkraken/profiles/
            local profile_dir="${{HOME}}/.gitkraken/profiles"
            if [[ -d "${{profile_dir}}" ]]; then
                local profiles=""
                for profile in "${{profile_dir}}"/*; do
                    if [[ -d "${{profile}}" ]]; then
                        profiles="${{profiles}} $(basename "${{profile}}")"
                    fi
                done
                COMPREPLY=( $(compgen -W "${{profiles}}" -- "${{cur}}") )
            fi
            return 0
            ;;
        --token-file)
            # Complete with file paths
            COMPREPLY=( $(compgen -f -- "${{cur}}") )
            return 0
            ;;
        --token)
            # No completion for token (it's a secret)
            return 0
            ;;
        --generate-completion)
            # Complete with shell names
            COMPREPLY=( $(compgen -W "{shells_str}" -- "${{cur}}") )
            return 0
            ;;
        *)
            ;;
    esac

    # Check if certain options have already been used (to avoid duplicates)
    local used_opts=""
    local i
    for ((i=1; i < COMP_CWORD; i++)); do
        case "${{COMP_WORDS[i]}}" in
            -p|--provider|-P|--profile|--token|--token-file|--generate-completion|--debug|-v|--version|-h|--help)
                used_opts="${{used_opts}} ${{COMP_WORDS[i]}}"
                ;;
        esac
    done

    # Filter out already used single-use options
    local available_opts=""
    for opt in ${{opts}}; do
        case "${{opt}}" in
            -p|--provider|-P|--profile|--token|--token-file|--generate-completion|-v|--version|-h|--help)
                # These options should only appear once
                if [[ ! " ${{used_opts}} " =~ " ${{opt}} " ]]; then
                    available_opts="${{available_opts}} ${{opt}}"
                fi
                ;;
            *)
                # Other options can be repeated
                available_opts="${{available_opts}} ${{opt}}"
                ;;
        esac
    done

    # Default completion with available options
    COMPREPLY=( $(compgen -W "${{available_opts}}" -- "${{cur}}") )
    return 0
}}

# Register the completion function
complete -F _{SCRIPT_NAME.replace('-', '_')}_completion {SCRIPT_NAME}
"""


def get_completion_zsh() -> str:
    """Generate Zsh completion script dynamically"""
    # Build provider descriptions
    provider_descriptions = {
        "github": "GitHub provider",
        "gitlab": "GitLab provider",
        "bitbucket": "Bitbucket provider",
        "azure": "Azure DevOps provider",
        "google": "Google provider",
    }

    providers_array = "\n".join(
        f"        '{provider}:{provider_descriptions.get(provider, f'Login with {provider}')}'"
        for provider in PROVIDERS
    )

    shells_array = "\n".join(
        f"        '{shell}:Shell completion for {shell}'" for shell in COMPLETION_SHELLS
    )

    return f"""#compdef {SCRIPT_NAME}
# zsh completion for {SCRIPT_NAME}
# Place this file in your $fpath (e.g., /usr/share/zsh/site-functions/_{SCRIPT_NAME})
# or source it directly in your ~/.zshrc

_{SCRIPT_NAME.replace('-', '_')}() {{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a providers
    providers=(
{providers_array}
    )

    local -a shells
    shells=(
{shells_array}
    )

    local -a profiles
    local profile_dir="${{HOME}}/.gitkraken/profiles"
    if [[ -d "${{profile_dir}}" ]]; then
        for dir in "${{profile_dir}}"/*(/N); do
            local profile_id="${{dir:t}}"
            local profile_name="UNKNOWN"
            local profile_file="${{dir}}/profile"

            # Special case for default profile
            if [[ "${{profile_id}}" == "{DEFAULT_PROFILE}" ]]; then
                profile_name="DEFAULT"
            elif [[ -f "${{profile_file}}" ]]; then
                # Try to extract profile name from JSON
                profile_name=$(jq -r '.profileName // "UNNAMED"' "${{profile_file}}" 2>/dev/null || echo "UNKNOWN")
            fi

            profiles+=("${{profile_id}}:${{profile_name}}")
        done
    fi

    _arguments -C \\
        '(- *)'{{-h,--help}}'[show help message and exit]' \\
        '(- *)'{{-v,--version}}'[show version and exit]' \\
        '(-p --provider)'{{-p,--provider}}'[provider to login with]:provider:->providers' \\
        '(-P --profile)'{{-P,--profile}}'[profile ID to use]:profile:->profiles' \\
        '(--token --token-file)--token[access token (literal, stdin, or -)]:token:' \\
        '(--token --token-file)--token-file[path to file containing access token]:file:_files' \\
        '(- *)--generate-completion[generate shell completion script]:shell:->shells' \\
        '--debug[output debug information]' \\
        && return 0

    case $state in
        providers)
            _describe -t providers 'provider' providers
            ;;
        profiles)
            if (( ${{#profiles[@]}} > 0 )); then
                _describe -t profiles 'profile' profiles
            else
                _message 'no profiles found'
            fi
            ;;
        shells)
            _describe -t shells 'shell' shells
            ;;
    esac

    return 0
}}

_{SCRIPT_NAME.replace('-', '_')} "$@"
"""


def get_completion_fish() -> str:
    """Generate Fish completion script dynamically"""
    providers_str = " ".join(PROVIDERS)
    shells_str = " ".join(COMPLETION_SHELLS)

    return f"""# fish completion for {SCRIPT_NAME}
# Place this file in ~/.config/fish/completions/{SCRIPT_NAME}.fish
# or in /usr/share/fish/vendor_completions.d/{SCRIPT_NAME}.fish

# Disable file completion by default
complete -c {SCRIPT_NAME} -f

# Help and version
complete -c {SCRIPT_NAME} -s h -l help -d 'Show help message and exit'
complete -c {SCRIPT_NAME} -s v -l version -d 'Show version and exit'

# Provider option
complete -c {SCRIPT_NAME} -s p -l provider -d 'Provider to login with' -x -a '{providers_str}'

# Profile option - complete with actual profile IDs
if test -d ~/.gitkraken/profiles
    for dir in ~/.gitkraken/profiles/*/
        set profile_id (basename $dir)
        set profile_file $dir/profile
        set profile_name "UNKNOWN"

        # Special case for default profile
        if test "$profile_id" = "{DEFAULT_PROFILE}"
            set profile_name "DEFAULT"
        else if test -f $profile_file
            # Try to extract profile name from JSON
            set profile_name (jq -r ".profileName // \\"UNNAMED\\"" $profile_file 2>/dev/null; or echo "UNKNOWN")
        end

        complete -c {SCRIPT_NAME} -s P -l profile -d 'Profile ID to use' -x -a "$profile_id\\t'$profile_name'"
    end
end

# Token option (no completion for security)
complete -c {SCRIPT_NAME} -l token -d 'Access token (literal, stdin, or -)' -x

# Token file option (enable file completion)
complete -c {SCRIPT_NAME} -l token-file -d 'Path to file containing access token' -r

# Generate completion option
complete -c {SCRIPT_NAME} -l generate-completion -d 'Generate shell completion script' -x -a '{shells_str}'

# Debug option
complete -c {SCRIPT_NAME} -l debug -d 'Output debug information'

# Conditional completions to prevent conflicts
# --token and --token-file are mutually exclusive
complete -c {SCRIPT_NAME} -l token -n 'not __fish_seen_argument -l token-file'
complete -c {SCRIPT_NAME} -l token-file -n 'not __fish_seen_argument -l token'
"""


#####################
# UTILITY FUNCTIONS #
#####################


def get_profiles() -> Dict[str, str]:
    """Get a mapping of profile IDs to profile names"""
    profiles_dir = CONFIG_DIR / "profiles"
    profiles = {}

    if not profiles_dir.exists():
        return profiles

    try:
        for profile_path in profiles_dir.iterdir():
            if not profile_path.is_dir():
                continue

            profile_id = profile_path.name
            profile_file = profile_path / "profile"

            # Special case for default profile
            if profile_id == DEFAULT_PROFILE:
                profiles[profile_id] = "DEFAULT"
            elif profile_file.exists():
                try:
                    with open(profile_file, "r", encoding="utf-8") as f:
                        profile_data = json.load(f)
                        profile_name = profile_data.get("profileName", "UNNAMED")
                        profiles[profile_id] = profile_name
                except (json.JSONDecodeError, IOError):
                    profiles[profile_id] = "UNKNOWN"
            else:
                profiles[profile_id] = "UNKNOWN"
    except Exception:
        pass

    return profiles


def error(message: str) -> None:
    """Print error message to stderr"""
    cprint(f" ✗ {message}", "red", file=sys.stderr)


def warn(message: str) -> None:
    """Print warning message to stderr"""
    cprint(f" ⚠ {message}", "yellow", file=sys.stderr)


def debug(message: str, debug_enabled: bool = False) -> None:
    """Print debug message to stderr if debug is enabled"""
    if debug_enabled:
        print(f" ▶ {message}", file=sys.stderr)


def success(message: str) -> None:
    """Print success message to stdout"""
    cprint(f" ✓ {message}", "green")


def die(message: Optional[str] = None, exit_code: int = 1) -> NoReturn:
    """Exit script with optional error message and exit code"""
    if message:
        error(message)
    sys.exit(exit_code)


########################
# CORE LOGIC FUNCTIONS #
########################


def ensure_provider(provider: Optional[str], debug_enabled: bool) -> str:
    """Ensure a valid provider is specified and supported"""
    debug("Checking provider", debug_enabled)

    if not provider:
        die(f"{SCRIPT_NAME} requires a provider")

    if provider not in PROVIDERS:
        error(f"Provider '{provider}' is invalid")
        print()
        print(f"Available providers: {','.join(PROVIDERS)}")
        die()

    debug(f"Using provider: '{provider}'", debug_enabled)
    return provider


def ensure_profile(profile: Optional[str], debug_enabled: bool) -> str:
    """Ensure a profile ID is set, or use the default profile ID"""
    if not profile:
        warn("No profile ID set, using default profile ID")
        profile = DEFAULT_PROFILE
    else:
        profiles = get_profiles()
        if profile not in profiles:
            error(f"Profile '{profile}' does not exist")
            print()
            if profiles:
                print("Available profiles:")
                for profile_id, profile_name in profiles.items():
                    print(f"  {profile_id}: {profile_name}")
            else:
                print("No profiles found. Is GitKraken installed?")
            die()

    debug(f"Using profile: '{profile}'", debug_enabled)
    return profile


def ensure_config(profile: str, provider: str, debug_enabled: bool) -> Path:
    """Ensure the main config file exists and is readable, and the profile directory exists"""
    debug("Checking config file", debug_enabled)

    if not CONFIG_FILE.exists():
        die("Config file not found. Is GitKraken installed?")

    if not os.access(CONFIG_FILE, os.R_OK):
        die("Config file is not readable")

    debug("Config file found", debug_enabled)

    profile_dir = CONFIG_DIR / "profiles" / profile / provider

    # Create profile directory if it doesn't exist
    if not profile_dir.exists():
        try:
            profile_dir.mkdir(parents=True, exist_ok=True)
            debug(f"Created profile directory: {profile_dir}", debug_enabled)
        except OSError as e:
            die(f"Failed to create profile directory: {profile_dir}\n{e}")
    else:
        debug(f"Using existing profile directory: {profile_dir}", debug_enabled)

    return profile_dir


def open_browser(provider: str) -> None:
    """Open the default web browser to the GitKraken OAuth login page for the selected provider"""
    url = f"https://api.gitkraken.com/oauth/{provider}/login?action=login&in_app=true"

    print(
        f"{colored('Opening web browser to login to GitKraken account...', attrs=['bold'])}"
    )
    print(
        colored(
            f"If browser doesn't open automatically, use this URL: {url}",
            attrs=["dark"],
        )
    )

    try:
        subprocess.run(
            ["xdg-open", url],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except Exception:
        warn("Failed to open browser automatically, please open the URL manually")


def validate_token(token: str) -> bytes:
    """Validate that the token is in base64 format"""
    if not token:
        die("Access token cannot be empty")

    try:
        return base64.b64decode(token)
    except Exception:
        die("Invalid access token format (expected base64 encoded string)")


def read_token_from_file(file_path: str, debug_enabled: bool) -> str:
    """Read token from a file path"""
    debug(f"Reading token from file: {file_path}", debug_enabled)

    path = Path(file_path)

    if not path.exists():
        die(f"Token file not found: {file_path}")

    if not os.access(path, os.R_OK):
        die(f"Token file is not readable: {file_path}")

    try:
        with open(path, "r", encoding="utf-8") as f:
            token = f.read().strip()
    except Exception as e:
        die(f"Failed to read token from file: {e}")

    return token


def read_token_from_stdin(debug_enabled: bool) -> str:
    """Read token from stdin"""
    debug("Reading token from stdin", debug_enabled)

    try:
        token = sys.stdin.read().strip()
    except Exception as e:
        die(f"Failed to read token from stdin: {e}")

    return token


def get_token_non_interactive(
    token_arg: Optional[str], token_file_arg: Optional[str], debug_enabled: bool
) -> bytes:
    """Get token from non-interactive sources (--token or --token-file)"""

    # Check mutual exclusivity
    if token_arg is not None and token_file_arg is not None:
        die("--token and --token-file are mutually exclusive")

    token = ""

    if token_file_arg is not None:
        # Read from file
        token = read_token_from_file(token_file_arg, debug_enabled)
    elif token_arg is not None:
        # --token provided
        if token_arg == "" or token_arg == "-":
            # Read from stdin
            token = read_token_from_stdin(debug_enabled)
        else:
            # Use literal value
            debug("Using token from command line argument", debug_enabled)
            token = token_arg.strip()

    # Validate token
    return validate_token(token)


def set_token() -> bytes:
    """Prompt the user to enter the OAuth access token, validate it, and return it"""
    for attempt in range(TOKEN_INPUT_MAX_ATTEMPTS):
        try:
            print("Enter access token:")
            token = getpass.getpass("> ").strip()

            if not token:
                error("Access token cannot be empty")
                continue

            # Validate base64 format
            return validate_token(token)
        except (ValueError, Exception):
            error("Invalid access token format (expected base64 encoded string)")
        except KeyboardInterrupt:
            print()
            die("Script interrupted")

    die("Maximum token entry attempts exceeded")


def extract_token(oauth_token: bytes, debug_enabled: bool) -> Tuple[str, str]:
    """Extract API and provider tokens from the zlib-compressed access token"""
    debug("Extracting tokens from access token", debug_enabled)

    if not oauth_token:
        die("Missing access token")

    debug("Expanding zlib compressed access token", debug_enabled)

    try:
        expanded_token = zlib.decompress(oauth_token).decode("utf-8")
    except Exception as e:
        die(f"Failed to expand access token: {e}")

    debug(
        "Extracting API and provider tokens from expanded access token", debug_enabled
    )

    try:
        token_data = json.loads(expanded_token)
        api_token = token_data.get("accessToken")
        provider_token = token_data.get("providerToken", {}).get("access_token")
    except json.JSONDecodeError as e:
        die(f"Failed to parse expanded token as JSON: {e}")

    if not api_token:
        die("Failed to extract API token")

    if not provider_token:
        die("Failed to extract provider token")

    debug("Tokens successfully extracted", debug_enabled)
    return api_token, provider_token


def merge_json(current: Dict[str, Any], update: Dict[str, Any]) -> Dict[str, Any]:
    """Merge two JSON objects (update overwrites current)"""
    result = current.copy()

    # Deep merge: current is base, update overwrites
    for key, value in update.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = merge_json(result[key], value)
        else:
            result[key] = value

    return result


def encrypt_api_token(api_token: str, debug_enabled: bool) -> None:
    """Encrypt the API token and store it in the global secret file"""
    secret_file = CONFIG_DIR / "secFile"
    secret_content = {}
    update = {"GitKraken": {"api-accessToken": api_token}}

    debug(f"Encrypting API token to {secret_file}", debug_enabled)

    # Decrypt existing secret file if it exists
    if secret_file.exists():
        debug("Decrypting existing secret file", debug_enabled)

        try:
            result = subprocess.run(
                ["gk-decrypt", str(secret_file)],
                capture_output=True,
                text=True,
                check=True,
            )
            secret_content = json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            # Print the original error from gk-decrypt (stderr)
            if e.stderr:
                print(e.stderr, file=sys.stderr, end="")
                die(exit_code=e.returncode)

            die("Failed to decrypt existing secret file")
        except json.JSONDecodeError as e:
            die(f"Failed to parse decrypted secret file: {e}")

    debug("Merging existing secret data with new API token", debug_enabled)
    merged_content = merge_json(secret_content, update)

    debug("Saving encrypted file in place", debug_enabled)

    try:
        result = subprocess.run(
            ["gk-encrypt", "-o", str(secret_file)],
            input=json.dumps(merged_content),
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        if e.stderr:
            print(e.stderr, file=sys.stderr, end="")
            die(exit_code=e.returncode)

        die("Failed to encrypt API token")


def encrypt_provider_token(
    provider_token: str, profile_dir: Path, debug_enabled: bool
) -> None:
    """Encrypt the provider token and store it in the profile-specific secret file"""
    provider_secret_file = profile_dir / "secFile"
    debug(f"Encrypting provider token to {provider_secret_file}", debug_enabled)

    provider_data = {"GitKraken": {"accessToken": provider_token}}

    try:
        subprocess.run(
            ["gk-encrypt", "-o", str(provider_secret_file)],
            input=json.dumps(provider_data),
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        if e.stderr:
            print(e.stderr, file=sys.stderr, end="")
            die(exit_code=e.returncode)

        die("Failed to encrypt provider token")


def update_config(provider: str, debug_enabled: bool) -> None:
    """Update the main config file with registration data"""
    debug("Updating config file with registration data", debug_enabled)

    try:
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            current = json.load(f)
    except (IOError, json.JSONDecodeError) as e:
        die(f"Failed to read config file: {e}")

    # Generate ISO 8601 timestamp with milliseconds
    now = datetime.now(timezone.utc)
    timestamp = now.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    update = {
        "registration": {
            "status": "activated",
            "loginType": provider,
            "date": timestamp,
        },
        "userMilestones": {"firstLoginRegister": True},
    }

    merged = merge_json(current, update)

    try:
        with open(TMP_CONFIG, "w", encoding="utf-8") as f:
            json.dump(merged, f, indent=2)

        TMP_CONFIG.replace(CONFIG_FILE)
    except (IOError, OSError) as e:
        die(f"Failed to write config file: {e}")


def cleanup() -> None:
    """Remove temporary files on exit"""
    try:
        if TMP_CONFIG.exists():
            TMP_CONFIG.unlink()
    except Exception:
        pass


def generate_completion_script(shell: str) -> None:
    """Generate and output shell completion script"""

    completion_generators = {
        "bash": get_completion_bash,
        "zsh": get_completion_zsh,
        "fish": get_completion_fish,
    }

    if shell not in completion_generators:
        die(f"Unsupported shell: {shell}")

    print(completion_generators[shell](), end="")


########
# MAIN #
########


def signal_handler(sig: int, frame: Any) -> NoReturn:
    """Handle interruptions gracefully"""
    cleanup()
    warn("\nScript interrupted")
    sys.exit(130)  # Standard exit code for SIGINT


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments"""

    profiles = get_profiles()
    profiles_help = "profile ID to use (defaults to default profile)"
    if profiles:
        profiles_list = ", ".join(
            [
                f"{profile_id} ({profile_name})"
                for profile_id, profile_name in profiles.items()
            ]
        )
        profiles_help += f"\n  Available: {profiles_list}"

    parser = argparse.ArgumentParser(
        prog=SCRIPT_NAME,
        description=DESCRIPTION,
        epilog=f"Example: {SCRIPT_NAME} --provider=github --profile=default",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-p",
        "--provider",
        metavar="PROVIDER",
        required=False,
        help=f"provider to login with (available: {','.join(PROVIDERS)})",
    )

    parser.add_argument(
        "-P",
        "--profile",
        metavar="PROFILE_ID",
        help=profiles_help,
    )

    parser.add_argument(
        "--token",
        nargs="?",
        const="",
        default=None,
        metavar="TOKEN",
        help="access token (literal string, '-' for stdin, or omit value to read from stdin)",
    )

    parser.add_argument(
        "--token-file",
        metavar="PATH",
        help="path to file containing access token",
    )

    parser.add_argument(
        "--generate-completion",
        metavar="SHELL",
        choices=COMPLETION_SHELLS,
        help=f"generate shell completion script ({', '.join(COMPLETION_SHELLS)})",
    )

    parser.add_argument(
        "--debug",
        action="store_true",
        help="output debug information",
    )

    parser.add_argument(
        "-v", "--version", action="version", version=f"%(prog)s {VERSION}"
    )

    return parser.parse_args()


def main() -> None:
    """Main entry point"""

    # Set up signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Parse command-line arguments
    args = parse_arguments()

    # Handle completion generation
    if args.generate_completion:
        generate_completion_script(args.generate_completion)
        sys.exit(0)

    # Provider is required for normal operation
    if not args.provider:
        error(f"{SCRIPT_NAME} requires --provider")
        print()
        print(f"Available providers: {','.join(PROVIDERS)}")
        print()
        print(f"Run '{SCRIPT_NAME} --help' for more information")
        sys.exit(1)

    debug(f"Starting GitKraken login process", args.debug)
    debug(f"Using {CONFIG_DIR} as root directory", args.debug)

    # Execute main logic
    provider = ensure_provider(args.provider, args.debug)
    profile = ensure_profile(args.profile, args.debug)
    profile_dir = ensure_config(profile, provider, args.debug)

    # Determine if we're in interactive or non-interactive mode
    is_interactive = args.token is None and args.token_file is None

    if is_interactive:
        # Interactive mode: open browser and prompt for token
        open_browser(provider)
        oauth_token = set_token()
    else:
        # Non-interactive mode: get token from --token or --token-file
        oauth_token = get_token_non_interactive(args.token, args.token_file, args.debug)

    api_token, provider_token = extract_token(oauth_token, args.debug)
    encrypt_api_token(api_token, args.debug)
    encrypt_provider_token(provider_token, profile_dir, args.debug)
    update_config(provider, args.debug)

    success("GitKraken authentication successful!")
    print("Please restart or start GitKraken for changes to take effect.")


if __name__ == "__main__":
    try:
        main()
    finally:
        cleanup()
