# AI Sandboxing Best Practices

## Overview

This document synthesizes best practices for sandboxing AI coding agents (Claude Code) based on official documentation, community research, and open-source tooling as of April 2026.

## 1. Claude Code Native Sandbox

Claude Code has built-in sandboxing using OS-level primitives (bubblewrap on Linux/WSL2, Seatbelt on macOS). This is the simplest starting point and eliminates constant permission prompts.

### Prerequisites (Linux/WSL2)

```bash
sudo apt-get install bubblewrap socat
```

### Recommended settings

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "failIfUnavailable": true,
    "filesystem": {
      "denyRead": ["~/"],
      "allowRead": ["."],
      "allowWrite": ["/tmp/build"]
    },
    "network": {
      "allowedDomains": [
        "api.anthropic.com",
        "*.anthropic.com",
        "github.com",
        "*.githubusercontent.com",
        "*.npmjs.org",
        "*.crates.io",
        "*.pypi.org"
      ]
    }
  }
}
```

Key settings:

| Setting | Purpose |
|---|---|
| `autoAllowBashIfSandboxed` | Commands inside sandbox boundaries run without prompting |
| `allowUnsandboxedCommands: false` | Disables the `dangerouslyDisableSandbox` escape hatch entirely |
| `failIfUnavailable: true` | Hard failure if sandbox cannot start (missing deps, unsupported platform) |
| `filesystem.denyRead: ["~/"]` | Block reading the entire home directory |
| `filesystem.allowRead: ["."]` | Re-allow reading the project directory |
| `network.allowedDomains` | Explicit allowlist of reachable domains |

### Custom proxy for HTTPS inspection

Claude Code supports plugging in your own proxy for traffic auditing:

```json
{
  "sandbox": {
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

Point these at a mitmproxy instance to decrypt and log all HTTPS traffic.

### Sandbox modes

- **Auto-allow mode**: sandboxed commands run automatically, unsandboxable commands fall back to the permission flow.
- **Regular permissions mode**: all commands go through the standard permission flow even when sandboxed.

### Limitations

- `enableWeakerNestedSandbox` is required inside Docker but **significantly reduces security**. Compensate with container-level isolation.
- `docker` commands are incompatible with the sandbox. Use `excludedCommands: ["docker *"]`.
- `watchman` is incompatible. Use `jest --no-watchman` instead.
- Built-in file tools (Read, Edit, Write) use the permission system, not the sandbox.

Reference: https://code.claude.com/docs/en/sandboxing

## 2. Defense-in-Depth Layers

Effective sandboxing requires **both** filesystem and network isolation. Without network isolation, a compromised agent can exfiltrate files. Without filesystem isolation, a compromised agent can backdoor system resources to gain network access.

| Layer | What it protects | Tools |
|---|---|---|
| Container | Isolate from host OS | Docker with `--cap-drop ALL`, `--no-new-privileges`, `--read-only` |
| Filesystem | Block sensitive paths | Claude sandbox `denyRead`/`denyWrite`, Landlock LSM |
| Network | Domain allowlist | Claude sandbox `allowedDomains`, mitmproxy sidecar |
| Secrets | Agent never sees raw values | iron-proxy boundary injection, Docker Sandboxes secret proxy |
| SSH/Git | Per-session ephemeral keys | Deploy keys with minimal scope, short-lived tokens |

## 3. Docker Container Hardening

### Hardened run command

```bash
docker run \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --security-opt seccomp=/path/to/seccomp-profile.json \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=512m \
  --tmpfs /home/agent/.cache:rw,size=1g \
  --user 1000:1000 \
  --memory 4g \
  --cpus 2 \
  -v /path/to/project:/workspace:rw \
  -w /workspace \
  your-agent-image
```

### Key flags

| Flag | Purpose |
|---|---|
| `--cap-drop ALL` | Remove all Linux capabilities |
| `--no-new-privileges` | Prevent privilege escalation via setuid binaries |
| `--seccomp=profile.json` | Restrict available syscalls |
| `--read-only` | Read-only root filesystem |
| `--tmpfs /tmp` | Writable scratch area, not persisted |
| `--user 1000:1000` | Run as non-root |
| `--memory 4g --cpus 2` | Resource limits |

### Stronger isolation options

| Technology | Isolation Level | Startup Time | Best For |
|---|---|---|---|
| Firecracker | Hardware (KVM), dedicated kernel | ~100-200ms | Gold standard for untrusted code |
| Kata Containers | Hardware (KVM), dedicated kernel | ~150-300ms | Multi-tenant, Kubernetes |
| gVisor | User-space kernel | Fast | When VMs are not available |
| Hardened containers | Shared kernel + seccomp/capabilities | Instant | Quick isolation, defense-in-depth |

## 4. Network Control

### Approaches ranked by complexity

**A. `--network none`**: No network at all. Simplest but prevents package installs and API calls.

**B. Claude Code native proxy**: Built-in domain allowlist via `sandbox.network.allowedDomains`. No extra infrastructure needed.

**C. mitmproxy sidecar** (recommended for HTTPS auditing):
- Runs alongside the agent container
- iptables rules force all outbound traffic through the proxy
- Full visibility into HTTPS request bodies
- Domain allowlist enforcement
- Performance: ~5-50ms per request

**D. iron-proxy**: Purpose-built egress firewall with boundary-level secret injection. The agent sends proxy tokens, the proxy replaces them with real secrets. The agent never sees actual credentials.

**E. pipelock**: Combines network filtering with DLP scanning (detects secrets before any DNS query leaves), Landlock LSM, and seccomp.

### Performance considerations

- mitmproxy adds ~5-50ms per request depending on payload size
- SSL bumping is CPU-intensive; use connection pooling
- For high-throughput, prefer domain-only filtering (SNI-based) over full body inspection
- DNS filtering is the lightest but only controls domains, not paths or payloads

## 5. Git/SSH Isolation

### Principles

- Never mount `~/.ssh` from the host
- Generate per-session SSH keys or use GitHub deploy keys (read-only, per-repo)
- Use fine-grained GitHub Personal Access Tokens with minimal scope and limited expiration
- Use `git credential-store` with a token file injected at runtime and destroyed when the container exits

### Example

```bash
# Don't do this:
-v ~/.ssh:/home/agent/.ssh:ro

# Do this instead:
-v /path/to/deploy-key:/home/agent/.ssh/id_ed25519:ro
-v /path/to/agent-gitconfig:/home/agent/.gitconfig:ro
```

## 6. Secret Management

### The threat is real

- Claude Code auto-loads `.env` files via dotenv without user consent
- DNS exfiltration: agents can be tricked into encoding sensitive data into DNS queries
- AI-assisted commits have a ~3.2% secrets leak rate (double the ~1.6% human baseline)

### Approaches (strongest to weakest)

1. **Zero-knowledge proxy** (agent never sees secrets): iron-proxy replaces proxy tokens with real secrets at the network boundary.
2. **Encrypted secrets with session leases**: joelhooks/agent-secrets uses Age encryption with session-scoped leases and a killswitch.
3. **Dedicated secrets managers**: Bitwarden Secrets Manager, 1Password, Akeyless.
4. **Environment variable hygiene** (minimum baseline):
   - Never mount `.env` files into the container
   - Never pass secrets via `docker run -e`
   - Use `--read-only` filesystem
   - Add `.env` to the container's filesystem deny list

## 7. Filesystem Isolation

### Principles

- Mount **only the workspace directory**, not the home directory
- Use `--read-only` root filesystem with explicit `--tmpfs` for writable scratch
- Be aware that mounted workspaces include implicitly-executed files: Git hooks, CI config, Makefile, package.json scripts

### Deny list recommendations

Block the agent from reading:
- `~/.ssh/`, `~/.gnupg/`, `~/.aws/`, `~/.kube/`
- `~/.bashrc`, `~/.zshrc` (may contain exported secrets)
- `/proc/self/environ` (contains all environment variables)
- `.env`, `.env.local`, `.env.production`

## 8. Docker on Windows/WSL2 (No Docker Desktop)

### Option A: Docker Engine in WSL2 (recommended)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

Enable systemd in `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then:

```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

Caveat: modern Ubuntu uses nftables. You may need:

```bash
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
```

### Option B: Rancher Desktop

Free, open-source Docker Desktop replacement. Installs into WSL2, supports `containerd` or `dockerd (moby)` runtime. Heavier than bare Docker Engine but provides a GUI.

### Option C: containerd + nerdctl

Minimal footprint, same runtime Kubernetes uses. Not 100% Docker-compatible.

## 9. Native Windows Containers (not LCOW)

This section covers native Windows containers only — not Linux Containers on Windows (LCOW).

### Isolation modes

| Mode | Kernel | Host requirement | Startup | Security |
|---|---|---|---|---|
| Process isolation | Shared with host | Windows Server only. Container OS version must match host exactly. | Fast | Weak (shared kernel, no seccomp/capabilities) |
| Hyper-V isolation | Dedicated per-container | Windows 10/11 Pro/Enterprise, Windows Server | ~1-2s, more memory | Strong (full kernel boundary) |

Process isolation on Windows 10/11 is not officially supported and requires workarounds. For strong isolation, **Hyper-V isolation is the only viable option** on Windows client editions.

### Running Windows containers without Docker Desktop

| Tool | Maturity | Notes |
|---|---|---|
| **dockerd (Moby) directly** | Production-ready | Install via `Install-Module DockerMsftProvider` or from `microsoft/Windows-Containers` GitHub. Free, no license. This was the standard before Docker Desktop. |
| **containerd + nerdctl** | Mature | Microsoft actively contributes Windows container support to containerd. |
| **Podman** | Experimental | Primarily Linux-focused. Not mature for native Windows containers. |

#### Option A: Docker Engine via DockerMsftProvider (PowerShell)

This is the simplest method. Run PowerShell as Administrator:

```powershell
# 1. Enable the Containers feature (requires reboot)
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All

# 2. Enable Hyper-V (required for Hyper-V isolation, requires reboot)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# 3. Reboot
Restart-Computer

# 4. Install the Docker provider and Docker Engine
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# 5. Start the Docker service
Start-Service docker

# 6. Verify
docker version
docker run --isolation=hyperv mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd /c echo hello
```

The `docker` service runs as a Windows service (`dockerd.exe`). No Docker Desktop involved.

To start automatically on boot:

```powershell
Set-Service -Name docker -StartupType Automatic
```

#### Option B: containerd + nerdctl

```powershell
# 1. Enable Containers and Hyper-V features (same as above, requires reboot)
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Restart-Computer

# 2. Download and install containerd
# Get the latest release from https://github.com/containerd/containerd/releases
# Extract to C:\Program Files\containerd
# Register as a Windows service:
& "C:\Program Files\containerd\containerd.exe" --register-service
Start-Service containerd

# 3. Download and install nerdctl (Docker-compatible CLI)
# Get the latest release from https://github.com/containerd/nerdctl/releases
# Extract nerdctl.exe to a directory in your PATH

# 4. Verify
nerdctl run --isolation=hyperv mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd /c echo hello
```

#### Requirements

| Requirement | Details |
|---|---|
| OS edition | Windows 10/11 Pro/Enterprise or Windows Server 2019/2022/2025 |
| Containers feature | Must be enabled (`Enable-WindowsOptionalFeature -Online -FeatureName Containers`) |
| Hyper-V feature | Required for Hyper-V isolation on client editions (Pro/Enterprise) |
| Admin rights | Required for installation and running `dockerd` |
| OS version matching | For process isolation, container OS version must exactly match host. Hyper-V isolation relaxes this. |

### Base images

Only two official base images exist:

- `mcr.microsoft.com/windows/servercore` — ~1.5-3GB, includes most Win32 APIs
- `mcr.microsoft.com/windows/nanoserver` — ~250MB, minimal, no Win32 subsystem

Image sizes are 10-50x larger than Linux Alpine (~5MB).

### What Linux security primitives are missing

| Linux primitive | Windows equivalent | Status |
|---|---|---|
| `--cap-drop ALL` | No equivalent | Not available |
| seccomp profiles | No equivalent | Not available |
| `--read-only` filesystem | No equivalent | Not supported on Windows containers |
| User namespaces | No equivalent | Not available |
| bubblewrap / Landlock | No equivalent | Not available |
| Network namespaces | HNS (Host Networking Service) | Available but less granular |

The only strong isolation boundary on Windows containers is **Hyper-V isolation**, which provides a full kernel boundary but no fine-grained controls inside the container.

### Network control on Windows containers

Windows containers use HNS (Host Networking Service) with these network modes:

- **NAT** (default) — container gets a private IP, outbound traffic is NATed
- **Transparent** — container is directly on the physical network
- **Overlay** — for multi-host (Swarm/Kubernetes)
- **L2Bridge / L2Tunnel** — for specific routing scenarios

Network filtering options:

- **Windows Defender Firewall** — can apply rules per-process inside the container, but no domain-level allowlisting (IP-based only)
- **HNS ACL policies** — L4 ACLs (IP + port) applied at the virtual switch level
- **Proxy-based filtering** — run a forward proxy (Squid, mitmproxy) and force traffic through it via environment variables or route table. This is the most viable approach for domain-level allowlisting on Windows.

There is no equivalent to Linux iptables transparent proxying on Windows. Applications must respect `HTTP_PROXY`/`HTTPS_PROXY` environment variables, or a PAC file must be configured.

### Claude Code in Windows containers

- Claude Code is Node.js-based and can run on Windows
- The native sandbox (bubblewrap) is **Linux-only and not available in Windows containers**
- No equivalent OS-level sandbox exists for Windows containers
- Claude Code's `sandbox.enabled` setting will not work inside a Windows container

### Viable approaches

#### Approach 1: Hyper-V isolated Windows container + proxy (Windows-only tools)

Best for running Windows-only tools (e.g., dotnet framework, MSBuild) in isolation.

```powershell
# Install Docker Engine (no Docker Desktop)
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Run with Hyper-V isolation
docker run --isolation=hyperv `
  --memory 4g `
  --cpus 2 `
  -e HTTP_PROXY=http://host.docker.internal:8080 `
  -e HTTPS_PROXY=http://host.docker.internal:8080 `
  -v C:\path\to\project:C:\workspace `
  -w C:\workspace `
  mcr.microsoft.com/windows/servercore:ltsc2022
```

Run mitmproxy on the host to filter and audit outbound traffic. This does not prevent the container from bypassing the proxy (no transparent proxying), but Claude Code and most tools respect `HTTP_PROXY`.

Limitations:
- No fine-grained filesystem deny lists
- No `--read-only` filesystem
- No seccomp/capability controls
- Large images (multi-GB)
- Proxy bypass possible if a tool ignores `HTTP_PROXY`

#### Approach 2: Windows Sandbox (built-in disposable VM)

Windows Sandbox is a lightweight, disposable VM built into Windows Pro/Enterprise. It is destroyed on close — all changes are lost.

```xml
<!-- sandbox-config.wsb -->
<Configuration>
  <Networking>Enable</Networking>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>C:\path\to\project</HostFolder>
      <SandboxFolder>C:\workspace</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>powershell -ExecutionPolicy Bypass -File C:\workspace\setup.ps1</Command>
  </LogonCommand>
</Configuration>
```

Limitations:
- Full desktop VM, not a container (heavier)
- Networking is all-or-nothing (Enable/Disable), no domain-level filtering built-in
- Not easily scriptable for CI/automation
- Single instance at a time

Network control can be added inside the sandbox by installing a proxy or configuring Windows Firewall rules in the `LogonCommand` setup script.

#### Approach 3: Hybrid — Linux container for Claude Code + Windows host for tools (recommended)

This is the most practical approach for a mixed Windows+Linux workflow:

1. **Claude Code runs in a Linux container** (Docker Engine in WSL2) with full sandbox support (bubblewrap, seccomp, mitmproxy sidecar, filesystem deny lists)
2. **Windows-only tools** (dotnet framework, MSBuild) run on the host or in a separate Windows container
3. The workspace is shared via a mounted volume accessible from both WSL2 and Windows (`/mnt/c/...`)
4. Claude Code invokes Windows tools via `cmd.exe /c` or `powershell.exe` through WSL interop if needed

This gives you the best of both worlds: strong Linux sandboxing for the AI agent, and access to Windows-only tooling where needed.

Trade-off: WSL2 filesystem interop (`/mnt/c/`) has performance overhead for I/O-heavy operations. Consider keeping the workspace inside WSL2 (`~/projects/`) and syncing to Windows only when needed.

### Summary

| Approach | Isolation strength | Network control | Filesystem control | Complexity |
|---|---|---|---|---|
| Hyper-V container + proxy | Strong (kernel boundary) | Medium (proxy-based, bypassable) | Weak (no read-only, no deny lists) | Medium |
| Windows Sandbox | Strong (VM) | Weak (all-or-nothing) | Weak (mapped folders only) | Low |
| Hybrid Linux + Windows | Strong (Linux sandbox) | Strong (mitmproxy, iptables) | Strong (seccomp, Landlock, deny lists) | Higher |

For AI agent sandboxing, the **hybrid approach is recommended** because Linux has far superior sandboxing primitives. Use Windows containers or Windows Sandbox only for the Windows-only tools that cannot run in WSL2.

## 10. Mixing Windows and Linux Containers

A single Docker Compose file **cannot** mix Windows and Linux containers. Docker Compose targets a single daemon, and a daemon runs in either Windows or Linux container mode — never both.

### Why it doesn't work

| Setup | Linux containers | Windows containers | Both in one compose |
|---|---|---|---|
| Docker Engine in WSL2 | Yes | No | No |
| Docker Engine on Windows (DockerMsftProvider) | No | Yes | No |
| Docker Desktop (switch mode) | Yes OR Yes | — | No |
| LCOW (Linux Containers on Windows) | Experimental | Yes | Was the goal, **deprecated and abandoned** by Microsoft |

LCOW was the attempt to solve exactly this problem. Microsoft stopped investing in it — it never left experimental status.

### Workaround A: Two Docker daemons + two compose files (most practical)

Run both daemons side by side and use `DOCKER_HOST` to target each.

```yaml
# docker-compose-linux.yml — targets Docker Engine in WSL2
services:
  claude-agent:
    build: ./linux
    ports:
      - "8080:8080"
    volumes:
      - /mnt/c/Users/you/project:/workspace
```

```yaml
# docker-compose-windows.yml — targets Docker Engine on Windows
services:
  dotnet-builder:
    image: mcr.microsoft.com/windows/servercore:ltsc2022
    isolation: hyperv
    ports:
      - "9090:9090"
    volumes:
      - C:\Users\you\project:C:\workspace
```

Run them from their respective environments:

```powershell
# From Windows PowerShell — Windows containers
docker-compose -f docker-compose-windows.yml up -d
```

```bash
# From WSL2 bash — Linux containers
docker compose -f docker-compose-linux.yml up -d
```

Containers communicate via `host.docker.internal` or exposed ports on `localhost`. Both daemons share the host's network stack (WSL2 uses NAT to the host).

### Workaround B: Orchestrator script wrapping both

A single script that drives both compose files:

```bash
#!/bin/bash
# start.sh — run from WSL2
docker compose -f docker-compose-linux.yml up -d
powershell.exe -Command "docker-compose -f docker-compose-windows.yml up -d"
```

```bash
#!/bin/bash
# stop.sh — run from WSL2
docker compose -f docker-compose-linux.yml down
powershell.exe -Command "docker-compose -f docker-compose-windows.yml down"
```

### Workaround C: Avoid Windows containers entirely

If the Windows-only tool (e.g., `dotnet framework`, `msbuild`) can be installed directly on the host, skip Windows containers. The agent in the Linux container calls Windows tools via WSL interop:

```bash
# From inside the Linux container or WSL2
cmd.exe /c "msbuild C:\\path\\to\\project.sln"
powershell.exe -Command "dotnet build C:\path\to\project.sln"
```

This avoids the two-daemon complexity entirely.

### Workaround D: Kubernetes with mixed node pools

Kubernetes can schedule Linux pods and Windows pods on different nodes in the same cluster. This is production-grade but overkill for local dev. Mentioned for completeness.

### Networking between Linux and Windows containers

When running two daemons, containers on different daemons cannot use Docker networking (bridge, overlay) to discover each other. Communication options:

| Method | How |
|---|---|
| Exposed ports on localhost | Both daemons publish ports on the host. Containers reach each other via `host.docker.internal:<port>`. |
| Shared volume | Mount the same directory from both (`/mnt/c/...` in WSL2, `C:\...` on Windows). File-based communication (results, artifacts). |
| Named pipes | Windows containers can access named pipes. Not available from Linux containers. |

### Summary

There is no single-compose solution for mixed Windows+Linux containers. The most practical approach is **two compose files + two daemons**, connected via localhost ports and shared volumes. For most AI sandboxing scenarios, **avoiding Windows containers entirely** (workaround C) is simpler — use the Linux container for the agent and call Windows tools via WSL interop.

## 11. Open-Source Projects

| Project | Focus | Link |
|---|---|---|
| mattolson/agent-sandbox | Docker + mitmproxy sidecar | https://github.com/mattolson/agent-sandbox |
| ironsh/iron-proxy | Egress firewall, boundary-level secret injection | https://github.com/ironsh/iron-proxy |
| pipelock | DLP scanning + Landlock + seccomp | https://github.com/luckyPipewrench/pipelock |
| joelhooks/agent-secrets | Age-encrypted credentials, killswitch | https://github.com/joelhooks/agent-secrets |
| @anthropic-ai/sandbox-runtime | Claude Code's sandbox as open-source npm package | https://github.com/anthropic-experimental/sandbox-runtime |
| kubernetes-sigs/agent-sandbox | Kubernetes, gVisor + Kata | https://github.com/kubernetes-sigs/agent-sandbox |
| restyler/awesome-sandbox | Curated list of AI sandboxing tools | https://github.com/restyler/awesome-sandbox |

## 12. Security Warnings

- **Domain fronting**: broad domain allowlists (e.g., `github.com`) can be exploited for data exfiltration via domain fronting.
- **Unix sockets**: `allowUnixSockets` with `/var/run/docker.sock` grants host system access. Carefully evaluate any allowed unix sockets.
- **Filesystem write escalation**: allowing writes to directories in `$PATH` or shell config files (`.bashrc`, `.zshrc`) enables privilege escalation.
- **Nested sandbox weakness**: `enableWeakerNestedSandbox` inside Docker considerably weakens security. Only use when additional container-level isolation is enforced.

## References

- Claude Code Sandboxing: https://code.claude.com/docs/en/sandboxing
- Claude Code Settings: https://code.claude.com/docs/en/settings
- Anthropic Secure Deployment: https://platform.claude.com/docs/en/agent-sdk/secure-deployment
- Docker Sandboxes: https://docs.docker.com/ai/sandboxes/
- Northflank Sandbox Guide: https://northflank.com/blog/how-to-sandbox-ai-agents
- Knostic .env Leakage: https://www.knostic.ai/blog/claude-cursor-env-file-secret-leakage
- NVIDIA Sandboxing Guide: https://developer.nvidia.com/blog/practical-security-guidance-for-sandboxing-agentic-workflows-and-managing-execution-risk/
