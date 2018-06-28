#!/bin/env bash
#
# make a new entry for the microblog

# user configurable - location of where new posts should go
mb_location="$HOME/microblog/_posts/";

# set up variables
today=$(date +%F);
now=$(date +%F\ %H:%M);
iterator=1;
filename=$today-$(printf "%02d" $iterator).md;

cd $mb_location;

# make sure we have the hottest newest latest
git pull;

# determine the first available file for today
while [ -f $filename ]
  do iterator=$(($iterator+1));
  filename=$today-$(printf "%02d" $iterator).md;
done

# pre-populate the file
echo "---
date: $now
---
" > $filename;


# start editing
vim +star +4 $filename;

# and upload
git add $filename;
git commit -a -m $iterator;
git push;

echo "
all done with $filename;
";
