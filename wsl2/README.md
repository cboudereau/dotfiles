# setup

## distro
```powershell
wsl --unregister ubuntu
wsl --update
wsl --install ubuntu
```

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix ffmpeg iftop btop
ln -s .tmux/tmux.conf.symlink ~/.tmux.conf
```

## other app home folders
```bash
WINDOWS_HOME=/mnt/c/Users/$(whoami.exe | cut -d "\\" -f 2 | tr -d '\r') && ln -s $WINDOWS_HOME/.aws ~/.aws && ln -s $WINDOWS_HOME/.azure ~/.azure && ln -s $WINDOWS_HOME/.config/gcloud ~/.config/gcloud
```

## iftop conf
```bash
sudo setcap "cap_net_admin,cap_net_raw=ep" /usr/sbin/iftop
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases

## docker
[docker native](./docker/README.md#native)