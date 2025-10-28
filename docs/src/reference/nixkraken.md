[doc-examples]: ../guide/getting-started/config-examples.md
[doc-profiles]: ../guide/user/profiles.md
[doc-opt-profiles]: ./profiles.md

# Options Reference

All NixKraken options are available under the `programs.nixkraken` attribute.

This documentation provides a complete reference for every available option. For practical, real-world examples, refer to the [configuration examples][doc-examples].

## Groups

Options are organized into logical groups exposed as children attributes to `programs.nixkraken`.

For example, options from the [`graph` group](./graph.md) are available at `programs.nixkraken.graph`.

## Scopes

Most options in GitKraken applies to a given profile, but some of them are global to the application and will therefore apply to all profiles.

For a better discovery of options scope, we document them using the following badges:

- <Badge type="tip"><i class="fa-solid fa-globe"></i> Global</Badge> options apply globally
- <Badge type="tip"><i class="fa-solid fa-users"></i> Profile</Badge> options apply to a specific profile

::: tip

Profile options outside the [`profiles` group][doc-opt-profiles] apply to the default profile **and** additional profiles, unless overridden.

Refer to the [profiles guide][doc-profiles] for further details on profile inheritance.

:::
