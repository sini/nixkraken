# Quick Start

Add Nixkraken to your `flake.nix`:

```nix
{
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken";
}
```

Then, enable it in Home Manager configuration:

```nix
{
  programs.nixkraken.enable = true;
}
```
