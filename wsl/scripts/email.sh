set -euo pipefail
ACC="${ACC:-outlook}"
mbsync "$ACC"
neomutt
