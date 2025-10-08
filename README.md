# Bootstrap

A fast setup for my development environment across Linux / Windows. Currently supporting Omarchy 3.0 and WSL Ubuntu 24.04.

# General Use

All bootstrapped dependencies are in /dep, which are installed after more fundamental dependencies in the scripts. configCopy is the intermediary for copying.

## Importing

Ensure you start with the correct distro. First, run the import.sh script, which should install additional dependencies and import all remote config files to ~/.config (Overwrites everything currently there).

Afterwards there are a few optional separate scripts in syncScripts and manual procedures in manual.txt that might be helpful.

## Exporting

The export.sh script will export everything in ~/.config/, as well as specified files in ~, into corresponding entries in configCopy. Since you may not want to push large/private entries, there are many excluded ones in .gitignore for this.

# Various

## Keybinds

For keyboard, software, and browser.

## IDE

Settings for non-Neovim IDEs.

## Windows

Utilities for improving the Windows dev experience, which I created before making the switch to objectively superior linux.

## Wifi

For connecting to secured networks, like eduroam. Per the Omarchy installation manual:

Omarchy defaults to the systemd stack: systemd-networkd for networking, iwd for Wi-Fi, and systemd-resolved for DNS.

So installing NetworkManager (+ other steps in ufgetonline.sh) is required for the UF-provided Join-Now script to work.

## Issues I encountered

To get Surface Studio 2 Drivers working, you must downgrade to a previous surface-linux version.
See:
<https://github.com/linux-surface/linux-surface/issues/1272>
