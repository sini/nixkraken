[doc-caveats]: ../notes/caveats.md#reverted-paid-features
[doc-opt-enable]: https://nicolas-goudry.github.io/nixkraken/options/nixkraken.html#enable
[gitkraken]: https://www.gitkraken.com/git-client
[hm-home-pkgs]: https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages
[oauth]: https://www.oauth.com

# Authentication

Beyond managing [GitKraken][gitkraken] application configuration, NixKraken also provides the `gk-login` utility to authenticate with your GitKraken account without launching the app first. This stores your token so GitKraken starts authenticated on next launch.

This is mainly useful when installing GitKraken for the first time and configuring paid features right away.

As mentioned in the [known caveats][doc-caveats] section, if you configure paid features and launch the app while not authenticated, those features could be disabled or reset to their default values.

> [!IMPORTANT]
>
> `gk-login` writes credentials to the same configuration file and applies the same encryption procedures that GitKraken itself uses.

## Limitations

Currently, only the [OAuth][oauth] flow is supported, with the following providers:

- GitHub
- GitLab
- Bitbucket
- Azure
- Google

## How it works

When NixKraken is [enabled][doc-opt-enable], the `gk-login` package is automatically added to [`home.packages`][hm-home-pkgs], making it available globally for your user.

The only required option is the `--provider` (or `-p`) option, which defines the OAuth provider to use:

| Provider  | Value       |
| --------- | ----------- |
| GitHub    | `github`    |
| GitLab    | `gitlab`    |
| Bitbucket | `bitbucket` |
| Azure     | `azure`     |
| Google    | `google`    |

To start the authentication process, run:

```bash
gk-login -p <provider>
```

The command attempts to start the OAuth flow in your default browser. If this does not work, copy the authentication URL displayed in the terminal and open it manually in your browser.

Complete the authentication inside the browser. When it succeeds, copy the token shown under the `Didn't work?` section:

![Example of a successful OAuth flow result](./assets/oauth-success.png 'Example of a successful OAuth flow result')

Return to the terminal where `gk-login` is running, paste the token (input is hidden), and press <kbd>Enter</kbd>.

That is it! On the next GitKraken launch, you will be authenticated to your account.
