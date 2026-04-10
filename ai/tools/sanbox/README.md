# AI Sandboxing

I want to sandbox AI agent to avoid leaking sensitive data or using untrustfull websites.

Ideally, I want to run the sandbox as a simple docker container / compose file with mounted volume. 

I also want that the :
- AI MUST use its own SSH keys to use git.
- AI MUST NOT use the host home.
- Network MUST be controlled via a firewall with allowed domain and forbidden (how about using an allow list from a trustful list). MITM proxy is very promising but SHOULD NOT impact performance. I also want a copy with a MITM https proxy to audit AI network usage (tcpdump MITM? MITM proxy ?) .
- A devcontainer CAN be created but the Dockerfile MUST be standalone with required feature so that a bash/sh CLI tool can be used inside the container without vscode.

For the use case, only Claude code will be used, claude must be available in the container and setup in the Dockerfile

## Use cases
### Standalone linux dev box

This is the simplest case, all tools MUST be defined inside the Dockerfile.

### Windows + Linux dev box

The host is windows with WLS2/ubuntu.
Docker desktop MUST NOT be used due to license and costs.

This use case is more complex because the dev platform is windows (ie: dotnet framework) and some tools are only available for windows.

1. Windows only host
2. A mix of Windows + linux

Find a viable approach to be able to use docker for windows and linux or for windows only without Docker Desktop