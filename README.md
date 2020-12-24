# Ansible macOS Playbook

This is the playbook I use after a clean install of macOS to set everything up.

## Roles/Tasks

- Installs Homebrew packages and app casks (Role `homebrew`)
- Installs MacPorts packages (Role `macports`)
- Installs App Store apps with [`mas-cli`](https://github.com/mas-cli/mas) (Role `mas`)
- Modifies MacOS settings (Role `settings`)
- Changes the user shell, if configured (Role `shell`)

## Usage

1. Install [Homebrew](https://brew.sh) or [MacPorts](https://macports.org).
1. Install Python (`brew install python`) or (`sudo port install python38`)
1. Install Ansible (`pip3 install ansible`) or (`sudo port install py38-ansible`)
1. Copy `default.config.yml` to `config.yml` and edit the configuration to your likings.
   - **Don't skip this, otherwise your computer will be provisioned like mine :)**
1. Install external roles with `ansible-galaxy install -r roles/requirements.yml`
1. Run `ansible-playbook main.yml`. Enter your account password when prompted.
   - If you have a configuration stored elsewhere (e.g. in a dotfiles folders), run `ansible-playbook main.yml --extra-vars=@/path/to/my/config.yml`

## Updating a fork with the latest changes from this repository

If you forked this repository and want to include its latest changes without losing your own,
add this repository as an upstream and rebase it onto your fork:

```bash
git remote add upstream git@github.com:tthoma24/ansible-macos-playbook.git
git fetch upstream
git rebase upstream/master
```

## Acknowledgements
This playbook is a fork of [Jerome Gamez's ansible-macos-playbook](https://github.com/jeromegamez/ansible-macos-playbook)

This playbook is heavily inspired by
[Jeff Geerling's mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook).

The macOS settings (a.k.a. `defaults write`s) are mostly taken from
[Mathias Bynens' defaults scripts](https://mths.be/macos) or from one of the
dotfiles repos from [http://dotfiles.github.io](http://dotfiles.github.io), but some I wrote on my own.
