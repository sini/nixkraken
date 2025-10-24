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

# Decryption constants
IV_SIZE = 12
AUTH_TAG_SIZE = 16
MIN_ENCRYPTED_SIZE = IV_SIZE + AUTH_TAG_SIZE

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


def ensure_secret(secret_file: Optional[str]) -> Path:
    """Ensure the secret file is provided, exists, is readable, and is not empty"""

    if not secret_file:
        die(f"{SCRIPT_NAME} requires a file to decrypt")

    secret_path = Path(secret_file).expanduser().resolve()

    if not secret_path.exists():
        die(f"Secret file does not exist: {secret_path}")

    if not secret_path.is_file():
        die(f"Secret path is not a file: {secret_path}")

    if not os.access(secret_path, os.R_OK):
        die(f"Secret file is not readable: {secret_path}")

    if secret_path.stat().st_size == 0:
        die(f"Secret file is empty: {secret_path}")

    return secret_path


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
        password=app_id.encode("utf-8"), salt=b"salt", n=16384, r=8, p=1, dklen=32
    )


def decrypt_secret(secret_file: Path, app_id: str) -> str:
    """Decrypt secret data using AES-GCM"""

    # Derive encryption key from appId
    encryption_key = derive_key(app_id)

    # Extract crypto components
    with open(secret_file, "rb") as f:
        encrypted_buffer = f.read()

    # Validate minimum size: 12 (IV) + 16 (tag) = 28 bytes
    if len(encrypted_buffer) < MIN_ENCRYPTED_SIZE:
        die(f"Invalid encrypted file: too small ({len(encrypted_buffer)} bytes)")

    iv = encrypted_buffer[:IV_SIZE]
    auth_tag = encrypted_buffer[IV_SIZE:MIN_ENCRYPTED_SIZE]
    encrypted_data = encrypted_buffer[MIN_ENCRYPTED_SIZE:]

    # Decrypt
    try:
        aesgcm = AESGCM(encryption_key)
        decrypted = aesgcm.decrypt(iv, encrypted_data + auth_tag, None).decode("utf-8")
    except Exception as e:
        die(f"Decryption failed: {e}\nIs this a GitKraken secret file?")

    return decrypted


def write_output(
    data: str, output_file: Optional[str] = None, pretty: bool = False
) -> None:
    """Write decrypted data to file or stdout"""

    try:
        json_data = json.loads(data)
        data = json.dumps(json_data, indent=2 if pretty else None, sort_keys=pretty)
    except json.JSONDecodeError as e:
        die(f"Decrypted data is not valid JSON: {e}")

    if output_file:
        output_path = Path(output_file).expanduser().resolve()
        try:
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(data)
            success(
                f"Decrypted data written to: {colored(str(output_path), attrs=['bold'])}"
            )
        except IOError as e:
            die(f"Failed to write output file: {e}")
    else:
        print(data)


########
# MAIN #
########


def signal_handler(sig: int, frame: Optional[Any]) -> NoReturn:
    """Handle interruptions gracefully"""

    warn("\nScript interrupted")
    sys.exit(130)  # Standard exit code for SIGINT


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments"""

    parser = argparse.ArgumentParser(
        prog=SCRIPT_NAME,
        description=DESCRIPTION,
        epilog=f"Example: {SCRIPT_NAME} ~/.gitkraken/secFile -o decrypted.json --pretty",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "secret_file",
        metavar="SECRET_FILE",
        help="path to the secret file to decrypt (e.g., $HOME/.gitkraken/secFile)",
    )

    parser.add_argument(
        "-o", "--output", metavar="FILE", help="write output to FILE instead of stdout"
    )

    parser.add_argument(
        "-p",
        "--pretty",
        action="store_true",
        help="pretty print JSON output with indentation",
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
    secret_path = ensure_secret(args.secret_file)
    app_id = get_app_id()
    decrypted_data = decrypt_secret(secret_path, app_id)
    write_output(decrypted_data, args.output, args.pretty)


if __name__ == "__main__":
    main()
