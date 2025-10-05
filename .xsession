
#!/usr/bin/env bash
# Source Dockerfile ENV variables
[ -f /etc/environment ] && . /etc/environment

echo "[.xsession] Running as $(whoami) at $(date)" > /tmp/xsession-debug.log
echo "[.xsession] Environment variables:" >> /tmp/xsession-debug.log
echo "FIREFOX_AUTOSTART=$FIREFOX_AUTOSTART" >> /tmp/xsession-debug.log
echo "FIREFOX_KIOSK=$FIREFOX_KIOSK" >> /tmp/xsession-debug.log
echo "FIREFOX_HOME=$FIREFOX_HOME" >> /tmp/xsession-debug.log
echo "KIOSK_LOCKDOWN=$KIOSK_LOCKDOWN" >> /tmp/xsession-debug.log
env >> /tmp/xsession-debug.log

# Export environment variables for the session
export FIREFOX_AUTOSTART FIREFOX_KIOSK FIREFOX_HOME KIOSK_LOCKDOWN

# Check if KIOSK_LOCKDOWN is enabled - if so, launch Firefox-only session
if [ "$KIOSK_LOCKDOWN" = "true" ]; then
    echo "[.xsession] KIOSK_LOCKDOWN enabled, launching Firefox-only session" >> /tmp/xsession-debug.log
    exec /home/ubuntu/.firefox-kiosk-session
fi

# Regular desktop mode - Start the default X session (e.g., xfce4-session, startxfce4, or similar)
if command -v startxfce4 >/dev/null 2>&1; then
    # Start Firefox in background after a short delay if autostart is enabled
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         echo "[.xsession] Starting Firefox with FIREFOX_HOME=$FIREFOX_HOME, KIOSK=$FIREFOX_KIOSK" >> /tmp/xsession-debug.log;
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
         else
             firefox "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
         fi) &
    fi
    exec startxfce4
elif command -v xfce4-session >/dev/null 2>&1; then
    # Start Firefox in background after a short delay if autostart is enabled
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         echo "[.xsession] Starting Firefox with FIREFOX_HOME=$FIREFOX_HOME, KIOSK=$FIREFOX_KIOSK" >> /tmp/xsession-debug.log;
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
         else
             firefox "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
         fi) &
    fi
    exec xfce4-session
elif command -v startlxqt >/dev/null 2>&1; then
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" &
         else
             firefox "$FIREFOX_HOME" &
         fi) &
    fi
    exec startlxqt
elif command -v startlxde >/dev/null 2>&1; then
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" &
         else
             firefox "$FIREFOX_HOME" &
         fi) &
    fi
    exec startlxde
elif command -v openbox-session >/dev/null 2>&1; then
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" &
         else
             firefox "$FIREFOX_HOME" &
         fi) &
    fi
    exec openbox-session
else
    if [ "$FIREFOX_AUTOSTART" = "true" ]; then
        (sleep 5; 
         if [ "$FIREFOX_KIOSK" = "true" ]; then
             firefox --kiosk "$FIREFOX_HOME" &
         else
             firefox "$FIREFOX_HOME" &
         fi) &
    fi
    exec xterm
fi
