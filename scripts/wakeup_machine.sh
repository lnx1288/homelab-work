#!/bin/bash

# Usage: ./wol.sh <MAC_ADDRESS>

MAC="$1"

if [ -z "$MAC" ]; then
    echo "Usage: $0 <MAC_ADDRESS>"
    exit 1
fi

# Check if wakeonlan command exists
if ! command -v wakeonlan >/dev/null 2>&1; then
    echo "Error: wakeonlan command not found."
    echo "Please install it using: sudo apt install wakeonlan"
    exit 1
fi

# Send the magic packet
wakeonlan "$MAC"