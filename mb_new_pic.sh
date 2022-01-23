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
# note on the <+markers+>: you can just start typing and enter your post
# text. Then hit ctrl+j and vim jumps to the the next marker and 
# highlights it, so if you continue typing it'll be overwritten. Then
# hit ctrl+j again and so forth
echo "---
date: $now
---
  
![<+title+>]({{\"images/<+filename+>\"|absolute_url}} \"<+description+>\")
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
