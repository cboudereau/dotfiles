# setup

## tmux conf
```bash
ln -s .tmux/tmux.conf.symlink .tmux.conf
```

## other app home folders
```bash
ln -s /mnt/c/Users/cboudereau/.aws .aws
ln -s /mnt/c/Users/cboudereau/.azure .azure
ln -s /mnt/c/Users/cboudereau/.gcloud .gcloud
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases

## docker
- add wsl2 Ubuntu distro
- Check that systemd is correctly installed : https://learn.microsoft.com/en-us/windows/wsl/wsl-config#systemd-support
- Setup docker for ubuntu : https://docs.docker.com/engine/install/ubuntu/
