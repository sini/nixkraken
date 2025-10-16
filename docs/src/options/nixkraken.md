[doc-examples]: ../getting-started/examples.md
[doc-profiles]: ../guides/profiles.md
[doc-opt-profiles]: ./profiles.md

# Module options

All NixKraken options are available under the `programs.nixkraken` attribute.

This section provides a complete reference for every available option. For practical, real-world examples, refer to the [configuration examples][doc-examples].

## Groups

Options are organized into logical groups exposed as children attributes to `programs.nixkraken` (ie. the `graph` options are available at `programs.nixkraken.graph`).

Find below the list of available groups:

<!-- GROUPS_GEN -->

Additionally, groups can be found in the left navigation menu.

## Scopes

Most options in GitKraken applies to a given [profile][doc-profiles], but some of them are global to the application and will therefore apply to all profiles.

For a better discovery of options scope, we document their scope using emoji icons:

- 🌐: option applies globally
- 👤: option applies to a specific profile

> [!NOTE]
>
> Unless an option is child of the [`profiles` group][doc-opt-profiles], it will apply to the default profile.

## Root options

The options below are available under `programs.nixkraken`.
