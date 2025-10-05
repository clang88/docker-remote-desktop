# Build xrdp pulseaudio modules in builder container
# See https://github.com/neutrinolabs/pulseaudio-module-xrdp/wiki/README
ARG TAG=noble
FROM ubuntu:$TAG AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        autoconf \
        build-essential \
        ca-certificates \
        dpkg-dev \
        libpulse-dev \
        lsb-release \
        git \
        libtool \
        libltdl-dev \
        sudo && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp
WORKDIR /pulseaudio-module-xrdp
RUN scripts/install_pulseaudio_sources_apt.sh && \
    ./bootstrap && \
    ./configure PULSE_DIR=$HOME/pulseaudio.src && \
    make && \
    make install DESTDIR=/tmp/install


# Build the final image
# Core environment
ENV FIREFOX_AUTOSTART=true \
    FIREFOX_KIOSK=true \
    FIREFOX_HOME=about:blank \
    KIOSK_LOCKDOWN=false

FROM ubuntu:$TAG

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        git \
        locales \
        openbox \
        pavucontrol \
        libpci-dev \
        pulseaudio \
        pulseaudio-utils \
        software-properties-common \
        sudo \
        unclutter \
        vim \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    echo "Package: *"  > /etc/apt/preferences.d/mozilla-firefox && \
    echo "Pin: release o=LP-PPA-mozillateam" >> /etc/apt/preferences.d/mozilla-firefox && \
    echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends firefox && \
    rm -rf /var/lib/apt/lists/*

# Remove existing "ubuntu" users and create ubuntu user and group with UID/GID 1000 and home directory, adding user to video group
RUN deluser --remove-home ubuntu || true && \
    delgroup ubuntu || true && \
    groupadd -f -g 1000 ubuntu && \
    useradd --shell /bin/bash --uid 1000 --gid 1000 --groups sudo,render,video --create-home --home-dir /home/ubuntu ubuntu && \
    locale-gen en_US.UTF-8

COPY --from=builder /tmp/install /
RUN sed -i 's|^Exec=.*|Exec=/usr/bin/pulseaudio|' /etc/xdg/autostart/pulseaudio-xrdp.desktop

ENV LANG=en_US.UTF-8
COPY .xsession /home/ubuntu/.xsession
COPY .firefox-kiosk-session /home/ubuntu/.firefox-kiosk-session
RUN chown ubuntu:ubuntu /home/ubuntu/.xsession && chmod 755 /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.firefox-kiosk-session && chmod 755 /home/ubuntu/.firefox-kiosk-session
# Symlinking to xsessionrc because apparently not all xrdp use .xsession directly
RUN ln -sf /home/ubuntu/.xsession /home/ubuntu/.xsessionrc && chown ubuntu:ubuntu /home/ubuntu/.xsessionrc
COPY entrypoint.sh /usr/bin/entrypoint
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]
