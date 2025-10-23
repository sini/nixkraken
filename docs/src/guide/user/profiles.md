[doc-group-opts]: ../../reference/nixkraken.md#group-options
[doc-opts-profiles]: ../../reference/profiles.md
[doc-root-opts]: ../../reference/nixkraken.md#root-options
[gitkraken]: https://www.gitkraken.com/git-client

# Profiles

In [GitKraken][gitkraken], profiles are used to manage different app preferences, Tabs and Git config settings. This comes handy when working for several organizations, or to separate work and personal configurations.

There are two _"types"_ of profiles in GitKraken, which can both be configured using NixKraken:

- default profile, available out-of-the-box
- additional profiles, available with a paid license

::: warning

**Unlicensed users can only use the default profile**, and can only use GitKraken with public or remote-less repositories.

Although NixKraken will not prevent you from configuring additional profiles if you do not own a paid license, they will not be available in the application.

:::

## Default profile

The default profile is configured using all [group options][doc-group-opts], excluding the `profiles` group.

Additionally, there are [root options][doc-root-opts] which only apply to the default profile:

- `defaultProfile.name`, to set the profile name
- `defaultProfile.icon`, to set the profile avatar

## Additional profiles

Additional profiles are configured using the [profiles group][doc-opts-profiles], which will inherit all options from the default profile. Options from additional profiles will always have precedence over default profile options.

The profiles group reuses most (but not all) of the groups used by the default profile, under the `programs.nixkraken.profiles` option. This option is a list of attribute sets defining profile-specific configuration.

Find below an example of a multi-profiles configuration:

<!-- #region profiles_inheritance -->

```nix
{
  programs.nixkraken = {
    enable = true;

    # Define options for default profile
    git.defaultBranch = "main";
    ui.theme = "system";

    user = {
      name = "Somebody";
      email = "somebody@example.com";
    };

    # Define additional work profile
    profiles = [
      {
        name = "Work";

        # Override options from default profile
        user.email = "somebody@company.com";
        git.defaultBranch = "master";
        ui.theme = "light";

        # Configure profile-specific options
        gpg = {
          format = "openpgp";
          signingKey = "D7229043384BCC60326C6FB9D8720D957C3D3074";
          signCommits = true;
          signTags = true;
        };
      }
    ];
  };
}
```

<!-- #endregion profiles_inheritance -->
