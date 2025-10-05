#!/usr/bin/env bash

# Default environment variables
FIREFOX_HOME=${FIREFOX_HOME:-about:blank}
FIREFOX_KIOSK=${FIREFOX_KIOSK:-true}
FIREFOX_AUTOSTART=${FIREFOX_AUTOSTART:-true}
KIOSK_LOCKDOWN=${KIOSK_LOCKDOWN:-false}
echo "FIREFOX_AUTOSTART=$FIREFOX_AUTOSTART" >> /etc/environment \
&& echo "FIREFOX_KIOSK=$FIREFOX_KIOSK" >> /etc/environment \
&& echo "FIREFOX_HOME=$FIREFOX_HOME" >> /etc/environment \
&& echo "KIOSK_LOCKDOWN=$KIOSK_LOCKDOWN" >> /etc/environment
# Set the ubuntu user's password from UBUNTU_PASSWORD env variable if user exists
if id ubuntu >/dev/null 2>&1; then
    echo "ubuntu:${UBUNTU_PASSWORD:-ubuntu}" | chpasswd
fi

# Remove existing sesman/xrdp PID files to prevent rdp sessions hanging on container restart
[ ! -f /var/run/xrdp/xrdp-sesman.pid ] || rm -f /var/run/xrdp/xrdp-sesman.pid
[ ! -f /var/run/xrdp/xrdp.pid ] || rm -f /var/run/xrdp/xrdp.pid

# Start xrdp sesman service
/usr/sbin/xrdp-sesman

## Firefox autostart removed from here. It should be started in the user's xrdp session profile (e.g., .xsession or .bash_profile).

# Run xrdp in foreground if no commands specified
if [ -z "$1" ]; then
    /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
