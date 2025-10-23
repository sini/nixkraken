[doc-examples]: ../guide/getting-started/config-examples.md
[doc-profiles]: ../guide/user/profiles.md
[doc-opt-profiles]: ./profiles.md

# Options Reference

All NixKraken options are available under the `programs.nixkraken` attribute.

This section provides a complete reference for every available option. For practical, real-world examples, refer to the [configuration examples][doc-examples].

## Groups

Options are organized into logical groups exposed as children attributes to `programs.nixkraken` (ie. the `graph` options are available at `programs.nixkraken.graph`).

Find below the list of available groups:

<!-- GROUPS_GEN -->

Additionally, groups can be found in the sidebar.

## Scopes

Most options in GitKraken applies to a given profile, but some of them are global to the application and will therefore apply to all profiles.

For a better discovery of options scope, we document them using emoji icons:

- 🌐 options apply globally
- 👤 options apply to a specific profile

::: info

Unless a 👤 option is child of the [`profiles` group][doc-opt-profiles], it will apply to the default profile and additional profiles, unless overridden.

Refer to the [profiles guide][doc-profiles] for further details on profile inheritance.

:::
