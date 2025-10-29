[doc-auth]: ../user/auth.md
[doc-caching]: ../user/caching.md
[doc-pkg-login]: ../../contrib/pkgs/login.md
[doc-pkgs]: ../../contrib/pkgs/intro.md
[gh-nixpkgs-fetchurl-issue]: https://github.com/NixOS/nixpkgs/issues/156930
[gitkraken]: https://www.gitkraken.com/git-client
[hm-opt-homefile]: https://nix-community.github.io/home-manager/options.xhtml#opt-home.file
[hm]: https://nix-community.github.io/home-manager
[nix-manual-language]: https://nix.dev/manual/nix/stable/language/syntax.html

# Known caveats

## Reverted Paid Features

There have been reports of paid features configuration being reverted by the app on the first launch due to the user being signed out of their account.

Although users can login to their [GitKraken][gitkraken] account from within the application, **we recommend [using the dedicated process][doc-auth] to sign in with GitKraken** using the [`gk-login` package][doc-pkg-login].

The security implications of using this authentication process are the same as using those available within the application, since it is replicating the code used by GitKraken.

::: tip **Key takeaway**

To prevent paid features to be reverted on first launch, use `gk-login`.

:::

## Mutability

Although NixKraken allows to configure GitKraken using [Nix language][nix-manual-language], the resulting configuration **is not immutable**.

Contrary to lots of other application modules provided by [Home Manager][hm], NixKraken does not use Nix capabilities to write the configuration file (usually through [`home.file` option][hm-opt-homefile]).

This is due to GitKraken using the configuration files to store application state alongside options. Therefore, if the configuration files were not writable, the application would fail to work as expected.

The module instead uses [various Bash scripts][doc-pkgs] to safely update the configuration files without overwriting application state.

This also means that there can be a **configuration drift between the application and the Nix code**. This is a known issue which will require users to **refrain updating the configuration in-app** and instead use NixKraken options.

::: tip **Key takeaway**

To avoid configuration drift, always make changes to the Nix configuration, not in the GitKraken UI.

**Let NixKraken be the single source of truth for GitKraken settings.**

:::

## Long Installation Time

Because GitKraken is closed source, **end users will always have to "build" the package** (by _build_, we mean to retrieve the artifacts and patch them for Nix). Although this process is usually not very long, it is still longer than fetching a pre-built binary.

Plus, there have been reports of "stuck" builds in the past. This is most often due to a combination of several factors:

- a slow internet connection
- GitKraken's artifacts being 200MB+
- [`fetchUrl` not outputting its download progress][gh-nixpkgs-fetchurl-issue]

::: tip **Key takeaway**

To dramatically speed up the installation process, we highly recommend to **[setup NixKraken's binary cache][doc-caching]**.

:::
