. .dotenv
WINDOWS_HOME=/mnt/c/Users/$(whoami.exe | cut -d "\\" -f 2 | tr -d '\r')
alias git="${WINDOWS_HOME}/bin/Git/bin/git.exe"
alias g="${WINDOWS_HOME}/bin/Git/bin/git.exe"
alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
alias d='docker'
alias dc='docker compose'
alias k='kubectl'
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
alias k9s='/snap/k9s/current/bin/k9s --readonly'
