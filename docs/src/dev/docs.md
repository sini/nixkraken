[doc-devshell]: ./contributing.md#nix-development-shell
[doc-pkgs]: ./packages/index.md
[gh-docs-alerts]: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts
[gh-pages]: https://pages.github.com
[gitkraken]: https://www.gitkraken.com/git-client
[loc-authoring]: #content-authoring
[loc-config]: #configuration
[loc-custom-css]: #custom-css
[loc-customization]: #customization
[loc-drv]: #nix-derivation
[loc-gen-content]: #generated-content
[loc-gitrev]: #providing-git-revision
[loc-img-title]: #image-title-rendering
[loc-json-representation]: #providing-json-module-options-representation
[loc-local-dev]: #local-development
[loc-opts-builder]: #options-documentation-builder
[loc-page-toc]: #page-dedicated-toc
[markdown]: https://www.markdownguide.org
[mdbook-alerts]: https://github.com/lambdalisue/rs-mdbook-alerts
[mdbook-config]: https://rust-lang.github.io/mdBook/format/configuration/index.html
[mdbook-html-renderer]: https://rust-lang.github.io/mdBook/format/configuration/renderers.html#html-renderer-options
[mdbook-linkcheck]: https://github.com/Michael-F-Bryan/mdbook-linkcheck
[mdbook-pagetoc]: https://github.com/slowsage/mdbook-pagetoc
[mdbook-summary]: https://rust-lang.github.io/mdBook/format/summary.html
[mdbook]: https://rust-lang.github.io/mdBook
[mdn-after-pseudo]: https://developer.mozilla.org/en-US/docs/Web/CSS/::after
[nix-manual-drv]: https://nix.dev/manual/nix/stable/language/derivations.html
[nix-manual-sandbox]: https://nix.dev/manual/nix/stable/command-ref/conf-file#conf-sandbox
[nixos-manual-module-opts]: https://nixos.org/manual/nixos/stable/#sec-option-declarations
[nixpkgs-manual-evalmodules]: https://nixos.org/manual/nixpkgs/stable/#module-system-lib-evalModules
[nixpkgs-manual-substituteinplace]: https://nixos.org/manual/nixpkgs/stable/#fun-substituteInPlace
[nixpkgs-mk-opts-doc]: https://github.com/NixOS/nixpkgs/blob/02071814abd873bc55202fe0fd3d8de89225050a/nixos/lib/make-options-doc/default.nix
[options-root-marker-usage]: https://github.com/search?q=repo%3Anicolas-goudry%2Fnixkraken+lang%3ANix+OPTIONS_ROOT+path%3A%2F%5Emodules%5C%2F%2F&type=code
[repo-action-deploy]: https://github.com/nicolas-goudry/nixkraken/blob/main/.github/workflows/deploy-docs.yml
[repo-booktoml-patch]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/book.toml.nix-build.patch
[repo-booktoml]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/book.toml
[repo-build-doc-script]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/build-doc.js
[repo-docs-drv]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/default.nix
[repo-docs-root]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs
[repo-gitkraken-versions]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/versions.nix
[repo-main-css]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/css/main.css
[repo-summary]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/src/SUMMARY.md
[repo-themes]: https://github.com/nicolas-goudry/nixkraken/blob/main/themes
[repo-toc-css]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/css/toc.css
[repo-toc-js]: https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/js/toc.js

# Working on the documentation

---

<center>

_“ A documentation about the documentation inside the documentation. ”_

</center>

---

This guide, aimed at contributors working on the documentation available in the [`docs` directory][repo-docs-root], explains how it is structured and built.

## Overview

The documentation is using [mdBook][mdbook] to generate a static website from the [Markdown][markdown] content located inside the `docs/src` directory and the [dynamically generated module options reference pages][loc-opts-builder].

The canonical build path uses a [Nix derivation][nix-manual-drv], manual builds outside Nix are out of scope here.

A GitHub Actions workflow, available at [`.github/workflows/deploy-docs.yml`][repo-action-deploy], builds and deploys the website to [GitHub Pages][gh-pages].

The `docs` directory defines several files and directories, each with unique responsibilities:

- `book.toml`: [mdBook configuration][loc-config]
- `src`: [mdBook markdown content][loc-authoring]
- `theme`: [mdBook customization][loc-customization]
- `build-doc.js`: [options documentation builder][loc-opts-builder] to generate reference documentation pages from the module code
- `default.nix`: [Nix derivation][loc-drv] to build the documentation static content

> [!NOTE]
>
> All paths referenced in the rest of this guide are relative to the `docs` directory, unless stated otherwise.

## Local development

To serve the documentation website locally, for development purposes, run the following command:

```bash
# From repository's root
mdbook serve docs
```

```bash
# ...or from the docs directory
mdbook serve
```

The documentation will be served at: `http://localhost:3000`.

Any change to the documentation files ([content][loc-authoring], [configuration][loc-config] and [customization][loc-customization]) will trigger a page reload.

> [!NOTE]
>
> The `mdbook` command is available if the [Nix development shell][doc-devshell] is enabled.
>
> Otherwise, it has to be available globally.

## Content authoring

### Structure

The documentation content is generated from [Markdown][markdown] files located in the `src` directory.

Each of these files is built as a single HTML page and is served at the same URL location as its location in the filesystem, relative to the `src` directory. For example, a page content stored in `src/foo/bar.md` would be served from `/foo/bar.html`.

> [!WARNING]
>
> All pages must appear in the global table of contents (defined by the [`src/SUMMARY.md` file][repo-summary]) in order to be included in the final build.

#### Topics

To further organize documentation content and improve navigation, we use a concept of "topics" to categorize pages.

Topics are defined as level one headers (`# Header`) inside the `src/SUMMARY.md` file, effectively providing visual separation between documentation categories when rendered in the global table of contents.

Beyond visual separation, this concept also allows us to organize content by topic inside subdirectories of `src`, as shown by the table below:

| Topic           | Directory         |
| --------------- | ----------------- |
| Developer Guide | `dev`             |
| Getting Started | `getting-started` |
| User Guides     | `guides`          |
| Important Notes | `notes`           |
| Reference       | `options`         |

_For further details about the directory structure and the `src/SUMMARY.md` file, please refer to the [official mdBook documentation][mdbook-summary]._

#### Generated content

Throughout the documentation, there are multiple special markers which are used to generate content at build time. This process avoids manual maintenance of documentation directly originating from code, effectively avoiding update omissions.

Here is a list of currently used markers:

| Marker               | Location                           | Replaced by                 | Replacement                                                           |
| -------------------- | ---------------------------------- | --------------------------- | --------------------------------------------------------------------- |
| `CACHED_COMMIT_LIST` | `guides/caching.md`                | [Derivation][loc-drv]       | List of nixpkgs cached commits                                        |
| `GK_<pkg>_USAGE`     | `dev/packages`                     | [Derivation][loc-drv]       | Usage output of `<pkg>` command                                       |
| `GROUPS_GEN`         | `options/nixkraken.md`             | [Builder][loc-opts-builder] | List of links to top-level option groups                              |
| `OPTS_GEN`           | `SUMMARY.md`                       | [Builder][loc-opts-builder] | List of links to generated option pages                               |
| `OPTIONS_ROOT`       | Module options `description` field | [Derivation][loc-drv]       | Path to `src/options` directory, relative to files holding the marker |
| `THEMES_LIST`        | `guides/theming.md`                | [Derivation][loc-drv]       | List of bundled themes for [GitKraken][gitkraken]                     |

> [!NOTE]
>
> Reported marker locations are relative to the `docs/src` directory.

In addition to static content living in the repository, there are also dynamically generated pages for the module options reference. Those pages do not exist in the repository and are only created at build time inside the `src/options` directory.

_For further details on this generation process, refer to the specific section about the [options documentation builder][loc-opts-builder]._

### Alerts and callouts

The [mdbook-alerts][mdbook-alerts] preprocessor is enabled, so you can use [GitHub style alert/callout][gh-docs-alerts] blocks in Markdown content:

> [!NOTE]
> Useful information that users should know, even when skimming content.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

### Images and assets

If there is a need to use images and/or assets, they should be added in a directory called `assets` and located at the same level as their consumer. For example, if an image is needed in the `src/dev/contributing/docs.md` file, the source images should be stored in the `src/dev/contributing/assets` directory.

Additional assets, like CSS or JavaScript files, should be stored in the `theme` directory and wired via `book.toml`. This is further covered in the [mdBook customization section][loc-customization].

## mdBook specifics

### Configuration

mdBook configuration is located in the [`book.toml` file][repo-booktoml] and covers:

- general metadata
- preprocessors
- renderers

Beyond general metadata which defines the book title, description, language and so on, and the `mdbook-alerts` preprocessor, there are some configuration of interest for the renderers. Most notably:

- the [`html` renderer][mdbook-html-renderer], which defines additional assets (CSS, JS) to load as well as the default sidebar fold level
- the [`linkcheck` renderer][mdbook-linkcheck], which ensures that all links (both internal and external) can resolve

_Please refer to the [official mdBook documentation][mdbook-config] for further details about configuration options and behavior._

### Customization

mdBook allows to include arbitrary additional CSS and JS files using respectively the `additional-css` and `additional-js` [options of the `html` renderer][mdbook-html-renderer]. These settings enable to further customize mdBook behavior without having to write Rust code.

The documentation takes advantage of this to introduce several custom behaviors to mdBook:

- [CSS customizations][loc-custom-css]
- [page-dedicated table of contents][loc-page-toc]
- [image title rendering][loc-img-title]

#### Custom CSS

Some [minor CSS customizations][repo-main-css] are brought:

- custom horizontal rule (`<hr/>` element)
- left-aligned tables
- missing gap fix between alerts and tables
- images with rounded corners and borders
- center-aligned images

#### Page-dedicated TOC

This feature implements an auto-generated, collapsible and floating table of contents for documentation pages.

Implementation-wise, this is heavily inspired by the [mdbook-pagetoc][mdbook-pagetoc] plugin, although it uses a completely different rendering.

The [JavaScript code][repo-toc-js], responsible for the page TOC generation, is heavily annotated, but here is what it does in short:

- build TOC items
  - scans all in-page headings (`h2-h6`) via their `a.header` anchors
  - extracts their text and generates link elements pointing to each section, with styling according to heading level (`.toc-h2`, `.toc-h3`, etc.) for indentation hierarchy
- insert UI
  - creates a floating hamburger button that toggles the visibility of the TOC dropdown
  - adds accessibility functionality
    - keyboard navigation with support for <kbd>Enter</kbd> and <kbd>Esc</kbd>
    - automatically closes when scrolling or clicking outside
  - note that the TOC is only injected if:
    - the page is scrollable
    - the path is not in the `hideOnPath` list
    - and there is more than one heading

The [companion CSS code][repo-toc-css] is responsible for visual presentation of the TOC, specifically tailored to mdBook HTML:

- positions the TOC button in a sticky container floating to the right side of the page content
- defines visual styles of the main `.toc-content` block which holds actual heading links
  - hidden by default
  - visible when `.toc-btn` gains the `toc-btn__open` class
  - links are styled with no underlines, padding for indentation (increasing per heading depth), and color states on hover/focus
- hides the TOC entirely on small screens to avoid overlap with mdBook right navigation bar

#### Image title rendering

This feature renders image titles as an actual element in the DOM, rather than only relying on the `title` attribute shown on image hover.

It is implemented using some JavaScript code which discovers all images with a `title` attribute and copies it to a new `data-title` attribute. Then, a few line of CSS are responsible for rendering the title below the actual image, using the [`after` pseudo-element][mdn-after-pseudo].

Example:

```md
![](https://cataas.com/cat 'A random cat image')
```

![](https://cataas.com/cat 'A random cat image')

## Options documentation builder

Thanks to the self-describing nature of [NixOS module options][nixos-manual-module-opts], we can leverage this information to auto-generate reference documentation for module options.

This is the role of the [`build-doc.js` script][repo-build-doc-script], which automatically creates [Markdown][markdown] documentation files from a [JSON representation of NixKraken module options][loc-json-representation].

The script reads this JSON file from command-line arguments to:

- process and categorize options into predefined groups matching known submodules (like `datetime`, `git`, `gpg`, `profiles`, etc. ; this list is defined in the `OPTION_GROUPS` variable inside the script)
- convert each option's metadata (`description`, `type`, `default` value, `examples`) into formatted Markdown documentation

The grouping logic uses pattern matching to determine which category each option belongs to, with special handling for nested `profile` options and a fallback `root` group for ungrouped items.

For each group, the script generates a separate Markdown file in an organized directory structure under `src/options`. Root-level options are appended to the main `src/options/nixkraken.md` file, while profile-specific options (matching the pattern `profiles.*.*`) are placed in the `src/options/profiles` subdirectory.

```plain
src/options
├── datetime.md
├── git.md
├── gpg.md
├── graph.md
├── nixkraken.md
├── notifications.md
├── profiles
│   ├── git.md
│   ├── gpg.md
│   ├── graph.md
│   ├── ssh.md
│   ├── tools.md
│   ├── ui.md
│   └── user.md
├── profiles.md
├── ssh.md
├── tools.md
├── ui.md
└── user.md
```

Each generated file includes formatted sections for each option with its:

- name
- description
- type information (with special formatting for constrained string types that show valid values)
- default values
- optional examples

Every generated documentation page includes a footer with generation timestamp and git revision information (passed through the `GIT_REV` environment variable, see details in the [dedicated section][loc-gitrev]), making it clear that the documentation is auto-generated and traceable to a specific codebase version.

## Nix derivation

The [Nix derivation][nix-manual-drv], located in the [`default.nix` file][repo-docs-drv], is the canonical way to build, test and package the documentation as a static site using [mdBook][mdbook].

At its core, this derivation is responsible for generating and providing all the necessary content to build the final documentation from the `docs` source directory, which can then be deployed to a hosting service or served locally.

To build it, use the following command:

```bash
# Using new Nix commands
nix build '.#docs'
```

```bash
# ...or classic Nix commands
nix-build ./docs \
  -I nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz \
  --argstr gitRev $(git rev-parse HEAD)
```

### Providing Git revision

As highlighted by the `nix-build` command above, the derivation accepts an optional `gitRev` argument, which is used to set the `GIT_REV` environment variable used by the [options documentation builder][loc-opts-builder] to generate pages footer.

When building using `nix build`, the `gitRev` argument is automatically set to the current Git revision from the root `flake.nix` by using the following expression:

```nix
self.rev or self.dirtyRev or "dirty"
```

`gitRev` defaults to `dirty` when unset.

### Providing JSON module options representation

Since the [options documentation builder][loc-opts-builder] needs to be provided with a JSON representation of the module options in order to generate the reference documentation, the Nix derivation:

- loosely evaluates (`config._module.check = false`) the actual module code using [`lib.evalModules`][nixpkgs-manual-evalmodules]
- pass the evaluated module `options` attributes to [`nixosOptionsDoc`][nixpkgs-mk-opts-doc] which generates, among other formats, a JSON representation of the module options

This JSON representation is then passed down to the options documentation builder along with the previously documented [`GIT_REV` environment variable][loc-gitrev] to actually generate the reference documentation for module options.

For debugging purposes, here is how to generate the module options JSON representation (run these from the root repository, or adapt the path to `module.nix`):

```bash
# Using new Nix commands
nix build --impure --include nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz --expr 'let pkgs = import <nixpkgs> { }; moduleEval = pkgs.lib.evalModules { modules = [(_: { imports = [ ./module.nix ]; config._module.check = false; })]; }; in (pkgs.nixosOptionsDoc { inherit (moduleEval) options; }).optionsJSON'
```

```bash
# ...or classic Nix commands
nix-build --include nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz --expr 'let pkgs = import <nixpkgs> { }; moduleEval = pkgs.lib.evalModules { modules = [(_: { imports = [ ./module.nix ]; config._module.check = false; })]; }; in (pkgs.nixosOptionsDoc { inherit (moduleEval) options; }).optionsJSON'
```

Once run, the JSON options file will be located in `result/share/doc/nixos/options.json`.

### Replacing special markers

As mentioned in the [generated content section][loc-gen-content], several markers are consumed by this derivation to generate dynamic documentation content, using the [`substituteInPlace` utility function][nixpkgs-manual-substituteinplace]:

- the `CACHED_COMMIT_LIST` marker is replaced by a Markdown list generated from the [GitKraken cached versions][repo-gitkraken-versions]
- the `GK_<pkg>_USAGE` markers are replaced by running [helper packages][doc-pkgs] with the `--help` flag and using the output as replacement
- the `OPTIONS_ROOT` marker is replaced in every Markdown file (including dynamically generated ones) using the `realpath` command to get the relative path to `src/options` directory
- the `THEMES_LIST` marker is replaced by a Markdown table describing all [bundled themes][repo-themes]

> [!NOTE]
>
> If you are wondering what is the use case for the `OPTIONS_ROOT` marker, it is useful to link to global module options documentation from profile-specific module options documentation.
>
> See [these examples][options-root-marker-usage] to get a better grasp of its use.

### Patching mdBook configuration

[mdBook's configuration][mdbook-config], stored in [`book.toml`][repo-booktoml], is only intended to be used for [local development][loc-local-dev].

This is due to the fact that [mdbook-linkcheck][mdbook-linkcheck] is configured to check external links, which is not compatible with [sandboxed Nix builds][nix-manual-sandbox]. Therefore, there is a patch file stored in [`book.toml.nix-build.patch`][repo-booktoml-patch] which is responsible for updating the configuration to make it suitable for use.

This patch does two things:

1. Disable checking external links

   Since the Nix build sandbox does not allow network access, we have to disable checking external links to avoid build failures.

2. Enable checking internal links to generated content

   By default, internal links to [generated content][loc-gen-content] are not checked, since such content does not exist when building outside the Nix derivation.\
   When building the Nix derivation, this content is available and we must therefore check links to them.

### Build phases

The following build phases are implemented:

- `preBuild`: generates dynamic content
- `build`: runs `mdbook build`
- `check`: runs `mdbook test`
- `install`: moves generated HTML content (`book/html`) to derivation output directory (`$out`)
