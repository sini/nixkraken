[gh-discuss]: https://github.com/nicolas-goudry/nixkraken/discussions
[gh-issues]: https://github.com/nicolas-goudry/nixkraken/issues
[gh-prs]: https://github.com/nicolas-goudry/nixkraken/pulls

# NixKraken Roadmap

## Now (current focus)

- **GitKraken 11.1.1+ compatibility:** ensuring full compatibility with recent GitKraken versions, particularly addressing authentication handling changes introduced in newer releases
- **Expanded test coverage:** adding more automated tests to catch compatibility issues early and ensure module reliability

## Soon (next few months)

- **Reach stable:** reaching a stable, production-ready release with comprehensive compatibility guarantees
- **Username/password authentication:** supporting traditional username/password authentication flow in `gk-login` alongside the existing OAuth providers

## Later (future ideas)

- **CI/CD automation**:
  - Run test suites in CI with clear pass/fail reports and artifacts
  - Automate tracking and updating of GitKraken versions and packaged themes
  - Add PR checks (formatting, builds, option schema validation, docs links) and required-status enforcement
- **Fully reproducible authentication:** exploring ways to make GitKraken authentication fully declarative and reproducible
- **True immutability:** investigating approaches to prevent configuration drift by making GitKraken configuration files truly immutable while maintaining app functionality

## How you can help

We would love hearing from you! [Share your feedback][gh-discuss], [report bugs][gh-issues], and [suggest new features][gh-prs] on our GitHub repository.
