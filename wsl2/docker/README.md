# docker setup
## TL;DR 

wsl2 and native tools are standard. The init time is far better (<5s instead of >1mn) and the memory is also managed better (since everything is setup on only one wsl distro instead of 2) but additional scripts should be configured to be available from any windows shell.

Only the LCOW (Linux Container On Windows) has been tested.

The .scripts folder contains docker and docker-compose cli integration for windows

| setup | container runtime | init time | complexity | usability | k3s | compose | internet |
|-|-|-|-|-|-|-|-|
| native | containerd | < 5s | 1 | 8 | yes | yes | yes |
| rancher desktop | dockerd | > 1mn | 5 | 3 | yes | yes | yes |
| rancher desktop | containerd | > 1mn | 5 | 5 | yes | yes | no |

eps : event per second

|  | container runtime | cpu | memory | file io |
|-|-|-|-|-|
| native | containerd | 1953.37 eps | 6442.59 MiB/s | read: 39.57 MiB/s / write: 26.38 MiB/s  | 
| rancher desktop | dockerd | 1946.26 eps | 5296.50 MiB/s | read: 38.44 MiB/s / write: 25.96 MiB/s |
| rancher desktop | containerd | 1920.96 eps | 4831.14 MiB/s | read: 36.58 MiB/s / write: 24.39 MiB/s |

## native

Native install consists of installing wsl2 with ubuntu distro (or any distro having systemd preconfigured) and install docker like if it is a true one.

k3s test is on going, only the setup has been validated at the time of writing

### docker setup
- add wsl2 Ubuntu distro
- setup docker for ubuntu : https://docs.docker.com/engine/install/ubuntu/
- check that systemd is correctly installed : https://learn.microsoft.com/en-us/windows/wsl/wsl-config#systemd-support
- to run docker and docker compose from any windows shell, add .scripts to PATH

```bash
sudo usermod -aG docker $USER
```

### k3s setup
```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s -
```

```bash
sudo snap install --classic kubectx
```

```bash
sudo snap install k9s
```

## rancher desktop

### dockerd
docker cli in rancher desktop is only compatible with the dockerd container runtime

```bash
docker run --rm -it ubuntu bash
```

### containerd
nerdctl is used with containerd as container runtime
```bash
nerdctl run --rm -it ubuntu bash
```

:warning: Internet is not available from the container (TODO : analyse why ?)

## benchmark

### environment

#### wsl2
```bash
>wsl -v
WSL version: 1.2.5.0
Kernel version: 5.15.90.1
WSLg version: 1.0.51
MSRDC version: 1.2.3770
Direct3D version: 1.608.2-61064218
DXCore version: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
Windows version: 10.0.19045.2965
```

```bash
>wsl -l -v
  NAME            STATE           VERSION
* Ubuntu-22.04    Stopped         2
```

### container benchmark

replace docker by nerdctl for rancher desktop and containerd setup

#### image setup
```bash
docker build -t sysbench:ubuntu-22.04 .
```

##### cpu
```bash
docker run --rm sysbench:ubuntu-22.04 cpu run
```
##### memory
```bash
docker run --rm sysbench:ubuntu-22.04 memory run
```

##### file io
```bash
docker run --rm --entrypoint bash sysbench:ubuntu-22.04 -c "sysbench fileio prepare && sysbench fileio --file-test-mode=rndrw run && sysbench fileio cleanup"
``` 
