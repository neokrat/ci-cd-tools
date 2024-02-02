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
    echo "Base branch '$base_branch' created. Continuing with actions on '$current_branch' branch."
else
    echo "Base branch '$base_branch' already exists. Continuing with actions on '$current_branch' branch."
fi

# Inform user about the merge operation
echo "You are about to merge '$current_branch' into '$base_branch' with changes to the '.semaphore' folder ignored."
read -p "Do you wish to continue? (y/n) " -n 1 -r
echo    # move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Merge aborted. You can continue to work on '$current_branch'."
    exit 1
fi

# Perform the merge
git checkout $base_branch
git merge --no-ff --no-commit $current_branch
git reset HEAD -- .semaphore
git checkout -- .semaphore

# Inform the user of the successful merge
echo "'$current_branch' is now merged into '$base_branch' with changes to the '.semaphore' folder ignored. You are currently on '$base_branch'. If your work on '$current_branch' is complete, you can continue to work on '$base_branch' and push your code."

# Optionally, switch back to the testing branch
git checkout $current_branch
echo "Switched back to '$current_branch'. Continue your work or switch to '$base_branch' to push your changes."
