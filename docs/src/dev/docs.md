# Working on the documentation

---

<center>

_“ A documentation about the documentation inside the documentation. ”_

</center>

---

This guide, aimed at contributors working on the documentation available in the [`docs` directory](https://github.com/nicolas-goudry/nixkraken/blob/main/docs), explains how it is structured and built.

## Overview

The documentation is using [mdBook](https://rust-lang.github.io/mdBook/) to generate a static website from the Markdown content located inside the `docs/src` directory and the dynamically generated module options reference pages.

The canonical build path is the Nix derivation, manual builds outside Nix are out of scope here.

A GitHub Actions workflow, available at [`.github/workflows/deploy-docs.yml`](https://github.com/nicolas-goudry/nixkraken/blob/main/.github/workflows/deploy-docs.yml), builds and deploys the website to GitHub Pages.

The `docs` directory defines several files and directories, each with unique responsibilities:

- `book.toml`: [mdBook configuration](#configuration)
- `src`: [mdBook markdown content](#content-authoring)
- `theme`: [mdBook customization](#customization)
- `build-doc.js`: [options documentation builder](#options-documentation-builder) to generate reference documentation pages from the module code
- `default.nix`: [Nix derivation](#nix-derivation) to build the documentation static content

> [!NOTE]
>
> All paths referenced in the rest of this guide are relative to the `docs` directory, unless stated otherwise.

## Content authoring

### Structure

The documentation content is generated from [Markdown](https://www.markdownguide.org/) files located in the `src` directory.

Each of these files is built as a single HTML page and is served at the same URL location as its location in the filesystem, relative to the `src` directory. For example, a page content stored in `src/foo/bar.md` would be served from `/foo/bar.html`.

> [!WARNING]
>
> All pages must appear in the global table of contents (defined by the `src/SUMMARY.md` file) in order to be included in the final build.

#### Topics

To further organize documentation content and improve navigation, we use a concept of "topics" to categorize pages.

Topics are defined as level one headers (`# Header`) inside the `src/SUMMARY.md` file, effectively providing visual separation between documentation categories when rendered in the global table of contents.

Beyond visual separation, this concept also allows us to organize content by topic in `src` subdirectories, as shown by the table below:

| Topic           | Directory         |
| --------------- | ----------------- |
| Getting Started | `getting-started` |
| Important Notes | `notes`           |
| User Guides     | `guides`          |
| Reference       | `options`         |
| Developer Guide | `dev`             |
| Changelog       | `changelog`       |

_For further details about the directory structure and the `src/SUMMARY.md` file, please refer to the [official mdBook documentation](https://rust-lang.github.io/mdBook/format/summary.html)._

#### Generated content

Throughout the documentation, there are multiple special markers which are used to generate content at build time. This process avoids manual maintenance of documentation directly originating from code, effectively avoiding update omissions.

Here is a list of currently used markers:

| Marker           | Location                           | Replaced by                               | Replacement                                                           |
| ---------------- | ---------------------------------- | ----------------------------------------- | --------------------------------------------------------------------- |
| `OPTS_GEN`       | `SUMMARY.md`                       | [Builder](#options-documentation-builder) | List of links to generated option pages                               |
| `GROUPS_GEN`     | `options/nixkraken.md`             | [Builder](#options-documentation-builder) | List of links to generated option groups (non-profile)                |
| `CACHED_COMMITS` | `guides/caching.md`                | [Derivation](#nix-derivation)             | List of nixpkgs cached commits for GitKraken derivation               |
| `OPTIONS_ROOT`   | Module options `description` field | [Derivation](#nix-derivation)             | Path to `src/options` directory, relative to files holding the marker |

> [!NOTE]
>
> Reported marker locations are relative to the `docs/src` directory.

In addition to static content living in the repository, there are also dynamically generated pages for the module options reference. Those pages do not exist in the repository and are only created at build time inside the `src/options` directory.

_For further details on this generation process, refer to the specific section about the [options documentation builder](#options-documentation-builder)._

### Alerts and callouts

The [mdbook-alerts](https://github.com/lambdalisue/rs-mdbook-alerts) preprocessor is enabled, so you can use [GitHub style alert/callout](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) blocks in Markdown content:

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

If there is a need to use images and/or assets in the Markdown content, they should be added in a directory called `assets` and located at the same level as their consumer. For example, if an image is needed in the `src/dev/contributing/docs.md` file, the source images should be stored in the `src/dev/contributing/assets` directory.

Additional assets, like CSS or JavaScript files, should be stored in the `theme` directory and wired via `book.toml`. This is further covered in the [next section](#customization).

## mdBook specifics

### Configuration

mdBook configuration is located in the [`book.toml` file](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/book.toml) and covers:

- general metadata
- preprocessors
- renderers

Beyond general metadata which defines the book title, description, language and so on, and the `mdbook-alerts` preprocessor, there are some configuration of interest for the renderers. Most notably:

- the [`html` renderer](https://rust-lang.github.io/mdBook/format/configuration/renderers.html#html-renderer-options), which defines additional assets (CSS, JS) to load as well as the default sidebar fold level
- the [`linkcheck` renderer](https://github.com/Michael-F-Bryan/mdbook-linkcheck), which ensures that all links (both internal and external) can resolve

_Please refer to the [official mdBook documentation](https://rust-lang.github.io/mdBook/format/configuration/index.html) for further details about configuration options and behavior._

In addition to the `book.toml` file, there is a `book.toml.nix-build.patch` file which is used when building using the [Nix derivation](#nix-derivation). This is required since the Nix build sandbox does not allow network access and the `linkcheck` renderer tries to check external links by default. Therefore, when building, the patch is applied against `book.toml` to disable external links checking (internal links are still validated).

### Customization

mdBook allows to include arbitrary additional CSS and JS files using respectively the `additional-css` and `additional-js` options of the `html` renderer. These settings enable to further customize mdBook behavior without having to write Rust code.

The documentation takes advantage of this to bring table of contents dedicated to the currently rendered page. Implementation-wise, this is heavily inspired by the [mdbook-pagetoc](https://github.com/slowsage/mdbook-pagetoc) plugin, although it uses a completely different rendering.

This feature is implemented using raw [JavaScript](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/js/toc.js) and [CSS](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/css/toc.css) code, which together implement an auto-generated, collapsible table of contents sidebar for documentation pages.

The JavaScript code, responsible for the page TOC generation, is heavily annotated, but here's what it does in short:

- build TOC items
  - scans all in-page headings (`h2-h6`) via their `a.header` anchors
  - extracts their text and generates link elements pointing to each section, with styling according to heading level (`.toc-h2`, `.toc-h3`, etc.) for indentation hierarchy
- insert UI
  - creates a floating hamburger button that toggles the visibility of the TOC dropdown
  - adds accessibility functionality (keyboard navigation with <kbd>Enter</kbd>, automatically closes when scrolling or clicking outside)
  - note that the TOC is only injected if:
    - the page is scrollable
    - the path isn't in the `hideOnPath` list
    - and there's more than one heading

The companion CSS code is responsible for visual presentation of the TOC, specifically tailored to mdBook HTML:

- positions the TOC button in a sticky container floating to the right side of the page content
- defines visual styles of the main `.toc-content` block which holds actual heading links
  - hidden by default
  - visible when `.toc-btn` gains the `toc-btn__open` class
  - links are styled with no underlines, padding for indentation (increasing per heading depth), and color states on hover/focus
- hides the TOC entirely on small screens to avoid overlap with mdBook right navigation bar

Beyond this feature, some more generalist CSS customizations can be found in the [`docs/theme/css/main.css` file](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/theme/css/main.css).

## Options documentation builder

Thanks to the self-describing nature of NixOS module options, we can leverage this information to auto-generate reference documentation for module options.

This is the role of the [`build-doc.js` script](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/build-doc.js), which automatically creates Markdown documentation files from a JSON representation of NixKraken module options .

The script reads this JSON file from command-line arguments to:

- process and categorize options into predefined groups matching known submodules (like `datetime`, `git`, `gpg`, `profiles`, etc. ; this list is defined in the `OPTION_GROUPS` variable inside the script)
- convert each option's metadata (`description`, `type`, `default` value, `examples`) into formatted Markdown documentation

The grouping logic uses pattern matching to determine which category each option belongs to, with special handling for nested `profile` options and a fallback `root` group for ungrouped items.

For each group, the script generates a separate Markdown file in an organized directory structure under `src/options`. Root-level options are appended to the main `src/options/nixkraken.md` file, while profile-specific options (matching the pattern `profiles.*.*`) are placed in the `src/options/profiles` subdirectory.

Each generated file includes formatted sections for each option with its:

- name
- description
- type information (with special formatting for constrained string types that show valid values)
- default values
- optional examples

Every generated documentation page includes a footer with generation timestamp and git revision information (passed through the `GIT_REV` environment variable, see details in the next section), making it clear that the documentation is auto-generated and traceable to a specific codebase version.

## Nix derivation

The Nix derivation, located in the [`default.nix` file](https://github.com/nicolas-goudry/nixkraken/blob/main/docs/default.nix), is the canonical way to build, test and package the documentation as a static site using mdBook content files, customizations and generated Markdown for module options reference.

At its core, this derivation is responsible for generating and providing all the necessary content to build the final documentation from the `docs` source directory, which can then be deployed to a hosting service or served locally.

To build it, use the following command:

```bash
# Using new Nix commands
nix build '.#docs'

# ...or classic Nix commands
nix-build ./docs \
  -I nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz \
  --argstr gitRev $(git rev-parse HEAD)
```

### Providing Git revision

As highlighted by the `nix-build` command above, the derivation accepts an optional `gitRev` argument, which is used to set the `GIT_REV` environment variable used by `build-doc.js` to generate pages footer.

When building using `nix build`, the `gitRev` argument is automatically set to the current Git revision from the root `flake.nix` by using the following expression:

```nix
self.rev or self.dirtyRev or "dirty"
```

`gitRev` defaults to `dirty` when unset.

### Providing JSON module options representation

Since the `build-doc.js` script needs to be provided with a JSON representation of the module options in order to generate the reference documentation, the Nix derivation:

- loosely evaluates (`config._module.check = false`) the actual module code using [`lib.evalModules`](https://nixos.org/manual/nixpkgs/unstable/#module-system-lib-evalModules)
- pass the evaluated module `options` attributes to [`nixosOptionsDoc`](https://github.com/NixOS/nixpkgs/blob/02071814abd873bc55202fe0fd3d8de89225050a/nixos/lib/make-options-doc/default.nix) which generates, among other formats, a JSON representation of the module options

This JSON representation is then passed down to the `build-doc.js` script along with the previously documented `GIT_REV` environment variable to actually generate the reference documentation for module options.

For debugging purposes, here is how to generate the module options JSON representation (run these from the root repository, or adapt the path to `module.nix`):

```bash
# Using new Nix commands
nix build --impure --include nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz --expr 'let pkgs = import <nixpkgs> { }; moduleEval = pkgs.lib.evalModules { modules = [(_: { imports = [ ./module.nix ]; config._module.check = false; })]; }; in (pkgs.nixosOptionsDoc { inherit (moduleEval) options; }).optionsJSON'

# ...or classic Nix commands
nix-build --include nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz --expr 'let pkgs = import <nixpkgs> { }; moduleEval = pkgs.lib.evalModules { modules = [(_: { imports = [ ./module.nix ]; config._module.check = false; })]; }; in (pkgs.nixosOptionsDoc { inherit (moduleEval) options; }).optionsJSON'
```

Once run, the JSON options file will be located in `result/share/doc/nixos/options.json`.

### Replacing special markers

As mentioned in the [generated content section](#generated-content), several markers are consumed by this derivation to generate dynamic documentation content, using the [`substituteInPlace` utility function](https://nixos.org/manual/nixpkgs/stable/#fun-substituteInPlace):

- the `CACHED_COMMITS` marker is replaced by a Markdown list generated from the [GitKraken cached versions](https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/versions.nix)
- the `OPTIONS_ROOT` marker is replaced in every Markdown file (including dynamically generated ones) using the `realpath` command to get the relative path to `src/options` directory

> [!NOTE]
>
> If you're wondering what is the use case for the `OPTIONS_ROOT` marker, it is useful to link to global module options documentation from profile-specific module options documentation.
>
> See [this example](https://github.com/nicolas-goudry/nixkraken/blob/3e3a59565da737ce53ab6c9c8312e55322d2a132/modules/tools/profile-options.nix#L35) to get a better grasp of its use.

### Build phases

The following build phases are implemented:

- `preBuild`: generates dynamic content
- `build`: runs `mdbook build`
- `check`: runs `mdbook test`
- `install`: moves generated HTML content (`book/html`) to derivation output directory (`$out`)
