#!/bin/bash

# 10MB in KB
threshold=10240

# Find all passwd files in /home/virtual/site*/shadow/etc/
for passwd_file in /home/virtual/site*/shadow/etc/passwd; do
  # Extract the site name from the path
  site=${passwd_file%/shadow/etc/passwd}
  site=${site#/home/virtual/}

  echo "Processing site: $site"

  # Extract users from the passwd file, skipping the first user and user named "postgres"
  users=$(awk -F':' 'NR>1 && /bash$/ && !/postgres/{print $1}' $passwd_file)

  # Iterate over each user and get their quota
  for user in $users; do
    echo "Processing user: $user"
    
    QUOTA=$(cpcmd -d "$site" user_get_quota "$user")

    echo "Quota for user $user:"
    echo "$QUOTA"

    qused=$(echo "$QUOTA" | awk '/qused:/{print $2}')
    qhard=$(echo "$QUOTA" | awk '/qhard:/{print $2}')

    # Check if qused is within 10MB of qhard
    if (( qhard - qused < threshold )); then
      echo "WARNING: $site, user $user is close to running out of disk space."
    fi
  done
done
