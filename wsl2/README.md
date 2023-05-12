# setup

## tmux conf
```bash
apt install -y acpi
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
