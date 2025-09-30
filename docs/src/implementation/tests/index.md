# Tests

NixKraken includes an automated test suite to ensure that contributors and users alike can count on a smooth, reproducible experience.

The tests rely on the [NixOS test framework](https://nixos.org/manual/nixos/stable/#sec-nixos-tests), which spins up lightweight virtual machines (VMs) where different NixKraken configurations can be validated. This approach lets us test graphical behavior, NixOS module integration, and system-level interactions, all inside a controlled environment.

> [!WARNING]
>
> Although we aim to test as many configuration outcomes as possible, these automated tests will never be able to cover every possible configuration.
>
> Specifically, we are not currently able to test paid features since the login process is interactive. Hence, we cannot test multi-profile setups beyond Nix validation.

---

- [Running tests](./running.md) \
  _<sub>Learn how to run NixKraken tests.</sub>_

- [Writing tests](./writing.md) \
  _<sub>Contribute to NixKraken by writing new tests or updating existing ones.</sub>_
