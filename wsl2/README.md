# setup

## distro
```powershell
wsl --unregister ubuntu
wsl --update
wsl --install ubuntu
```

## copy wsl2 dotfiles
```bash
cd <PathToDotFilesRepo>/wsl2
cp -R .tmux/ ~ && cp .bash_aliases .dotenv ~
pushd ~ && . .bash_aliases && popd
```

## tmux conf
```bash
sudo apt update -y && sudo apt install -y tmux acpi graphviz cmatrix ffmpeg iftop btop
ln -s ~/.tmux/tmux.conf.symlink ~/.tmux.conf
```

## other app home folders
```bash
WINDOWS_HOME=$(wslpath -au "$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)") && ln -s $WINDOWS_HOME/.aws ~/.aws && ln -s $WINDOWS_HOME/.azure ~/.azure && mkdir -p .config && ln -s $WINDOWS_HOME/.config/gcloud ~/.config/gcloud
```

## iftop conf
```bash
sudo setcap "cap_net_admin,cap_net_raw=ep" /usr/sbin/iftop
```

## bash aliases
git and ssh comes from windows and linked through bash_aliases

## docker
[docker native](./docker/README.md#native)

## PowerShell integration
Aliases and dotenv [PowerShell profile](./Microsoft.PowerShell_profile.ps1) should be installed on windows :

- Windows PowerShell: Documents\WindowsPowerShell
- PowerShell core: Documents\PowerShell\

## Windows Terminal Setup
1. Copy [background](./WindowsTerminal/background.jpg) to home folder
1. Windows Terminal > Settings > Open JSON File
1. Copy [settings.json](./WindowsTerminal/settings.json) content to the current opened config
