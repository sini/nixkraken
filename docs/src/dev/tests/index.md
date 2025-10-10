[doc-running]: ./running.md
[doc-writing]: ./writing.md
[nixos-manual-modules]: https://nixos.org/manual/nixos/stable/#sec-writing-modules
[nixos-manual-options]: https://nixos.org/manual/nixos/stable/#sec-option-types
[nixos-manual-tests]: https://nixos.org/manual/nixos/stable/#sec-nixos-tests
[wikipedia-virtual-machine]: https://en.wikipedia.org/wiki/Virtual_machine

# Tests

NixKraken includes an automated test suite to ensure that contributors and users alike can count on a smooth, reproducible experience.

The tests rely on the [NixOS test framework][nixos-manual-tests], which spins up lightweight [virtual machines][wikipedia-virtual-machine] (VMs) where different NixKraken configurations can be validated. This approach lets us test graphical behavior, [NixOS module][nixos-manual-modules] integration, and system-level interactions, all inside a controlled environment.

> [!WARNING]
>
> Although we aim to test as many configuration outcomes as possible, these automated tests will never be able to cover every possible configuration.
>
> Specifically, we are not currently able to test paid features since the login process is interactive. Hence, we cannot test multi-profile setups beyond [Nix options][nixos-manual-options] validation.

---

- [Running tests][doc-running] \
  _<sub>Learn how to run NixKraken tests.</sub>_

- [Writing tests][doc-writing] \
  _<sub>Contribute to NixKraken by writing new tests or updating existing ones.</sub>_
