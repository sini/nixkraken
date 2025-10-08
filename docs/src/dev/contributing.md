# Contributing

Contributions are welcome across documentation, [module options](../options/nixkraken.md), [helper packages](./packages/index.md), [tests](./tests/index.md), compatibility work and every other aspects related to NixKraken.

Development occurs solely on the [official GitHub repository](https://github.com/nicolas-goudry/nixkraken).

## Before starting

### Don't waste your time

Please make sure to read the current documentation as a whole before considering to contribute, something you're planning to contribute to may already be available.

Also take a look at currently [open issues](https://github.com/nicolas-goudry/nixkraken/issues) and [pull requests](https://github.com/nicolas-goudry/nixkraken/pulls) before starting to work on a feature or bug fix, as someone else may already be planning to or has already started working on something similar.

### Conform to the code of conduct

Read our [code of conduct](https://github.com/nicolas-goudry/nixkraken/blob/main/CODE_OF_CONDUCT.md) and conform to it in all your interactions with others working on the project. However, don't stress yourself too much over this, everyone can make mistakes as long as they acknowledge and correct them.

### Be polyglot?

NixKraken uses various languages, with the predominant one being the [Nix language](https://nixos.org).

Additionally, we use a fair bit of [Bash scripting](https://www.gnu.org/software/bash/) for [helper packages](./packages/index.md), some [Python](https://python.org) for [automated tests](./tests/index.md) and some [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript), [HTML](https://developer.mozilla.org/en-US/docs/Web/HTML) and [CSS](https://developer.mozilla.org/en-US/docs/Web/CSS) for the documentation.

Contributors are expected to be familiar, to some varying extent, with the following languages and tools, depending on the topic involved:

- **Module development:** Nix language, nixpkgs, NixOS, [Home Manager](https://nix-community.github.io/home-manager/index.xhtml), Bash scripting, JavaScript, GitKraken
- **Module tests:** Nix language, nixpkgs, NixOS, Python, GitKraken
- **Helper packages:** Nix language, nixpkgs, Bash scripting, JSON, GitKraken
- **GitKraken caching:** Nix language, nixpkgs, [Garnix](https://garnix.io)
- **Documentation:** Nix language, nixpkgs, JavaScript, HTML, CSS, [Markdown](https://www.markdownguide.org/), [mdBook](https://rust-lang.github.io/mdBook/)

Although this list could look quite daunting, don't run away yet. You will most likely be doing great just knowing a small bit of any of these, and can only get better at them while working on NixKraken.

### Get familiar with our Git workflow

As noted in the [compatibility section](../notes/compatibility.md), we use a variety of branches to conduct work on NixKraken:

- `main`: this is the development branch, where all new (potentially unstable) features live
- `stable`: this is a "dummy" branch which tracks the latest release branch commit
- release branches: these are branches named after the GitKraken version they are known to be compatible with

When contributing to NixKraken, you will either want to add something new or fix something broken. Your contribution could either target a specific release branch, or the development branch, or both. In the case of a fix or feature targeting both development and release branch(es), we prefer to first integrate the changes into the development branch, and only then backport them to the release branch(es).

Please find below the lifecycle of a contribution to NixKraken:

1. [Fork the repository](https://github.com/nicolas-goudry/nixkraken/fork)
2. Work on your feature/bugfix in whatever branch you wish
3. Commit your changes using [atomic commits](https://en.wikipedia.org/wiki/Atomic_commit#Revision_control) and following [conventional commit style](https://www.conventionalcommits.org/en/v1.0.0/#specification)
4. Open a pull request to either the `main` branch or a specific release branch
5. PR is merged
6. Backport to release branch(es) happens, if relevant
7. `stable` branch is updated, if relevant

> [!NOTE]
>
> We use [convco](https://convco.github.io) to enforce conventional commits.

## Repository layout

Find below a root overview of the repository:

```bash
.
├── .github        # GitHub configuration (CI workflows, issue templates, …)
├── .hooks         # Auto Git hooks
├── docs           # Documentation website sources
├── gitkraken      # GitKraken derivations for caching
├── modules        # Module sources
├── pkgs           # Helper packages sources
├── tests          # Module tests
├── .envrc         # direnv configuration
├── flake.nix      # Root Flake definition
├── garnix.yaml    # Garnix CI configuration
├── module.nix     # Module entrypoint
├── .prettierrc    # Prettier custom configuration
├── shell.nix      # Nix development shell definition
└── treefmt.nix    # Code style formatters configuration
```

Admittedly this is a lot, but everything is covered in this documentation, so read along!

## Prerequisites

NixKraken being mostly Nix, it is the only hard requirement. The only known version constraint being to have at least Nix 2.4, which is quite old anyway, so you should be good.

Additionally, NixKraken should be compatible with any Nix "flavor" (upstream Nix, [Determinate Nix](https://determinate.systems/nix/), [Lix](https://lix.systems/), [Tvix](https://github.com/tvlfyi/tvix), [Snix](https://snix.dev/), …) since it only uses basic Nix capabilities.

Lastly, serving the documentation website locally for development purposes requires [mdBook](https://rust-lang.github.io/mdBook/) to be available with the following plugins:

- [mdbook-alerts](https://github.com/lambdalisue/rs-mdbook-alerts)
- [mdbook-linkcheck](https://github.com/Michael-F-Bryan/mdbook-linkcheck)

Building the documentation website only requires Nix.

## Development generalities

### Nix development shell

For a better developer experience, NixKraken provides a Nix development shell which source code can be viewed in the [`shell.nix` file](https://github.com/nicolas-goudry/nixkraken/blob/main/shell.nix).

This development shell does several things:

- add mdBook and required plugins to the PATH
- add [NodeJS](https://nodejs.org) to the PATH
- add helper packages to the PATH
- automatically install Git hooks located in the `.hooks` directory

Enabling the development shell can be done in various ways:

```bash
# Using new Nix commands
nix develop
```

```bash
# ...or classic Nix commands
nix-shell
```

```bash
# ...or direnv
direnv allow
```

#### About direnv

[direnv](https://direnv.net) is quite a handy tool which will automatically load the development shell (using classic Nix) when navigating to the project root directory or any of its subdirectories, as long as it's trusted using `direnv allow`.

> [!NOTE]
>
> If working on `shell.nix`, don't forget to run `direnv reload` to _re-apply_ the development shell, or use tools like [lorri](https://github.com/nix-community/lorri) to do this automatically for you.

### To Flake or not to Flake?

_…that's the question!_

The main distribution method for NixKraken is through Flakes. However, we don't want to alienate users who don't use Flakes, nor do we want to force its use on everyone. Our goal is to satisfy everyone.

For this reason, all Nix code in the repository **must be compatible with both Flakes and non Flakes setups**. This means that building any of the tools provided by the project should work either with `nix build` and `nix-build`. This also means that all documentation bits should provide instructions for both worlds.
