# git.ps1

Write-Host "Checking for Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing via winget..."
    winget install --id Git.Git -e --silent
    Start-Sleep -Seconds 5
} else {
    Write-Host "Git is already installed."
}
git --version

Write-Host "Configuring global Git settings..."
git config --global push.default current
git config --global pull.rebase true
git config --global fetch.prune true
git config --global diff.colorMoved zebra

git config --global alias.pushf "push --force-with-lease"
git config --global alias.ch "checkout"
git config --global alias.rb "rebase"
git config --global alias.ck "checkout"
git config --global alias.chp "cherry-pick"
git config --global alias.pom "pull origin main"
git config --global alias.ss "status"

git config --global alias.staash "stash --all"
git config --global alias.blaame "blame -w -C -C -C -L"
git config --global rerere.enabled true

Write-Host "Global Git configuration applied."
Write-Host "Reminder: Run 'git maintenance start' in each project directory if needed."
