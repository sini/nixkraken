[axosoft]: https://www.axosoft.com/
[doc-contrib]: ./dev/contributing.md
[gh-issues]: https://github.com/nicolas-goudry/nixkraken/issues
[gh]: https://github.com/nicolas-goudry/nixkraken
[gitkraken-eula]: https://www.gitkraken.com/eula
[gitkraken-paid-feat]: https://www.gitkraken.com/pricing#tablepress-8
[gitkraken-pricing]: https://www.gitkraken.com/pricing
[gitkraken]: https://www.gitkraken.com/git-client
[hm]: https://nix-community.github.io/home-manager
[repo-license]: https://github.com/nicolas-goudry/nixkraken/blob/main/LICENSE

<center>

![NixKraken logo](./logo.svg)

---

**NixKraken** provides a [Home Manager][hm] module for managing [GitKraken][gitkraken] configuration files and profiles in a declarative and reproducible way.

<small>_This project is **NOT** affiliated with Axosoft (the makers of GitKraken) in any way._</small><br/>
<small>_NixKraken is only handling GitKraken's configuration, one still needs to [purchase the product][gitkraken-pricing] to benefit paid features._</small><br/>
<small>_**This is not a cracked GitKraken app.**_</small>

---

</center>

## Features

- **Declarative profiles**: manage multiple profiles using Nix
- **Builtin themes**: personalize GitKraken with pre-packaged themes
- **Fast install**: benefit from cached artifacts, speeding installation time
- **Reproducible setup**: ensure identical configurations across several machines
- **Version control**: keep configuration in Git, tracking every change
- **Automated tooling**: includes command-line tools to help manage authentication and themes

## Contributing

Unlike GitKraken, NixKraken is free and open source: **contributions are welcome!**

The source code can be found on [GitHub][gh] and issues and feature requests can be posted on the [GitHub issue tracker][gh-issues].

To add new options, improve documentation, or fix bugs, please read the [contributing guide][doc-contrib].

## Licenses

The NixKraken source and documentation are released under the [MIT License][repo-license].

The GitKraken software is the property of [Axosoft][axosoft] and its use is subject to the [End User License Agreement][gitkraken-eula]. Some of its features are free to use, while others require a paid subscription - [read more about this on their official website][gitkraken-paid-feat].
