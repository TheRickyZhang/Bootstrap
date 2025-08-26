## Notable IDE edits
These shortcuts are used on top of vim bindings and are not comprehensive, just the ones I can remember well enough.

Global:
Ctrl + Shift + A -> Run Current File (ex bind to External Tools: run.bat)
Ctrl + Shift + N -> New Source File (Of whatever IDE-specific)
Alt + F -> Tab Switcher AND Down on Tab Switcher

Clion:
Editor -> Code Style -> Inspections -> Clang-Tidy  (remove warnings about .size())
-modernize-use-empty,-cppcoreguidelines-narrowing-conversions
Add CPP Template

IntelliJ:

Ctrl + Shift + H: Global Search and Replace
Alt + G: Open (Selection of file choices)

VSCode:

Visual Studio:

### Set PowerShell 7 as Default Terminal
1. Add an entry in `settings.json` of your terminal.
2. Set the default ID to PowerShell 7.

### Node.js Permissions Issue
- If encountering weird permissions issues with installing Node.js and related tools:
  - Check both `AppData/Roaming` and `Program Files` locations.
  - Manually copy or sync the files between these locations.

# Chrome Extensions and Shortcuts

## Primary
1. [GPT-Hotkeys](https://chromewebstore.google.com/detail/gpt-hotkeys/hmnopbffkafhmkojgmcolhlkeghmngcn?hl=en-US)  
   - Make sure you activate recommended keybindings.

2. [Recent Tabs](https://chromewebstore.google.com/detail/recent-tabs/ocllfmhjhfmogablefmibmjcodggknml)  
   - Use `Alt+F` for single, `Shift+Alt+F` for multiple list.

3. [Rearrange Tabs](https://chromewebstore.google.com/detail/rearrange-tabs/ccnnhhnmpoffieppjjkhdakcoejcpbga?hl=en-US)  
   - Use `Alt+Shift+Arrow`.

4. [Duplicate Tab Shortcut](https://chrome.google.com/webstore/detail/duplicate-tab-shortcut/bldjhijhndnjnpjafjphdndfmfnmhckb?hl=en)  
   - Use `Alt+Shift+D` (Duplicate), `Alt+Shift+R` (Duplicate to Right).

And ublock origin, the most effective extension, obviously.