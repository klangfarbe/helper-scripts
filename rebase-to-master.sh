#!/bin/bash

git fetch

branches=(`git branch -r | grep -v origin/master`)

logfile="`dirname $0`/rebase-failed.log";

git clean -fdX
git checkout master
git merge --ff-only origin/master || git reset --hard origin/master

for branch in ${branches[@]}; do
  # check if rebase is required otherwise skip this branch
  if [ `git merge-base master $branch` = `git rev-parse master` ]; then
    continue
  fi

  commit=`git rev-parse $branch`

  # check if branch was failing before then skip it
  if [ -e "$logfile" ] && grep -q "$branch:$commit" $logfile ; then
    continue
  fi

  # do the rebase
  echo
  echo "----------------------------------------------------------------------"
  echo "Rebase: $branch (sleeping 5 seconds to abort...)"
  echo "----------------------------------------------------------------------"
  sleep 5

  git checkout --track $branch || continue
  git rebase master

  if [ $? != 0 ]; then
    echo "$branch:$commit" >> $logfile
    git rebase --abort
  else
    git push --force-with-lease

    # Remove branch from $logfile
    grep -v $branch $logfile > rebase-tmp.log
    mv rebase-tmp.log $logfile
  fi

  branch_to_delete=`git branch | grep '*' | awk '{print $2}'`
  git checkout master
  git branch -D $branch_to_delete

  echo
done

exit
