# review-setup-debian

Automated setup script for [Re:VIEW](https://github.com/kmuto/review) environment on Debian GNU/Linux.

## Overview

This script automates the installation and configuration of Re:VIEW, a document production system for technical books. It handles the complex setup of Japanese LaTeX environment, Ruby dependencies, and font configurations required for PDF generation.

## Requirements

- Debian GNU/Linux (not derivatives)
- sudo privileges
- Internet connection

## Usage

### Basic Commands

Complete setup with default project directory

```bash
$ ./review-setup-debian.sh full-setup
```

Complete setup with custom project directory

```bash
$ ./review-setup-debian.sh full-setup my-technical-book
```

Setup environment without creating a project

```bash
$ ./review-setup-debian.sh system-setup
```

Individual setup steps

```bash
$ ./review-setup-debian.sh install-packages
$ ./review-setup-debian.sh bundle-install
$ ./review-setup-debian.sh setup-fonts
$ ./review-setup-debian.sh review-init my-project
```

Display help

```bash
$ ./review-setup-debian.sh help
```

### Setup Flow

The script executes tasks in the following order:

1. **install-packages** - Install system packages (bundler, texlive-lang-japanese, texlive-pictures)
2. **bundle-install** - Install Ruby dependencies including Re:VIEW gem
3. **setup-fonts** - Configure Japanese fonts for PDF generation
4. **review-init** - Initialize a new Re:VIEW project

### Font Configuration

The default font is Harano Aji (haranoaji). You can specify alternative fonts:

```bash
$ ./review-setup-debian.sh setup-fonts ipaex
$ ./review-setup-debian.sh setup-fonts ipa
```

## What Gets Installed

- **System Packages**
  - bundler - Ruby dependency management
  - texlive-lang-japanese - Japanese LaTeX support
  - texlive-pictures - Diagram and figure support

- **Ruby Gems** (via Gemfile)
  - review - Re:VIEW document production system
  - Dependencies for syntax highlighting, image processing, etc.

- **Font Configuration**
  - Japanese font mapping for PDF generation
  - JIS2004 character set support

## Generating PDFs

After setup, you can generate PDFs in your project directory:

```bash
$ cd my-book
$ bundle exec --gemfile=../Gemfile rake pdf
```

## Task Dependencies

The setup tasks have the following dependency chain:

```
install-packages (installs: bundler, texlive-lang-japanese, texlive-pictures)
    |
    v
bundle-install (requires: bundler)
    |
    v
setup-fonts (requires: texlive-lang-japanese)
    |
    v
review-init (requires: bundle-installed Re:VIEW gem)
```

- **setup-fonts** cannot run without texlive-lang-japanese package
- **review-init** cannot run without Re:VIEW gem installed via bundle
- **system-setup** executes install-packages, bundle-install, and setup-fonts in order
- **full-setup** executes all tasks in the correct order automatically

If a task fails, check that its prerequisites have been completed:

For setup-fonts issues

```bash
$ ./review-setup-debian.sh install-packages
```

For review-init issues

```bash
$ ./review-setup-debian.sh bundle-install
```

## Docker Image

Pre-built Docker images are available on GitHub Container Registry:

```bash
# Pull the latest image
$ docker pull ghcr.io/zinrai/review-setup-debian:latest

# Run Re:VIEW commands
$ docker run --rm -v $(pwd):/work ghcr.io/zinrai/review-setup-debian:latest rake pdf
```

## License

This project is licensed under the [MIT License](./LICENSE).
