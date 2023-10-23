#!/bin/bash

# Dynamically generate the list of sites based on directories in /home/virtual/
SITES=($(ls -d /home/virtual/site* | awk -F'/' '{print $NF}'))

for site in "${SITES[@]}"; do
    # Check if Redis exists for the site
    if cpcmd -d $site redis:exists $site | grep -q 1; then
        # Check if Redis is running for the site
        if ! cpcmd -d $site redis:running $site | grep -q "[0-9]"; then
            # Redis is not running for the site, so we start it
            cpcmd -d $site redis:start $site
            echo "Started Redis for $site"
        fi
    fi
done
