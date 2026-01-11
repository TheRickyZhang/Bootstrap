#!/bin/bash
# wine reg add "HKCU\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 96 /f
# wine reg add "HKCU\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 1 /f
export WINEPREFIX="$HOME/.wine-studio"
cd "/home/ricky/.wine-studio/drive_c/Program Files/Studio 2.0"
wine Studio.exe 2>/dev/null &
disown
