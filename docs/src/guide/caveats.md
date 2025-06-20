# Caveats

## Reverted paid features

There has been reports of paid features configuration being reverted by the app on the first launch due to the user being signed out of their account.

Although users can login to their GitKraken account from within the application, **we recommend using the [`gk-login` package](../implementation/packages/login.md)** — which comes with Nixkraken — **to sign in with GitKraken**.

`gk-login` currently supports signing in to GitKraken through the following OAuth providers:

- GitHub
- GitLab
- BitBucket
- Azure
- Google

The security implications of using `gk-login` are the same as using the application, since it is replicating the code used by GitKraken. Also, the [code can easily be reviewed](https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/login/script.sh) and is thoroughly documented.

## Mutability

Although Nixkraken allows to configure GitKraken using Nix language, the resulting configuration **is not immutable**.

Contrary to lots of other application modules provided by Home Manager, Nixkraken does not use Nix capabilities to write the configuration file.

This is due to GitKraken using the configuration files to store application state alongside options. Therefore, if the configuration files were not writable, the application would fail to work as expected.

The module instead uses [various Bash scripts](../implementation/packages/index.md) to safely update the configuration files without overwriting application state.

This also means that there can be a **configuration drift between the application and the Nix code**. This is a known issue which will require users to **refrain updating the configuration in-app** and instead use Nixkraken options.

## Long installation time

Nixkraken uses a pinned version of [nixpkgs](https://github.com/nixos/nixpkgs) to set the default version of the GitKraken package to a given version. Therefore, on the first module install - and whenever the GitKraken version is updated by the module - the package will be built by the system.

This process is usually not very long since GitKraken is not built from sources (it being closed source), however there has been reports of "stuck" installations/builds. This is most often due to a bad internet connection and the fact that GitKraken's archive is around 200MB (whatever the platform is).

To speed up the installation process, specify the [`programs.nixkraken.package`](../options/nixkraken.md#package) option from your nixpkgs channel or Flake input.

> [!WARNING]
> To prevent incompatibility issues, make sure to use a nixpkgs revision which has the correct GitKraken version for the module.
>
> Read more about [compatibility considerations](./install/considerations.md#compatibility).
