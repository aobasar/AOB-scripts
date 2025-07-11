#!/bin/bash

#!/bin/bash

# This script searches for all GitHub repository links inside a specified directory and its subdirectories.
# It identifies Git repositories by locating the ".git/config" files and extracts the repository URLs.
# Specifically, it looks for URLs associated with GitHub (both HTTPS and SSH formats).

# Usage:
# ./find_github_repos.sh <directory>
# Replace <directory> with the path of the folder where you want to search for GitHub repos.

# How it works:
# 1. The script takes one argument, which is the directory to search in.
# 2. It uses the `find` command to locate all "config" files within ".git" directories.
# 3. For each found config file, it uses `grep` to look for lines containing the GitHub URL (either HTTPS or SSH).
# 4. The `awk` command extracts the third field from the line, which is the repository URL.
# 5. If a GitHub URL is found, it is printed to the console.
# 
# Notes:
# - If no directory is provided as an argument, the script will exit with an error message.
# - This script only looks for GitHub repositories; other Git remotes (e.g., Bitbucket, GitLab) will be ignored.


# Check if a directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# The directory to search
SEARCH_DIR=$1

# Find all .git/config files in the specified directory
find "$SEARCH_DIR" -type f -name config -path '*/.git/*' | while read -r config_file
do
  # Extract the repository URL from the config file
  repo_url=$(grep -E 'url = https://github\.com|git@github\.com' "$config_file" | awk '{print $3}')
  
  # If a GitHub URL is found, print it
  if [ ! -z "$repo_url" ]; then
    echo "Repository found: $repo_url"
  fi
done
