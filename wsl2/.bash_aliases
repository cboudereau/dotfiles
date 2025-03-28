. ~/.dotenv
WINDOWS_HOME=$(wslpath -au "$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)")
alias git="${WINDOWS_HOME}/bin/Git/bin/git.exe"
alias g="${WINDOWS_HOME}/bin/Git/bin/git.exe"
alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
alias d='docker'
alias dc='docker compose'
alias dcd='docker compose down --remove-orphans -v --rmi local'
alias dcu='docker compose down --remove-orphans -v --rmi local && docker compose up'
alias ddf='docker system df'
alias dsp='docker system prune -a -f --volumes'
alias k='kubectl'
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
alias k9s='/snap/k9s/current/bin/k9s --readonly'
