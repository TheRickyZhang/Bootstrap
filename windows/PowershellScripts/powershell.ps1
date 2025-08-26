function ck { git checkout $args }
function rb { git rebase $args }
function or { git remote -v }
function cp { git cherry-pick $args }
function gitpush { param([string]$message) git add .; git commit -m "$message"; git push }
function gitpushf { param([string]$message) git add .; git commit -m "$message"; git push --force-with-lease }
function gitri { param([int]$number) git rebase -i HEAD~$number }

function openpfp {
    notepad "$PROFILE"
}
function pfp {
    . "$PROFILE"
    Write-Output "pfp applied"
}
