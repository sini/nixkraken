---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: NixKraken
  text: Declarative GitKraken
  tagline: Manage GitKraken configuration and profiles in a reproducible way using Nix & Home Manager.
  actions:
    - theme: brand
      text: Getting Started
      link: /guide/getting-started/quick-start
    - theme: alt
      text: Reference
      link: /reference/nixkraken
  image:
    src: /nixkraken-logo.svg
    alt: NixKraken

features:
  - icon: <i class="fa-solid fa-code"></i>
    title: Declarative profiles
    details: Manage multiple profiles using Nix.
  - icon: <i class="fa-solid fa-palette"></i>
    title: Builtin themes
    details: Personalize GitKraken with pre-packaged themes.
  - icon: <i class="fa-solid fa-bolt-lightning"></i>
    title: Fast install
    details: Benefit from cached artifacts, speeding installation time.
  - icon: <i class="fa-solid fa-clone"></i>
    title: Reproducible setup
    details: Ensure identical configurations across several machines.
  - icon: <i class="fa-solid fa-code-commit"></i>
    title: Version control
    details: Keep configuration in Git, tracking every change.
  - icon: <i class="fa-solid fa-robot"></i>
    title: Automated tooling
    details: Includes command-line tools to help manage authentication and themes.
---
