# setup

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix ffmpeg iftop
ln -s .tmux/tmux.conf.symlink ~/.tmux.conf
```

## other app home folders
```bash
WINDOWS_USERNAME=$(whoami.exe | cut -d "\\" -f 2 | tr -d '\r') && pushd /mnt/c/Users/$WINDOWS_USERNAME
ln -s $(pwd)/.aws ~/.aws
ln -s $(pwd)/.azure ~/.azure
ln -s $(pwd)/.gcloud ~/.gcloud
popd
```

## iftop conf
```bash
sudo setcap "cap_net_admin,cap_net_raw=ep" /usr/sbin/iftop
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases

## docker
https://github.com/cboudereau/dotfiles/tree/master/wsl2/docker#native
