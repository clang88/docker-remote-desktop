
#!/usr/bin/env bash
# Source Dockerfile ENV variables
[ -f /etc/environment ] && . /etc/environment

echo "[.xsession] Running as $(whoami) at $(date)" > /tmp/xsession-debug.log
echo "[.xsession] Firefox environment variables:" >> /tmp/xsession-debug.log
echo "FIREFOX_AUTOSTART=$FIREFOX_AUTOSTART" >> /tmp/xsession-debug.log
echo "FIREFOX_KIOSK=$FIREFOX_KIOSK" >> /tmp/xsession-debug.log
echo "FIREFOX_HOME=$FIREFOX_HOME" >> /tmp/xsession-debug.log
echo "KIOSK_LOCKDOWN=$KIOSK_LOCKDOWN" >> /tmp/xsession-debug.log
env >> /tmp/xsession-debug.log

# Export environment variables for the session
export FIREFOX_AUTOSTART FIREFOX_KIOSK FIREFOX_HOME KIOSK_LOCKDOWN

# Check if we should use kiosk lockdown mode
if [ "$KIOSK_LOCKDOWN" = "true" ] && [ "$FIREFOX_AUTOSTART" = "true" ]; then
    echo "[.xsession] Starting in KIOSK LOCKDOWN mode" >> /tmp/xsession-debug.log
    
    # Create a minimal startup script for kiosk mode
    cat > /tmp/kiosk-start.sh << 'EOF'
#!/bin/bash
# Disable screen saver and power management
xset -dpms
xset s off
xset s noblank

# Create Firefox profile with security restrictions
PROFILE_DIR="$HOME/.mozilla/firefox/kiosk-profile"
mkdir -p "$PROFILE_DIR"

# Copy kiosk preferences if they don't exist
if [ ! -f "$PROFILE_DIR/user.js" ]; then
    cp "$HOME/kiosk-prefs.js" "$PROFILE_DIR/user.js"
    chmod 644 "$PROFILE_DIR/user.js"
fi

# Start openbox with kiosk configuration
openbox --config-file ~/.config/openbox/kiosk-rc.xml &
WM_PID=$!

# Wait a moment for window manager to start
sleep 2

# Start Firefox in kiosk mode
if [ "$FIREFOX_KIOSK" = "true" ]; then
    # Full kiosk mode with security restrictions
    firefox \
        --profile "$PROFILE_DIR" \
        --kiosk \
        --no-first-run \
        --disable-dev-shm-usage \
        --disable-extensions \
        --disable-plugins \
        --disable-translate \
        --disable-infobars \
        --disable-web-security \
        --disable-features=TranslateUI \
        --disable-ipc-flooding-protection \
        --disable-default-apps \
        --disable-background-timer-throttling \
        --disable-renderer-backgrounding \
        --disable-backgrounding-occluded-windows \
        --disable-component-extensions-with-background-pages \
        "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
else
    firefox --profile "$PROFILE_DIR" "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
fi

FIREFOX_PID=$!

# Monitor Firefox and restart if it crashes/closes
while true; do
    if ! kill -0 $FIREFOX_PID 2>/dev/null; then
        echo "[kiosk] Firefox exited, restarting..." >> /tmp/xsession-debug.log
        if [ "$FIREFOX_KIOSK" = "true" ]; then
            firefox \
                --profile "$PROFILE_DIR" \
                --kiosk \
                --no-first-run \
                --disable-dev-shm-usage \
                --disable-extensions \
                --disable-plugins \
                --disable-translate \
                --disable-infobars \
                --disable-web-security \
                --disable-features=TranslateUI \
                --disable-ipc-flooding-protection \
                --disable-default-apps \
                --disable-background-timer-throttling \
                --disable-renderer-backgrounding \
                --disable-backgrounding-occluded-windows \
                --disable-component-extensions-with-background-pages \
                "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
        else
            firefox --profile "$PROFILE_DIR" "$FIREFOX_HOME" 2>&1 >> /tmp/firefox-debug.log &
        fi
        FIREFOX_PID=$!
    fi
    sleep 5
done
EOF

    chmod +x /tmp/kiosk-start.sh
    exec /tmp/kiosk-start.sh

# Regular desktop mode with optional Firefox autostart
else
    echo "[.xsession] Starting in regular desktop mode" >> /tmp/xsession-debug.log
    
    # Start the default X session (e.g., xfce4-session, startxfce4, or similar)
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
fi
