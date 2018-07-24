# BJGM

## what is it?

there is a bash script named 'mb_new_entry.sh' that works in Unixoid systems
(provided that git and vim are available) as well as Android (in a
[termux][] environment). This works together with a [jekyll][] instance hosted
wherever, provided this wherever can be pushed to via git.


## how to use it

### setup on the server

#### the git part

Use a [bare git repository](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server) on the webserver that acts as the master repository in to which all clients that can post entrys push to. This repository I have called  

	microblog.git

for obvious reasons. Also on the server, create a clone of this bare repository that contains a working copy created via  

	git clone microblog.git

In order to make sure that this clone is always up-to-date, set a post-receive-hook in the config of the bare repository that looks like this:  

	#!/bin/bash
	
	cd ~/microblog
	GIT_DIR=.git git pull origin master

so whenever we push to the bare repository from some other client (like e.g. your laptop), the working copy on the server immediately does a pull.
 
#### the Jekyll part

Inside the repository lives a [jekyll](https://jekyllrb.com/) instance using some pretty theme. I personally use the [Hydejack](https://qwtel.com/hydejack/) theme, but obviously a lot of themes would work. The overall jekyll config is beyond the scope of this document, but a few things are important for microblogging. One relevant line in the '_config.yml' file is  

	destination: /the/microblog/directory/in/the/webserver/

and further

	defaults:
	  - 
	    scope: 
	      path: "_posts"
	    values:
	      layout: post
	      title: ""

In this way, a new post can be created with minimal yaml frontmatter, i.e. only the 'date:' line is needed. Using the 'title: ""' trick creates microblog-like entries in that they have no title (this only works if you explicitly set an empty title).

#### doing it manually

Now the workflow would be something like (on whatever client that has a checkout of the git repository above)  

	$ cd ~/microblog/_posts
	$ vim 1971-01-01-01.md # here we need the date and a running numer
	$ # now I edit the file, the yaml frontmatter needs
	$ # date: 1971-01-01 00:00
	$ # in between two sets of three dashes (---)
	$ git add 1971-01-01-01.md
	$ git commit -a -m 01
	$ git push

On the server, in the checked out working copy directory, wehave the following command running:  

	$ bundle exec jekyll build --watch

which means that as soon as a new entry appears (via the post-receive hook above), the jekyll site rebuilds itself.

#### creation via shell script

Doing those steps above manually is a PITA. Therefore, you can use <mb_new_entry.sh> instead. Put this somewhere in your $PATH (like ~/bin) and running this will go through the steps outlined above for you.






[termux]: https://termux.com/
[jekyll]: https://jekyllrb.com/
