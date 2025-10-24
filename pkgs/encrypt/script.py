#!/usr/bin/env python3

import argparse
import json
import os
import signal
import sys
from hashlib import scrypt
from pathlib import Path
from typing import NoReturn, Optional, Any

try:
    from termcolor import colored, cprint  # pyright: ignore[reportMissingImports]
except ImportError:
    print(
        "Error: termcolor is not installed. Install it with: pip install termcolor",
        file=sys.stderr,
    )
    sys.exit(1)

try:
    from cryptography.hazmat.primitives.ciphers.aead import (  # pyright: ignore[reportMissingImports]
        AESGCM,
    )
except ImportError:
    print(
        "Error: cryptography is not installed. Install it with: pip install cryptography",
        file=sys.stderr,
    )
    sys.exit(1)

####################
# GLOBAL VARIABLES #
####################

VERSION = "@version@"
DESCRIPTION = "@description@."
SCRIPT_NAME = Path(__file__).name
CONFIG_FILE = Path.home() / ".gitkraken" / "config"

# Key derivation constants
KEY_SIZE = 32
KEY_WORK = 2**14  # 16384
KEY_BLOCKS = 8
KEY_PARALLELIZATION = 1

# Encryption constants
IV_SIZE = 12
AUTH_TAG_SIZE = 16

#####################
# UTILITY FUNCTIONS #
#####################


def error(message: str) -> None:
    """Print error message to stderr"""
    cprint(f" ✗ {message}", "red", file=sys.stderr)


def warn(message: str) -> None:
    """Print warning message to stderr"""
    cprint(f" ⚠ {message}", "yellow", file=sys.stderr)


def success(message: str) -> None:
    """Print success message to stdout"""
    cprint(f" ✓ {message}", "green")


def die(message: Optional[str] = None) -> NoReturn:
    """Exit script with optional error message"""
    if message:
        error(message)
    sys.exit(1)


########################
# CORE LOGIC FUNCTIONS #
########################


def ensure_config() -> None:
    """Ensure the config file exists and is readable"""

    if not CONFIG_FILE.exists():
        die(f"Config file not found: {CONFIG_FILE}\n\nIs GitKraken installed?")

    if not os.access(CONFIG_FILE, os.R_OK):
        die(f"Config file is not readable: {CONFIG_FILE}")


def get_app_id() -> str:
    """Extract appId from config file"""

    try:
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            config_data = json.load(f)
    except json.JSONDecodeError as e:
        die(f"Failed to parse config file as JSON: {e}\nFile: {CONFIG_FILE}")
    except IOError as e:
        die(f"Failed to read config file: {e}\nFile: {CONFIG_FILE}")

    app_id = config_data.get("appId")

    if not app_id or not isinstance(app_id, str) or app_id.strip() == "":
        die("Invalid or empty appId in config file")

    return app_id.strip()


def derive_key(app_id: str) -> bytes:
    """Derive a 32-byte key using scrypt"""
    return scrypt(
        password=app_id.encode("utf-8"),
        salt=b"salt",
        n=KEY_WORK,
        r=KEY_BLOCKS,
        p=KEY_PARALLELIZATION,
        dklen=KEY_SIZE,
    )


def load_and_validate_json() -> str:
    """Load and validate JSON data from standard input"""

    try:
        input_data = sys.stdin.read()
    except IOError as e:
        die(f"Failed to read from standard input: {e}")

    if not input_data or not input_data.strip():
        die("Standard input is empty")

    try:
        data = json.loads(input_data)
    except json.JSONDecodeError as e:
        die(f"Input is not valid JSON: {e}")

    # Convert back to string for encryption
    return json.dumps(data)


def encrypt_data(json_data: str, app_id: str) -> bytes:
    """Encrypt JSON data using AES-GCM"""

    # Derive encryption key from appId
    encryption_key = derive_key(app_id)

    # Generate random initialization vector (iv/nonce)
    iv = os.urandom(IV_SIZE)

    # Encrypt data
    try:
        aesgcm = AESGCM(encryption_key)
        # AESGCM.encrypt returns ciphertext + auth_tag concatenated
        encrypted_with_tag = aesgcm.encrypt(iv, json_data.encode("utf-8"), None)
    except Exception as e:
        die(f"Encryption failed: {e}")

    # Split encrypted data and auth tag
    # The last 16 bytes are the auth tag
    encrypted = encrypted_with_tag[:-AUTH_TAG_SIZE]
    auth_tag = encrypted_with_tag[-AUTH_TAG_SIZE:]

    # Concatenate: IV (12 bytes) + auth_tag (16 bytes) + encrypted data
    return iv + auth_tag + encrypted


def write_encrypted_file(encrypted_data: bytes, output_file: Path) -> None:
    """Write encrypted data to file, creating parent directories if needed"""

    try:
        # Create parent directories if they don't exist (recursive: true)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        # Write encrypted data
        with open(output_file, "wb") as f:
            f.write(encrypted_data)

        success(
            f"Encrypted data written to: {colored(str(output_file), attrs=['bold'])}"
        )
    except IOError as e:
        die(f"Failed to write output file: {e}")


########
# MAIN #
########


def signal_handler(sig: int, frame: Any) -> NoReturn:
    """Handle interruptions gracefully"""

    warn("\nScript interrupted")
    sys.exit(130)  # Standard exit code for SIGINT


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments"""

    parser = argparse.ArgumentParser(
        prog=SCRIPT_NAME,
        description=DESCRIPTION,
        epilog=f"Example: cat data.json | {SCRIPT_NAME} -o ~/.gitkraken/secFile",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-o",
        "--output",
        metavar="FILE",
        required=True,
        help="write encrypted output to FILE (e.g., $HOME/.gitkraken/secFile)",
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

    # Execute main logic
    ensure_config()
    output_path = Path(args.output).expanduser().resolve()
    app_id = get_app_id()
    json_data = load_and_validate_json()
    encrypted_data = encrypt_data(json_data, app_id)
    write_encrypted_file(encrypted_data, output_path)


if __name__ == "__main__":
    main()
