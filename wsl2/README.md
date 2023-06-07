# setup

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix nethogs
ln -s .tmux/tmux.conf.symlink ~/.tmux.conf
```

## other app home folders
```bash
ln -s /mnt/c/Users/cboudereau/.aws ~/.aws
ln -s /mnt/c/Users/cboudereau/.azure ~/.azure
ln -s /mnt/c/Users/cboudereau/.gcloud ~/.gcloud
```

## iftop conf
```bash
sudo setcap "cap_net_admin,cap_net_raw=ep" /usr/sbin/iftop
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases
