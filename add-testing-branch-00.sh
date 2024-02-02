#!/bin/bash

branch_prefix=testing
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ -n "$current_branch" ]; then
  if [ "$current_branch" == "master" ]; then
    echo "This is the master branch."
    echo "Consider switching to a feature branch if you're working on a specific feature."
    echo "You can create a new feature branch using 'git checkout -b your-feature-name'."
  else
    new_branch="$branch_prefix/$current_branch"

    # Check if the branch already exists
    if git show-ref --verify --quiet "refs/heads/$new_branch"; then
      echo "The branch '$new_branch' already exists."
      git checkout "$new_branch"
      echo "You've been switched to this branch '$branch_prefix/$current_branch',"
      echo "branched from the original feature branch '$current_branch'."
    else
      git checkout -b "$new_branch"
      echo "A new '$new_branch' feature branch has been created."
      echo "You've been switched to this branch '$branch_prefix/$current_branch',"
      echo "branched from the original feature branch '$current_branch'."
    fi
  fi
else
  echo "Not on any Git branch"
fi
