#!/bin/bash
#
# nbox 2.5 pwnage checker
#
# It must run locally in the nbox machine to verify the pwnage.
#
# (@javutin)
#
#     **** Here comes the paintrain! ****
#
#         . lol . lol . lol o
#                 _____      o
#      ______====  ]OO|_n_n__][.           _______
#     [__________]_|__|________)<          | nbox |
#      oo  oo   oo  'oo OOOO-| oo\\_        ~~|~~~
#  +--+--+--+--+--+--+--+--+--+-$1-+--+--+--+--+--+--+

# Constants
PWN="\e[00;32mPWN\e[00m"
NOPE="\e[00;31mNOPE\e[00m"

NBOX_IP="127.0.0.1"
NBOX_PATH="ntop-bin"
NBOX_URL="https://$NBOX_IP/$NBOX_PATH"
NBOX_USER="nbox"
NBOX_PASSWORD="nbox"

# Some functions because we can

# Tchoo Tchoo!
function paintrain() {
  echo ""
  echo "         . lol . lol . lol o"
  echo "                 _____      oA"
  echo "      ______====  ]OO|_n_n__][.           _______"
  echo "     [__________]_|__|________)<          | nbox |"
  echo "      oo  oo   oo  'oo OOOO-| oo\\\\_        ~~|~~~"
  echo "  +--+--+--+--+--+--+--+--+--+-$1-+--+--+--+--+--+--+"
  echo ""
  echo "    **** Here comes the paintrain! ****"
  echo ""
}

# Make sure we haz curl
function check_curl() {
  if [[ -z "$(which curl)" ]]; then
    echo "[!] You need curl to continue..."
    exit 1
  fi
}

# Helpers curl commands to make the code better. Because bash

# $1 is path to hit
function nbox_get() {
  local __path=$1

  curl -sk --user "$NBOX_USER":"$NBOX_PASSWORD" "$NBOX_URL"/"$__path"
}

# $1 is path to hit
# $2 is POST parameters
function nbox_post() {
  local __path=$1
  local __data=$2

  curl -sk --user "$NBOX_USER":"$NBOX_PASSWORD" --data="$__data" "$NBOX_URL"/"$__path"
}

# Eject when error
set -e

# Ascii art is always appreciated
paintrain

echo "[+] Checking nbox is running..."
NBOX_VERSION=`nbox_get dashboard.cgi | grep "NTOP" | cut -d">" -f3 | cut -d"<" -f1`

if [[ -z "$NBOX_VERSION" ]]; then
  echo "[!] ERROR: nbox is not running at $NBOX_URL"
  exit 1
else
  echo "[+] Success: Found $NBOX_VERSION running in $NBOX_URL"
fi

echo "[+]"

# kthnxbai
