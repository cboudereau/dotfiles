# docker setup
## TL;DR 

wsl2 and native tools are standard. The init time is far better (<5s instead of >1mn) and the memory is also better managed (since everything is setup on only one wsl distro instead of 2) but additional scripts should be configured to be available from any windows shell.

Only the LCOW (Linux Container On Windows) has been tested.

The .scripts folder contains docker and docker-compose cli integration for windows

| setup | container runtime | init time | complexity | usability | k3s | compose | internet |
|-|-|-|-|-|-|-|-|
| native | containerd | < 5s | S | S | yes | yes | yes |
| rancher desktop | dockerd | > 1mn | M | L | yes | yes | yes |
| rancher desktop | containerd | > 1mn | M | L | yes | yes | no |

eps : event per second

|  | container runtime | cpu | memory | io |
|-|-|-|-|-|
| native | containerd | 1953.37 eps | 6442.59 MiB/sec | read: 39.57 MiB/s / write: 26.38 MiB/s  | 
| rancher desktop | dockerd | 1946.26 eps | 5296.50 MiB/sec | read: 38.44 MiB/s / write: 25.96 MiB/s |
| rancher desktop | containerd | 1920.96 eps | 4831.14 MiB/sec| read: 36.58 MiB/s write: 24.39 MiB/s |

## native

Native install consists of installing wsl2 with ubuntu distro (or any distro having systemd preconfigured) and install docker like if it is a true one.

k3s test is on going, only the setup has been validated at the time of writing

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
wsl -v
WSL version: 1.2.5.0
Kernel version: 5.15.90.1
WSLg version: 1.0.51
MSRDC version: 1.2.3770
Direct3D version: 1.608.2-61064218
DXCore version: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
Windows version: 10.0.19045.2965
```

### tool benchmark

Native (wsl2 only) install is recommended since LCOW install is like having a true linux OS.
To have the docker cli available locally, .scripts can be added to PATH

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