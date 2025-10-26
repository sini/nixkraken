#!/usr/bin/env python3

import argparse
import hashlib
import json
import signal
import sys
import uuid
from pathlib import Path
from typing import Optional, TextIO, NoReturn, Any, Dict

try:
    from termcolor import cprint, colored  # pyright: ignore[reportMissingImports]
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
TMP_CONFIG = None

# Global flags
DRY_RUN = False
VERBOSE = False

# Default profile ID
DEFAULT_PROFILE = "d6e5a8ca26e14325a4275fc33b17e16f"

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


def _log(message: str, color: str, file: TextIO = sys.stdout) -> None:
    """Log a message, respecting dry-run and verbose modes"""
    prefix = "[dry-run] " if DRY_RUN else ""

    if DRY_RUN or VERBOSE:
        cprint(f"{prefix}{message}", color, file=file)


def error(message: str) -> None:
    """Print error message to stderr (always shown)"""
    cprint(f" ✗ {message}", "red", file=sys.stderr)


def warn(message: str) -> None:
    """Print warning message to stderr"""
    _log(f" ⚠ {message}", "yellow", file=sys.stderr)


def info(message: str) -> None:
    """Print warning message to stderr (shown in dry-run/verbose)"""
    _log(f" i {message}", "blue")


def success(message: str) -> None:
    """Print success message to stdout (never shown in dry-run)"""
    if not DRY_RUN:
        cprint(f" ✓ {message}", "green")


def die(message: Optional[str] = None, exit_code: int = 1) -> NoReturn:
    """Exit script with optional error message and exit code"""
    if message:
        error(message)
    sys.exit(exit_code)


########################
# CORE LOGIC FUNCTIONS #
########################


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


def ensure_config(config_file: Path) -> Dict[str, Any]:
    """Check config file exists and is valid or create empty one"""
    if config_file.exists() and not config_file.is_file():
        die(f"Path is not a file ({config_file})")

    try:
        with open(config_file, "r", encoding="utf-8") as f:
            config = json.load(f)

        info("Configuration file exists and is valid")
    except (json.JSONDecodeError, IOError):
        info("Create configuration file")
        config = {}

        if not DRY_RUN:
            config_file.parent.mkdir(parents=True, exist_ok=True)

            with open(config_file, "a", encoding="utf-8") as f:
                json.dump(config, f, indent=2)

    return config


def get_sha1(text: str) -> str:
    """Generate SHA1 hash of given text"""
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


def get_mac() -> str:
    """Get MAC address of the first active network interface"""
    # This returns the MAC address as an integer
    mac_int = uuid.getnode()

    # Convert to MAC address format
    mac_hex = f"{mac_int:012x}"
    mac_address = ":".join(mac_hex[i : i + 2] for i in range(0, 12, 2))

    return mac_address


def gen_appid() -> str:
    """Generate a unique appId based on the MAC address of the first active network interface"""
    blacklisted_appids = [
        "8149453d12fde3c987f5ceb011360abe56307d17",
        "a76a6cbfb93cbb6daa4c4836544564fb777a0803",
        "4433e1caaca0b97ba94ef3e0772e5931f792fa9b",
        "b14e824ad9cd8a3e95493d48e6132ecce40e0e47",
    ]

    try:
        mac_address = get_mac()
        generated_appid = get_sha1(mac_address)
    except Exception:
        # Fallback to random UUID if MAC address retrieval fails
        generated_appid = get_sha1(str(uuid.uuid4()))

    # Check if generated ID is blacklisted
    if generated_appid in blacklisted_appids:
        generated_appid = gen_appid()

    return generated_appid


def update_config(
    config_file: Path, config: Dict[str, Any], for_profile: bool = False
) -> None:
    """Update config file content"""
    global TMP_CONFIG

    # Handle app ID generation
    if not for_profile and "appId" not in config:
        info("Setting app ID")
        app_id = gen_appid()
        info(f"Generated app ID: {app_id}")

        config["appId"] = app_id
    elif not for_profile:
        info(f"Using existing app ID: {config["appId"]}")

    if not DRY_RUN:
        # Write to temporary file first, then move atomically
        try:
            # Ensure parent directory exists
            config_file.parent.mkdir(parents=True, exist_ok=True)
            TMP_CONFIG = config_file.with_name(f"{config_file.name}.tmp")

            with open(TMP_CONFIG, "w", encoding="utf-8") as tmp_file:
                json.dump(config, tmp_file, indent=2)

            TMP_CONFIG.replace(config_file)
        except Exception as e:
            die(f"Failed to update configuration file: {e}")


def cleanup() -> None:
    """Remove temporary files on exit"""
    try:
        if TMP_CONFIG is not None and TMP_CONFIG.exists():
            TMP_CONFIG.unlink()
    except Exception:
        pass


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

    parser = argparse.ArgumentParser(
        prog=SCRIPT_NAME,
        description=DESCRIPTION,
        epilog=f"""
{colored('Examples:', attrs=['bold'])}
  {colored('Configure application:', attrs=['dark'])}
    {colored('$', attrs=['dark'])} {SCRIPT_NAME} -c JSON [--dry-run] [-v]

  {colored('Configure profile:', attrs=['dark'])}
    {colored('$', attrs=['dark'])} {SCRIPT_NAME} -c JSON -p PROFILE_ID [--dry-run] [-v]
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-c",
        "--config",
        required=True,
        metavar="JSON",
        help="configuration content in JSON format",
    )
    parser.add_argument(
        "-p",
        "--profile",
        metavar="PROFILE_ID",
        help="operate on given profile configuration",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="only print what would be done",
    )

    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="enable verbose output",
    )

    parser.add_argument(
        "-V", "--version", action="version", version=f"%(prog)s {VERSION}"
    )

    return parser.parse_args()


def main() -> None:
    """Main function."""
    global DRY_RUN, VERBOSE

    # Set up signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Parse command-line arguments
    args = parse_arguments()

    # Set global flags
    DRY_RUN = args.dry_run
    VERBOSE = args.verbose

    info("Starting GitKraken configuration generation")

    # Determine configuration file path
    config_dir = CONFIG_DIR
    config_file = CONFIG_DIR / "config"

    if args.profile:
        config_dir = CONFIG_DIR / "profiles" / args.profile
        config_file = config_dir / "profile"

    info(f"Using configuration file at: {config_file}")

    current_config = ensure_config(config_file)

    info(f"Current configuration: {json.dumps(current_config)}")

    try:
        config_update = json.loads(args.config)
    except json.JSONDecodeError as e:
        die(f"Invalid JSON format: {e}")

    merged = merge_json(current_config, config_update)

    info(f"Updated configuration: {json.dumps(merged)}")

    info("Writing configuration")
    update_config(config_file, merged, for_profile=bool(args.profile))

    success("Configuration successfully generated")


if __name__ == "__main__":
    main()
