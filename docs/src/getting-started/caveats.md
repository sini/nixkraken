# Caveats

## Reverted paid features

There has been reports of paid features configuration being reverted by the app on the first launch due to the user being signed out of their account.

Although users can login to their GitKraken account from within the application, **we recommend using the [`gk-login` package](../implementation/packages/login.md)** — which comes with NixKraken — **to sign in with GitKraken**.

`gk-login` currently supports signing in to GitKraken through the following OAuth providers:

- GitHub
- GitLab
- BitBucket
- Azure
- Google

The security implications of using `gk-login` are the same as using the application, since it is replicating the code used by GitKraken. Also, the [code can easily be reviewed](https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/login/script.sh) and is thoroughly documented.

> ⚡ **Key takeaway**
>
> To prevent paid features to be reverted on first launch, use `gk-login`.

## Mutability

Although NixKraken allows to configure GitKraken using Nix language, the resulting configuration **is not immutable**.

Contrary to lots of other application modules provided by Home Manager, NixKraken does not use Nix capabilities to write the configuration file.

This is due to GitKraken using the configuration files to store application state alongside options. Therefore, if the configuration files were not writable, the application would fail to work as expected.

The module instead uses [various Bash scripts](../implementation/packages/index.md) to safely update the configuration files without overwriting application state.

This also means that there can be a **configuration drift between the application and the Nix code**. This is a known issue which will require users to **refrain updating the configuration in-app** and instead use NixKraken options.

> ⚡ **Key takeaway**
>
> To avoid configuration drift, always make changes to the Nix configuration, not in the GitKraken UI.
>
> **Let NixKraken be the single source of truth for GitKraken settings.**

## Long installation time

GitKraken being closed source, **end users will always have to “build” the package** (by _build_, we mean to retrieve the artifacts and patch them for Nix). Although this process is usually not very long, it is still longer than fetching a pre-built binary.

Plus, there has been reports of "stuck" builds in the past. This is most often due to a combination of several factors:

- a slow internet connection
- GitKraken's artifacts being 200MB+
- [`fetchUrl` not outputting its download progress](https://github.com/NixOS/nixpkgs/issues/156930)

> ⚡ **Key takeaway**
>
> To dramatically speed up the installation process, we highly recommend to **[setup NixKraken's binary cache](./caching.md)**.
