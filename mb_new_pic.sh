#!/bin/bash
#
# make a new entry for the microblog including a picture
# the picture should be a file in ~/microblog/images/ and should
# have been git added before you run this script

mb_location=$HOME/microblog/;
post_location=$mb_location"_posts";

# set up my variables
today=$(date +%F);
now=$(date +%F\ %H:%M);
iterator=1;
filename=$today-$(printf "%02d" $iterator).md;

cd $post_location;

# make sure we have the hottest newest latest
git pull;

# determine the first available file for today
while [ -f $filename ]
  do iterator=$(($iterator+1));
  filename=$today-$(printf "%02d" $iterator).md;
done

# pre-populate the file
# you can remove the all-caps helper text ..
echo "---
date: $now
---
TEXT GOES HERE
![PIC TITLE GOES HERE]({{\"images/PIC FILENAME GOES HERE\"|absolute_url}} \"PIC DESCRIPTION GOES HERE\")
" > $filename;

# start editing
vim +star +4 $filename;

# and upload
git add $filename;
git commit -a -m $iterator;
git push;

# now create the necessary variables for tooting, one with the image filename,
# one with the image description and one with the toot text
imagefile=$(grep absolute_url $filename | cut -d \" -f 2);
description=$(grep absolute_url $filename | cut -d \" -f 4);
toot_txt=$(sed -n -e 4p $filename);

# aaaand toot toot!
cd $mb_location;
/usr/bin/toot post -m $imagefile -d "$description" "$toot_txt";

echo "
all done with $filename;
"
