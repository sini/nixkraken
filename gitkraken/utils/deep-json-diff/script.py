#!/usr/bin/env python3

import json
import sys
import argparse


def get_diff(obj1, obj2, path=""):
    """Compare two JSON objects and return differences with full key paths."""
    differences = []

    # Get all keys from both objects
    if isinstance(obj1, dict) and isinstance(obj2, dict):
        all_keys = set(obj1.keys()) | set(obj2.keys())

        for key in all_keys:
            current_path = f"{path}.{key}" if path else key

            if key not in obj1:
                differences.append(f"[ADD] {current_path} = {obj2[key]}")
            elif key not in obj2:
                differences.append(f"[DEL] {current_path} = {obj1[key]}")
            else:
                # Both have the key, check if values are different
                if isinstance(obj1[key], dict) and isinstance(obj2[key], dict):
                    # Recursively compare nested objects
                    differences.extend(get_diff(obj1[key], obj2[key], current_path))
                elif isinstance(obj1[key], list) and isinstance(obj2[key], list):
                    # Compare lists
                    if obj1[key] != obj2[key]:
                        differences.append(
                            f"[MOD] {current_path}: {obj1[key]} >>> {obj2[key]}"
                        )
                elif obj1[key] != obj2[key]:
                    differences.append(
                        f"[MOD] {current_path}: {obj1[key]} >>> {obj2[key]}"
                    )

    elif isinstance(obj1, list) and isinstance(obj2, list):
        if obj1 != obj2:
            differences.append(f"[MOD] {path}: {obj1} >>> {obj2}")
    elif obj1 != obj2:
        differences.append(f"[MOD] {path}: {obj1} >>> {obj2}")

    return differences


def compare_json_files(file1_path, file2_path):
    """Load and compare two JSON files."""
    try:
        with open(file1_path, "r") as f1:
            data1 = json.load(f1)
    except FileNotFoundError:
        print(f"Error: File '{file1_path}' not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{file1_path}': {e}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(file2_path, "r") as f2:
            data2 = json.load(f2)
    except FileNotFoundError:
        print(f"Error: File '{file2_path}' not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{file2_path}': {e}", file=sys.stderr)
        sys.exit(1)

    differences = get_diff(data1, data2)

    if differences:
        for diff in differences:
            print(f"  {diff}")


def main():
    parser = argparse.ArgumentParser(
        description="Compare two JSON files and show differences with full key paths.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s file1.json file2.json
  %(prog)s old_config.json new_config.json
        """,
    )
    parser.add_argument("file1", help="First JSON file")
    parser.add_argument("file2", help="Second JSON file")

    args = parser.parse_args()

    compare_json_files(args.file1, args.file2)


if __name__ == "__main__":
    main()
