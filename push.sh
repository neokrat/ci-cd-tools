#!

. ./settings.sh

commit_message=$(date +"%Y-%m-%d-%H-%M-%S")

echo $GIT_USERNAME
echo $GIT_APP_PASSWORD
echo $GIT_REPOSITORY

git add .
git commit -m $commit_message
git push https://$GIT_EMAIL:$GIT_APP_PASSWORD@$GIT_REPOSITORY
