#!/bin/bash

# 8GB in KB
threshold=8000000

# Find all passwd files in /home/virtual/site*/shadow/etc/
for passwd_file in /home/virtual/site*/shadow/etc/passwd; do
  # Extract the site name from the path
  site=${passwd_file%/shadow/etc/passwd}
  site=${site#/home/virtual/}

  echo "Processing site: $site"

  # Extract users from the passwd file, skipping the first user and user named "postgres"
  users=$(awk -F':' 'NR>1 && /bash$/ && !/postgres/{print $1}' "$passwd_file")

  # Iterate over each user and get their quota
  for user in $users; do
    echo "Processing user: $user"

    QUOTA=$(cpcmd -d "$site" user_get_quota "$user")

    echo "Quota for user $user:"
    echo "$QUOTA"

    qhard=$(echo "$QUOTA" | awk '/qhard:/ {gsub(/[ \t]+/, ""); print substr($0, 7)}')

    # Check if qhard is strictly less than 8GB (threshold)
    if [[ -n $qhard ]] && (( qhard < threshold )); then
      echo "Changing quota for user $user to $threshold"
      cpcmd -d "$site" user_change_quota "$user" 8196
    elif [[ -z $qhard ]]; then
      echo "Changing quota for user $user to $threshold"
      cpcmd -d "$site" user_change_quota "$user" 8196
    else
      echo "Skipping user $user as their quota is already greater than or equal to $threshold"
    fi
  done
done
