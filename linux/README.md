# setup

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix ffmpeg btop jq tcpdump
cp -R .tmux/ ~
ln -s ~/.tmux/tmux.conf.symlink ~/.tmux.conf
```

## btop conf
```bash
mkdir -p ~/.config && cp -r .config/btop ~/.config
```
### gpu
#### amdgpu
to display amdgpu stats, install the required package:
```bash
sudo apt install rocm-smi
```

## linux bash aliases
```bash
cp .bash_aliases .dotenv .gitconfig ~
pushd ~ && . .bash_aliases && popd
```