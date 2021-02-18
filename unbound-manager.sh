#!/bin/bash
# https://github.com/complexorganizations/unbound-manager

# Require script to be run as root
function super-user-check() {
  if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as super user."
    exit
  fi
}

# Check for root
super-user-check

# Detect Operating System
function dist-check() {
  if [ -e /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO=$ID
  fi
}

# Check Operating System
dist-check

# Pre-Checks system requirements
function installing-system-requirements() {
  if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ] || [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ] || [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ] || [ "$DISTRO" == "alpine" ] || [ "$DISTRO" == "freebsd" ]; }; then
    if [ ! -x "$(command -v curl)" ]; then
      if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ]; }; then
        apt-get update && apt-get install curl -y
      elif { [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]; }; then
        yum update -y && yum install curl -y
      elif { [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ]; }; then
        pacman -Syu && pacman -Syu --noconfirm curl
      elif [ "$DISTRO" == "alpine" ]; then
        apk update && apk add curl
      elif [ "$DISTRO" == "freebsd" ]; then
        pkg update && pkg install curl
      fi
    fi
  else
    echo "Error: $DISTRO not supported."
    exit
  fi
}

# Run the function and check for requirements
installing-system-requirements

# Global variables
UNBOUND_MANAGER="/etc/unbound/unbound-manager"
RESOLV_CONFIG="/etc/resolv.conf"
RESOLV_CONFIG_OLD="/etc/resolv.conf.old"
UNBOUND_CONFIG="/etc/unbound/unbound.conf"
UNBOUND_ANCHOR="/var/lib/unbound/root.key"
UNBOUND_ROOT_HINTS="/etc/unbound/root.hints"
UNBOUND_ROOT_SERVER_CONFIG_URL="https://www.internic.net/domain/named.cache"

if [ ! -f "$UNBOUND_MANAGER" ]; then

  # Function to install unbound
  function install-unbound() {
    if [ ! -x "$(command -v unbound)" ]; then
      if [ "$DISTRO" == "ubuntu" ]; then
        apt-get install unbound unbound-host e2fsprogs -y
        if pgrep systemd-journal; then
          systemctl stop systemd-resolved
          systemctl disable systemd-resolved
        else
          service systemd-resolved stop
          service systemd-resolved disable
        fi
      elif { [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ]; }; then
        apt-get install unbound unbound-host e2fsprogs -y
      elif { [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]; }; then
        yum install unbound unbound-libs -y
      elif [ "$DISTRO" == "fedora" ]; then
        dnf install unbound -y
      elif { [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ]; }; then
        pacman -Syu --noconfirm unbound
      elif [ "$DISTRO" == "alpine" ]; then
        apk add unbound
      elif [ "$DISTRO" == "freebsd" ]; then
        pkg install unbound
      fi
      rm -f $UNBOUND_ANCHOR
      rm -f $UNBOUND_CONFIG
      unbound-anchor -a $UNBOUND_ANCHOR
      NPROC=$(nproc)
      echo "server:
    num-threads: $NPROC
    verbosity: 1
    root-hints: $UNBOUND_ROOT_HINTS
    auto-trust-anchor-file: $UNBOUND_ANCHOR
    interface: 0.0.0.0
    interface: ::0
    max-udp-size: 3072
    access-control: 0.0.0.0/0                 allow
    access-control: ::0                       allow
    access-control: 127.0.0.1                 allow
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    harden-referral-path: yes
    unwanted-reply-threshold: 10000000
    val-log-level: 1
    cache-min-ttl: 1800
    cache-max-ttl: 14400
    prefetch: yes
    qname-minimisation: yes
    prefetch-key: yes
forward-zone:
  name: "."
  forward-addr: 8.8.8.8
  forward-addr: 8.8.4.4
  forward-addr: 2001:4860:4860::8888
  forward-addr: 2001:4860:4860::8844" >>$UNBOUND_CONFIG
      # Set DNS Root Servers
      curl $UNBOUND_ROOT_SERVER_CONFIG_URL --create-dirs -o $UNBOUND_ROOT_HINTS
      chattr -i $RESOLV_CONFIG
      mv $RESOLV_CONFIG $RESOLV_CONFIG_OLD
      echo "nameserver 127.0.0.1" >>$RESOLV_CONFIG
      echo "nameserver ::1" >>$RESOLV_CONFIG
      chattr +i $RESOLV_CONFIG
      # restart unbound
      if pgrep systemd-journal; then
        systemctl enable unbound
        systemctl restart unbound
      else
        service unbound enable
        service unbound restart
      fi
    fi
  }

  # Running Install Unbound
  install-unbound

else

  # take user input
  function take-user-input() {
    echo "What do you want to do?"
    echo "   1) Option #1"
    echo "   2) Option #2"
    echo "   3) Option #3"
    echo "   4) Option #4"
    echo "   5) Option #5"
    until [[ "$USER_OPTIONS" =~ ^[0-9]+$ ]] && [ "$USER_OPTIONS" -ge 1 ] && [ "$USER_OPTIONS" -le 5 ]; do
      read -rp "Select an Option [1-5]: " -e -i 1 USER_OPTIONS
    done
    case $USER_OPTIONS in
    1)
      echo "Hello, World!"
      ;;
    2)
      echo "Hello, World!"
      ;;
    3)
      echo "Hello, World!"
      ;;
    4)
      echo "Hello, World!"
      ;;
    5)
      echo "Hello, World!"
      ;;
    esac
  }

  # run the function
  take-user-input

fi
