# setup

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix ffmpeg iftop
ln -s .tmux/tmux.conf.symlink ~/.tmux.conf
```

## other app home folders
```bash
ln -s /mnt/c/Users/$(whoami.exe | cut -d "\\" -f 2)/.aws ~/.aws
ln -s /mnt/c/Users/$(whoami.exe | cut -d "\\" -f 2)/.azure ~/.azure
ln -s /mnt/c/Users/$(whoami.exe | cut -d "\\" -f 2)/.gcloud ~/.gcloud
```

## iftop conf
```bash
sudo setcap "cap_net_admin,cap_net_raw=ep" /usr/sbin/iftop
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases

## docker
https://github.com/cboudereau/dotfiles/tree/master/wsl2/docker#native
