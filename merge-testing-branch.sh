#!/bin/bash

# Prefix for testing branches
testing_prefix="testing/"

# Get the name of the current git branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if current branch starts with the testing prefix
if [[ $current_branch != $testing_prefix* ]]; then
    echo "Please checkout to your testing branch. The current branch does not start with '$testing_prefix'."
    exit 1
fi

# Extract the base branch name by removing the prefix
base_branch=${current_branch#$testing_prefix}

# Check if the base branch exists
if ! git show-ref --verify --quiet refs/heads/$base_branch; then
    # Create the base branch and switch back to the testing branch
    git branch $base_branch
fi

# Refresh the local cache of remote branches
git fetch origin

# Check if there are any local commits that have not been pushed to the remote branch
local_commits=$(git rev-list --count origin/$current_branch..HEAD)

if [ "$local_commits" -gt 0 ]; then
    echo "Your branch is ahead of 'origin/$current_branch'. Please push your changes before merging."
    exit 1
fi

# Check for uncommitted changes (both staged and unstaged changes)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "You have uncommitted changes. Please commit or stash them before merging."
    exit 1
fi

# Check for untracked files
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "You have untracked files. Please add and commit them, or add them to .gitignore."
    exit 1
fi

# Inform user about the merge operation
echo "You are about to merge '$current_branch' branch into '$base_branch' branch with changes to the '.semaphore' folder ignored."
read -p "Do you wish to continue? (y/n) " -n 1 -r
echo    # move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Merge aborted. You can continue to work on '$current_branch' branch."
    exit 1
fi

# Perform the merge
git checkout $base_branch
git merge --no-ff --no-commit $current_branch
git reset HEAD -- .semaphore
git checkout -- .semaphore

# Inform the user of the successful merge
echo "'$current_branch' branch is now merged into '$base_branch' branch with changes to the '.semaphore' folder ignored."

# Optionally, switch back to the testing branch
git checkout $current_branch
echo "Switched back to '$current_branch' branch. Continue your work or switch to '$base_branch' branch to push your changes."
