---
name: Bug Report
about: Create a report to help us improve NixKraken
title: "A brief and descriptive title of the bug"
labels: 'bug'
assignees: ''
---

**Describe the bug**

A clear and concise description of what the bug is.

**Steps to Reproduce**

Steps to reproduce the behavior:

1. List here the steps to reproduce the bug you're seeing
2. Use numbered lists if relevant.
3. If you can, link to a repository reproducing the issue.

**Expected behavior**

A clear and concise description of what you expected to happen.

**Actual behavior**

A clear and concise description of what actually happened.

**Nix Configuration**

Please provide the relevant part of your Home Manager or other Nix configuration file where you are using NixKraken.

```nix
# Paste your NixKraken configuration here
programs.nixkraken = {
  enable = true;
  # ... other options
};
```

**System Information**

Please provide the following information about your system:

- **Nix version:** `nix-shell --version`
- **Operating System:** (e.g., NixOS 25.05, macOS Sonoma 14.0)

**Logs**

```
If applicable, add here any error messages or logs that you see.
```

**Screenshots or Screencasts**

If applicable, add screenshots or screencasts to help explain your problem.

**Possible Solution (Optional)**

If you have an idea of what might be causing the bug or how to fix it, please share it here.

**Additional context**

Add any other context about the problem here.
