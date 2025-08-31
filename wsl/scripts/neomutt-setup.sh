#!/usr/bin/env bash

debug() { echo -e "\033[31m$*\033[0m"; }

# -p for protect, don't complain if already exists
mkdir -p ~/email
mkdir -p ~/Mail

# Set up oauth2 via vygrant
debug "setting up vygrant"

cd ~/email
if [ ! -d vygrant ]; then
  git clone https://github.com/vybraan/vygrant.git
fi

cd vygrant
if ! go build -ldflags "-s -w"; then
  echo "go build for vygrant failed"
  exit 1
fi

echo "checking vygrant status"
vygrant status

// do vygrant token refresh outlook

debug "setting up mail smtp (smtp)"
# If it fails here, try ensuring that .msmtp is 600 (rw- --- ---)
