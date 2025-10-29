#!/usr/bin/env python3
"""
Generate markdown documentation files from a JSON file containing NixOS options.
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Optional


def unwrap(value: str, char: str) -> str:
    """Remove surrounding characters from a string."""
    if value.startswith(char) and value.endswith(char):
        return value[1:-1]
    return value


def wrap_with(value: str, char: str) -> str:
    """Wrap a string with specified characters."""
    return f"{char}{value}{char}"


def format_type(type_str: str) -> str:
    """
    Format the type string for better readability.

    Args:
        type_str: Raw type string

    Returns:
        Formatted type string
    """
    if type_str == "submodule":
        return "attribute set of (submodule)"

    # Extract all types before the first quote
    match_result = type_str.split('"')[0] if '"' in type_str else type_str
    all_types = [t.strip() for t in match_result.split(" or ")]

    if "one of" in all_types:
        # Handle constrained string types
        formatted_types = []
        for t in all_types:
            if t == "one of":
                formatted_types.append("constrained string")
            elif t == "string":
                formatted_types.append("freeform string")
            else:
                formatted_types.append(t)

        # Extract valid values after "one of "
        one_of_index = type_str.find("one of ")
        if one_of_index != -1:
            valid_values_part = type_str[one_of_index + len("one of ") :]
            # Split by ", " to get individual quoted values
            valid_values = [
                v.strip().strip('"')
                for v in valid_values_part.split('", "')
                if v.strip().strip('"')
            ]
        else:
            valid_values = []

        result = [" or ".join(formatted_types), "", "**Valid values:**"]
        result.extend(f"- {wrap_with(value, '`')}" for value in valid_values)

        return "\n".join(result)

    return type_str or "unknown type"


def discover_groups(options: Dict) -> List[str]:
    """
    Discover all groups by finding options with 'submodule' in their type.

    Args:
        options: Dictionary of all options

    Returns:
        List of group names
    """
    return [
        option_name
        for option_name, option_data in options.items()
        if option_name.startswith("programs.nixkraken.")
        and "submodule" in option_data.get("type", "")
    ]


def get_group_for_option(option_name: str, groups: List[str]) -> Optional[str]:
    """
    Determine which group an option belongs to.

    Args:
        option_name: Full option name
        groups: List of all group names

    Returns:
        Group name or None for root group
    """
    # Find the longest matching group (to handle nested groups correctly)
    matching_groups = [
        g for g in groups if option_name == g or option_name.startswith(g + ".")
    ]

    return max(matching_groups, key=len) if matching_groups else None


def group_to_filename(group_name: str) -> str:
    """
    Convert a group name to a markdown filename.

    Args:
        group_name: Full group name (e.g., 'programs.nixkraken.datetime')

    Returns:
        Filename (e.g., 'datetime.md' or 'profiles/git.md')
    """
    # Remove 'programs.nixkraken.' prefix and handle '.*.' as path separator
    name = group_name.replace("programs.nixkraken.", "").replace(".*.", "/")
    return f"{name}.md"


def extract_scope(description: str) -> tuple[str, Optional[str]]:
    """
    Extract scope information from description and remove the comment.

    Args:
        description: Option description text

    Returns:
        Tuple of (cleaned_description, scope) where scope is 'profile', 'global', or None
    """
    if "<!-- scope: profile -->" in description:
        return description.replace("<!-- scope: profile -->", "").strip(), "profile"
    elif "<!-- scope: global -->" in description:
        return description.replace("<!-- scope: global -->", "").strip(), "global"
    return description, None


def render_option(
    option_name: str, option_data: Dict, is_group: bool = False, is_root: bool = False
) -> str:
    """
    Render an option as markdown.

    Args:
        option_name: Full option name
        option_data: Option data dictionary
        is_group: Whether this option is a group option (affects header level)

    Returns:
        Markdown string
    """
    # Strip 'programs.nixkraken.' prefix
    display_name = option_name.replace("programs.nixkraken.", "")

    if is_root:
        header_level = "###"
    else:
        # Use level 1 header for group options, level 2 for child options
        header_level = "#" if is_group else "##"

    lines = [f"{header_level} {display_name}", ""]

    # Description and scope detection
    description = option_data.get("description", "")

    if description:
        description, scope = extract_scope(description)
        lines.extend([description, ""])

        # Add scope label if present
        if scope == "profile":
            lines.extend(
                [
                    '**Scope:** <Badge type="tip"><i class="fa-solid fa-users"></i> Profile</Badge>',
                    "",
                ]
            )
        elif scope == "global":
            lines.extend(
                [
                    '**Scope:** <Badge type="tip"><i class="fa-solid fa-globe"></i> Global</Badge>',
                    "",
                ]
            )

    # Type
    type_str = option_data.get("type", "unknown type")
    formatted_type = format_type(type_str)
    lines.extend([f"**Type:** {formatted_type}", ""])

    # Default
    default = option_data.get("default", {})
    default_text = default.get("text", "") if isinstance(default, dict) else ""
    if default_text:
        default_text = wrap_with(unwrap(default_text, '"'), "`")
    else:
        default_text = "No default value"
    lines.extend([f"**Default:** {default_text}", ""])

    # Example (only if present)
    example = option_data.get("example", {})
    example_text = example.get("text", "") if isinstance(example, dict) else ""
    if example_text:
        example_text = wrap_with(unwrap(example_text, '"'), "`")
        lines.extend([f"**Example:** {example_text}", ""])

    return "\n".join(lines)


def generate_documentation(json_file: str, output_dir: Optional[Path] = None) -> None:
    """
    Generate markdown documentation from JSON file.

    Args:
        json_file: Path to the JSON file
        output_dir: Output directory for generated files (defaults to current directory)
    """
    # Set output directory
    if output_dir is None:
        output_dir = Path.cwd()
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

    # Load JSON data
    json_path = Path(json_file)
    with json_path.open("r", encoding="utf-8") as f:
        options = json.load(f)

    # Filter to only nixkraken options
    nixkraken_options = {
        k: v for k, v in options.items() if k.startswith("programs.nixkraken.")
    }

    # Discover groups
    groups = discover_groups(nixkraken_options)

    # Group options by their group
    grouped_options = {}
    for option_name, option_data in nixkraken_options.items():
        group = get_group_for_option(option_name, groups)
        group_key = group if group else "root"

        if group_key not in grouped_options:
            grouped_options[group_key] = []
        grouped_options[group_key].append((option_name, option_data))

    # Frontmatter block
    frontmatter = """---
# This file is automatically generated. DO NOT EDIT MANUALLY.
---

"""

    # Generate markdown files
    for group_key, options_list in grouped_options.items():
        is_root = group_key == "root"

        # Determine filename
        filename = "root.md" if is_root else group_to_filename(group_key)

        # Create full filepath with output directory
        filepath = output_dir / filename
        filepath.parent.mkdir(parents=True, exist_ok=True)

        # Generate content
        content = []

        # Add virtual header for root group
        if is_root:
            content.append("## Root options\n")

        for option_name, option_data in options_list:
            # Check if this option is the group itself
            is_group = option_name == group_key
            content.append(render_option(option_name, option_data, is_group, is_root))

        # Write file with frontmatter
        with filepath.open("w", encoding="utf-8") as f:
            f.write(frontmatter)
            f.write("\n".join(content))

        print(f"Generated: {filepath}")


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python generate_docs.py <json_file> [output_dir]")
        sys.exit(1)

    json_file = sys.argv[1]
    output_dir = Path(sys.argv[2]) if len(sys.argv) == 3 else None

    if not Path(json_file).exists():
        print(f"Error: File '{json_file}' not found")
        sys.exit(1)

    generate_documentation(json_file, output_dir)
    print("\nDocumentation generation complete!")
