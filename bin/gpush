#!/bin/bash

# Function to check if the current branch is the main branch
#Make variable for the branch the script is running on so all the functions can use it
current_branch=$(git rev-parse --abbrev-ref HEAD)
MainBranch() {
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    echo "You are on the main branch. Please switch to a feature branch before pushing changes."
    exit 1
  fi
}
# Function to push changes to the remote repository
PushChanges() {
  local commit_message="$1"
  git add .
  git commit -m "$commit_message"
  git push origin "$current_branch"
}

# Main script execution
if [ -z "$1" ]; then
  echo "Usage: $0 <commit_message>"
  exit 1
else
  MainBranch
  PushChanges "$1"
fi
