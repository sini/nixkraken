[doc-config-discovery]: ./config-discovery.md
[nixpkgs-manual-callpackage]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.callPackageWith

# Deep JSON Differ

This utility is a Python program that compares two JSON files and reports structural differences with full key paths.

It works by recursively traversing nested objects and arrays, identifying additions (`[ADD]`), deletions (`[DEL]`), and modifications (`[MOD]`) with full key paths to show exactly where changes occurred.

## Usage

### Run

This utility is not meant to be run directly but rather as a dependency of another utility, like the config discovery.

However, since it does not have any dependencies, it can be run with plain `python`:

```sh
python3 script.py <file1> <file2>
```

**Requirements:** Python 3.x _(no external dependencies)_

### Depend

To use this in a Nix file, use the [`callPackage` function][nixpkgs-manual-callpackage]:

```nix
{ pkgs, ... }:

let
  deep-json-diff = pkgs.callPackage ./gitkraken/utils/deep-json-diff { };
in
{
  # ...
}
```

## Why This Utility?

Standard diff tools usually only outputs the section of the file that changed, sometimes and often losing the JSON context when differences are found deeply nested in objects.

This utility instead outputs the full key paths that changed along with changes that occurred:

```plain
  [MOD] webConfig.lastUpdatedAt: 2025-10-28T18:59:04.885Z >>> 2025-10-28T18:59:30.021Z
  [MOD] commits.showAll: False >>> True
  [MOD] commits.enableCommitsLazyLoading: False >>> True
  [MOD] activityLogLevel: 1 >>> 2
  [MOD] keepGitConfigInSyncWithProfile: False >>> True
  [ADD] ai = {'enabled': True}
  [ADD] ai.customProvider = OpenAI
  [ADD] ai.providers = {'GitKraken': {'commitMessage': {'model': 'openai:gpt-5-nano'}}}
  [MOD] ai.providers.GitKraken.commitMessage.model: openai:gpt-5-nano >>> gemini:gemini-2.0-flash
```

The main purpose of this utility is to be used with the [config discovery utility][doc-config-discovery].
