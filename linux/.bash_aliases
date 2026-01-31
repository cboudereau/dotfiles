. ~/.dotenv
alias g='git'
alias d='docker'
alias dc='docker compose'
alias dcd='docker compose down --remove-orphans -v --rmi local'
alias dcu='docker compose down --remove-orphans -v --rmi local && docker compose up'
alias dctcpdump='bridge=$(docker network inspect -f json $(dc config --format json | jq -r ".networks.bridge.name") | jq -r ".[0].Id" | cut -c 1-12) && if [ -n "${bridge}" ]; then echo "running tcp dump on docker compose network bridge ${bridge}" && sudo tcpdump -i br-${bridge} -U -w - | tee ${bridge}.pcap | tcpdump -r -; else echo "bridge not found"; fi'
alias ddf='docker system df'
alias dsp='docker system prune -a -f --volumes'
alias k='kubectl'
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
alias k9s='/snap/k9s/current/bin/k9s --readonly'
