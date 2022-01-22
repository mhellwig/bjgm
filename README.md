# BJGM

## what is it?

there is a bash script named 'mb_new_entry.sh' that works in Unixoid systems
(provided that git and vim are available) as well as Android (in a
[termux][] environment). This works together with a [jekyll][] instance hosted
wherever, provided this wherever can be pushed to via git.

As of 2022-01-22, the script also includes a line to post the same content to
Mastodon, provided the program <https://github.com/ihabunek/toot> is set up
correctly with an account.


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

On the server, in the checked out working copy directory, we have the following command running:  

	$ bundle exec jekyll build --watch

which means that as soon as a new entry appears (via the post-receive hook above), the jekyll site rebuilds itself.

#### systemd for jekyll

What does "we have the following command running" mean? For starters, and in order to get everything
set up in the first place, just use the tmux (screen would work as well)
instance that you have running perpetually anyway (you do, don't you?) and start that jekyll command in
there. 

Not that I'm a big believer or proponent of systemd,
but in German, we have a term called "Die normative Kraft des Faktischen"
which can be translated as "the normative power of the factual". So .. yeah.
Whatever. It exists, it is the default on most distros, I don't care enough to
fight some [rearguard action][] or whatever.

Therefore:

Step one, copy the file [jekyll.service](jekyll.service) to

	/home/<username>/.config/systemd/user/

This can now be run with

	$ systemctl --user start jekyll

and the output checked with

	$ journalctl --user -f -u jekyll

If everything looks ok, make the service permanent with

	$ systemctl --user enable jekyll

This would still only start the jekyll process once one logs into the system
and also kill it once one logs out. In order to make it truly permanent, the
admin user needs to run the command

	% loginctl enable-linger <username>

which causes our jekyll unit to be run on bootup and killed on shutdown.





### on the client

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
	$ tail -n +4 1971-01-01-01.md | toot post


#### creation via shell script

Doing those steps above manually is a PITA. Therefore, you can use [mb_new_entry.sh](mb_new_entry.sh) instead. Put this somewhere in your $PATH (like ~/bin) and running this will go through the steps outlined above for you.


## TODO

features that should theoretically be easily implemented and also I want them:

* a solution for termux' "share to termux"-feature that creates a microblog-post with a photo
* more vim trickery for creating posts with pictures (think like vim-latex works re jumping to the next necessary point in a file)


## References

Documents that helped me figure this out:

* a page at [archlinux wiki][]
* this [blog article][], where somebody does something similar, but as a
  system-wide service (which I explicitly wanted to avoid)
* and of course a page at [unix.stackexchange][]


[rearguard action]: https://devuan.org/
[termux]: https://termux.com/
[archlinux wiki]: https://wiki.archlinux.org/index.php/Systemd/User#Writing_user_units
[blog article]: https://yuan3y.com/2017/09/make-jekyll-serve-a-systemd-service/
[unix.stackexchange]: https://unix.stackexchange.com/questions/200654/executing-chdir-before-starting-systemd-service
[jekyll]: https://jekyllrb.com/
