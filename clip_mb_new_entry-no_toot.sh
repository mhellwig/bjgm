#!/bin/bash
#
# make a new entry for the microblog
# this is for the cases where you want to tweak stuff and then 
# post elsewhere afterwards, therefore the post text is put onto
# the clipboard and you can then ctrl+v it wherever (say into the
# mastodon web-interface)
# this is a stopgap measure untill I figure out an automatic way
# to include Content Warnings/Notes into my posting flow.

# set up my variables
today=$(date +%F);
now=$(date +%F\ %H:%M);
iterator=1;
filename=$today-$(printf "%02d" $iterator).md;

# go to working dir
cd ~/microblog/_posts;

# make sure we have the hottest newest latest
git pull;

# determine the first available file for today
while [ -f $filename ]
  do iterator=$(($iterator+1));
  filename=$today-$(printf "%02d" $iterator).md;
done

# create the file
touch $filename;

# pre-populate the file
echo '---' >> $filename;
echo -n 'date: ' >> $filename;
echo $now >> $filename;
echo '---' >> $filename;
echo >> $filename;

# start editing
vim +star +4 $filename;

# and upload
git add $filename;
git commit -a -m $iterator;
git push;

# put post text into clipboard
tail -n +4 $filename | xclip -r -selection clipboard

echo;
echo all done with $filename;
echo;
