# docker-remote-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)
[![GitHub stars](https://img.shields.io/github/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/network)
[![Docker Stars](https://img.shields.io/docker/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)
[![Docker Pulls](https://img.shields.io/docker/pulls/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)

Docker image with RDP server using [xrdp](https://www.xrdp.org) on Ubuntu with [Xfce](https://xfce.org).

## Features

- **Regular Desktop Mode**: Full XFCE desktop environment with Firefox integration
- **Kiosk Lockdown Mode**: Firefox-only session with no access to desktop environment
- **Auto-restart Firefox**: Automatically restarts Firefox if it crashes (in both modes)
- **Configurable home page**: Set any URL as the Firefox start page
- **Audio support**: Includes PulseAudio with xrdp integration

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FIREFOX_AUTOSTART` | `true` | Automatically start Firefox when session begins |
| `FIREFOX_KIOSK` | `true` | Run Firefox in fullscreen kiosk mode |
| `FIREFOX_HOME` | `about:blank` | URL to load when Firefox starts |
| `KIOSK_LOCKDOWN` | `false` | **Enable pure kiosk mode - bypasses desktop environment entirely** |
| `UBUNTU_PASSWORD` | `ubuntu` | Password for the ubuntu user |

### KIOSK_LOCKDOWN Mode

When `KIOSK_LOCKDOWN=true`, the container:
- **Bypasses the desktop environment completely**
- Launches Firefox directly in a minimal window manager
- Provides no access to Ubuntu desktop, panels, or menus
- Automatically hides the mouse cursor when inactive
- Restarts Firefox automatically if it crashes
- Perfect for digital signage, kiosks, or locked-down browser sessions

## Quick Start

### Regular Desktop Mode
Use the desktop environment with Firefox integration:

```bash
./run-desktop
```

### Kiosk Lockdown Mode  
Launch Firefox-only session (no desktop access):

```bash
./run
```

### Manual Docker Run

**Desktop Mode:**
```bash
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    --shm-size="1g" \
    --env "FIREFOX_HOME=https://your-website.com" \
    --env "FIREFOX_KIOSK=true" \
    --env "KIOSK_LOCKDOWN=false" \
    docker-remote-desktop:latest
```

**Kiosk Lockdown Mode:**
```bash
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop-kiosk" \
    --shm-size="1g" \
    --env "FIREFOX_HOME=https://your-website.com" \
    --env "FIREFOX_KIOSK=true" \
    --env "KIOSK_LOCKDOWN=true" \
    docker-remote-desktop:latest
```

### Docker Compose

Create a `docker-compose.yml` file:

**Desktop Mode:**
```yaml
version: '3.8'
services:
  remote-desktop:
    image: docker-remote-desktop:latest
    container_name: remote-desktop
    hostname: remote-desktop
    ports:
      - "3389:3389"
    shm_size: 1g
    environment:
      - FIREFOX_HOME=https://your-website.com
      - FIREFOX_KIOSK=true
      - FIREFOX_AUTOSTART=true
      - KIOSK_LOCKDOWN=false
      - UBUNTU_PASSWORD=your-secure-password
    restart: unless-stopped
```

**Kiosk Lockdown Mode:**
```yaml
version: '3.8'
services:
  remote-desktop-kiosk:
    image: docker-remote-desktop:latest
    container_name: remote-desktop-kiosk
    hostname: kiosk
    ports:
      - "3389:3389"
    shm_size: 1g
    environment:
      - FIREFOX_HOME=https://your-kiosk-app.com
      - FIREFOX_KIOSK=true
      - KIOSK_LOCKDOWN=true
      - UBUNTU_PASSWORD=your-secure-password
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

## Connecting with an RDP client

All Windows desktops and servers come with Remote Desktop pre-installed and macOS users can download the Microsoft Remote Desktop application for free from the App Store.  For Linux users, I'd suggest using the Remmina Remote Desktop client.

For the hostname, use `localhost` if the container is hosted on the same machine you're running your Remote Desktop client on and for remote connections just use the name or IP address of the machine you are connecting to.
NOTE: To connect to a remote machine, it will require TCP port 3389 to be exposed through the firewall.

**Default login credentials:**
```
Username: ubuntu
Password: ubuntu
```

**What you'll see after login:**
- **Desktop Mode**: Full XFCE desktop with Firefox auto-started
- **Kiosk Lockdown Mode**: Firefox immediately in fullscreen with no desktop visible

## Troubleshooting

### Firefox doesn't start
- Check if `FIREFOX_AUTOSTART=true` is set
- Verify the `FIREFOX_HOME` URL is accessible
- Check logs with: `docker logs <container-name>`

### Can't access desktop in Kiosk mode
This is by design! Set `KIOSK_LOCKDOWN=false` for desktop access.

### Performance issues
- Increase `--shm-size` (default: 1g)
- Reduce Firefox extensions and plugins
- Use lighter websites for `FIREFOX_HOME`

### Connection refused
- Ensure port 3389 is not blocked by firewall
- Verify container is running: `docker ps`
- Check if port is properly mapped: `docker port <container-name>`

```

## Mode Comparison

| Feature | Desktop Mode | Kiosk Lockdown Mode |
|---------|-------------|-------------------|
| **Environment** | Full XFCE desktop | Firefox only |
| **User Access** | Terminal, file manager, apps | Firefox browser only |
| **Use Cases** | Development, general use | Digital signage, kiosks |
| **Security** | Standard desktop | Locked down |
| **Resources** | Higher (full desktop) | Lower (minimal WM) |
| **Firefox Restart** | Manual or via desktop | Automatic |

![Screenshot of Desktop Mode](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_1.png)

*Desktop Mode: Full XFCE environment with Firefox*

## Building docker-remote-desktop

Clone the GitHub repository:

```bash
git clone https://github.com/scottyhardy/docker-remote-desktop.git
cd docker-remote-desktop
```

Build the image with the supplied script:

```bash
./build
```

Or run the following docker command:

```bash
docker build -t docker-remote-desktop .
```

## Running local images with scripts

The repository includes convenient scripts for different use cases:

### `./run-desktop`
Starts the container in **regular desktop mode** with full XFCE environment:
- Full Ubuntu desktop with panels, menus, and applications
- Firefox auto-starts and runs alongside other desktop applications
- Users can access terminal, file manager, and other installed software

### `./run` 
Starts the container in **kiosk lockdown mode**:
- Firefox-only interface with no desktop environment
- No access to Ubuntu desktop, panels, or other applications
- Perfect for digital signage, kiosks, or restricted browser sessions
- Automatically restarts Firefox if it crashes

### Other scripts:
- `./build` - Build the Docker image locally
- `./start` - Start as a detached daemon (desktop mode)
- `./stop` - Stop the detached container

## Advanced Usage

### Custom Firefox Profile
Mount a custom Firefox profile for persistent settings:

```bash
docker run -it \
    --rm \
    --publish="3389:3389/tcp" \
    --volume="/path/to/firefox-profile:/home/ubuntu/.mozilla" \
    --env "KIOSK_LOCKDOWN=true" \
    docker-remote-desktop:latest
```

### Persistent Storage
Mount volumes for persistent data:

```bash
docker run -it \
    --rm \
    --publish="3389:3389/tcp" \
    --volume="/path/to/data:/home/ubuntu/data" \
    --env "FIREFOX_HOME=file:///home/ubuntu/data/index.html" \
    docker-remote-desktop:latest
```

## Persisting User Settings

To maintain user settings, bookmarks, and other application data across container restarts, you can mount host directories to preserve important user configuration folders. This is particularly useful for maintaining Firefox profiles, desktop settings, and other personalized configurations.

### Key Directories to Persist

- **Firefox Profile**: `~/.mozilla/firefox` - Contains bookmarks, extensions, preferences, and browsing history
- **Desktop Settings**: `~/.config/xfce4` - XFCE desktop environment settings and customizations
- **User Home**: `/home/ubuntu` - Complete user directory (includes all settings)

### Docker Compose with Persistent Settings

**Desktop Mode with Settings Persistence:**
```yaml
version: '3.8'
services:
  remote-desktop:
    image: docker-remote-desktop:latest
    container_name: remote-desktop
    hostname: remote-desktop
    ports:
      - "3389:3389"
    shm_size: 1g
    environment:
      - FIREFOX_HOME=https://your-website.com
      - FIREFOX_KIOSK=true
      - FIREFOX_AUTOSTART=true
      - KIOSK_LOCKDOWN=false
      - UBUNTU_PASSWORD=your-secure-password
    volumes:
      # Persist Firefox profile (bookmarks, extensions, settings)
      - ./firefox-data:/home/ubuntu/.mozilla/firefox
      # Persist desktop settings
      - ./xfce-config:/home/ubuntu/.config/xfce4
      # Optional: persist entire user directory
      # - ./user-home:/home/ubuntu
    restart: unless-stopped
```

**Kiosk Mode with Firefox Settings Persistence:**
```yaml
version: '3.8'
services:
  remote-desktop-kiosk:
    image: docker-remote-desktop:latest
    container_name: remote-desktop-kiosk
    hostname: kiosk
    ports:
      - "3389:3389"
    shm_size: 1g
    environment:
      - FIREFOX_HOME=https://your-kiosk-app.com
      - FIREFOX_KIOSK=true
      - KIOSK_LOCKDOWN=true
      - UBUNTU_PASSWORD=your-secure-password
    volumes:
      # Persist Firefox profile for consistent kiosk behavior
      - ./firefox-data:/home/ubuntu/.mozilla/firefox
    restart: unless-stopped
```

### Manual Docker Run with Bind Mounts

```bash
# Create directories on host
mkdir -p ./firefox-data ./xfce-config

# Run with persistent settings
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    --shm-size="1g" \
    --volume="$(pwd)/firefox-data:/home/ubuntu/.mozilla/firefox" \
    --volume="$(pwd)/xfce-config:/home/ubuntu/.config/xfce4" \
    --env "FIREFOX_HOME=https://your-website.com" \
    --env "KIOSK_LOCKDOWN=false" \
    docker-remote-desktop:latest
```

**Note**: The first time you run with these bind mounts, the directories will be empty and Firefox will create a new profile. Any changes you make (bookmarks, extensions, settings) will persist between container restarts.
