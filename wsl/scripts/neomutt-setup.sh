#!/usr/bin/env bash
set -euo pipefail

# EDIT THESE (or export before running)
NAME="${NAME:-Ricky Zhang}"
EMAIL="${EMAIL:-rickyzhang196@outlook.com}"
ACC="${ACC:-outlook}"
MAILDIR="${MAILDIR:-$HOME/Mail/$ACC}"
TOKEN="${TOKEN:-$HOME/.config/mutt/$ACC.token}"

mkdir -p "$MAILDIR" ~/.config/mutt ~/.config/msmtp ~/.local/bin

# Find or fetch OAuth helper
if [ -x /usr/share/neomutt/oauth2/mutt_oauth2.py ]; then
  OAUTH=/usr/share/neomutt/oauth2/mutt_oauth2.py
elif [ -x "$HOME/.local/bin/mutt_oauth2.py" ]; then
  OAUTH="$HOME/.local/bin/mutt_oauth2.py"
else
  echo "downloading oauth helper..."
  curl -fsSL https://raw.githubusercontent.com/neomutt/neomutt/main/contrib/oauth2/mutt_oauth2.py \
    -o "$HOME/.local/bin/mutt_oauth2.py"
  chmod +x "$HOME/.local/bin/mutt_oauth2.py"
  OAUTH="$HOME/.local/bin/mutt_oauth2.py"
fi

# ~/.muttrc — uses local Maildir + msmtp; html via w3m
if [ -f ~/.muttrc ]; then cp ~/.muttrc ~/.muttrc.bak.$(date +%s); fi
cat >~/.muttrc <<EOF
set realname="$NAME"
set from="$EMAIL"

set folder="$MAILDIR"
set spoolfile="+INBOX"
set record="+Sent"
set postponed="+Drafts"
set trash="+Trash"

set sendmail="/usr/bin/msmtp"
set use_from=yes
set envelope_from=yes

# render HTML automatically with w3m
auto_view text/html
set mailcap_path=~/.mailcap
alternative_order text/plain text/html

# quality-of-life
set sort=threads
set sort_aux=last-date-received
set editor="nvim"
EOF

# ~/.mailcap — HTML → w3m
if [ -f ~/.mailcap ]; then cp ~/.mailcap ~/.mailcap.bak.$(date +%s); fi
cat >~/.mailcap <<'EOF'
text/html; w3m -I %{charset} -T text/html; copiousoutput
EOF

# ~/.mbsyncrc — IMAP <-> Maildir with XOAUTH2 via mutt_oauth2.py
if [ -f ~/.mbsyncrc ]; then cp ~/.mbsyncrc ~/.mbsyncrc.bak.$(date +%s); fi
cat >~/.mbsyncrc <<EOF
IMAPAccount $ACC
Host outlook.office365.com
User $EMAIL
AuthMechs XOAUTH2
SSLType IMAPS
CertificateFile /etc/ssl/certs/ca-certificates.crt
# mutt_oauth2.py prints a fresh access token via your refresh token
PassCmd "$OAUTH $TOKEN"

IMAPStore ${ACC}-remote
Account $ACC

MaildirStore ${ACC}-local
Path $MAILDIR/
Inbox $MAILDIR/INBOX
SubFolders Verbatim

Channel $ACC
Master :${ACC}-remote:
Slave  :${ACC}-local:
Patterns *
Create Slave
SyncState *
Expunge Both
EOF

# ~/.config/msmtp/config — SMTP with OAuthBearer via same token
if [ -f ~/.config/msmtp/config ]; then cp ~/.config/msmtp/config ~/.config/msmtp/config.bak.$(date +%s); fi
cat >~/.config/msmtp/config <<EOF
defaults
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.config/msmtp/msmtp.log

account $ACC
host smtp.office365.com
port 587
auth oauthbearer
user $EMAIL
tls_starttls on
oauthbearer_cmd $OAUTH $TOKEN

account default: $ACC
EOF

chmod 600 ~/.config/msmtp/config
echo "FILES OK. Maildir=$MAILDIR  Token=$TOKEN  OAUTH=$OAUTH"
