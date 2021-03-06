--- 
layout: post
title: "Capistrano completion in zsh"
date: 2009-10-06T23:03:00-07:00
comments: true
categories: [capistrano, completion, zsh]
updated: 2010-09-29T22:54:24-07:00
---

I've decided to try out zsh for a while, and while I already get
completions for most everything I want, out of the box, I am missing
completions for Capistrano tasks.

I had been using
[brynary's Bash Capistrano completion script][brynary-bash-completion].
I was able to find [a mailing list post][list-post] about setting up
Capistrano task completions for zsh, but it didn't quite work for
me. (`show_tasks` isn't a valid task.)  I also didn't like throwing
the `.cap_tasks` file in the top-level of the project.  I already had
a `~/.zsh_cache/` directory for caching zsh's completions, so I
decided to modify the script I found to put the cache file there,
instead.

<!--more-->

``` bash ~/.zsh.d/S50_capistrano
_cap_does_task_list_need_generating () {
  if [ ! -f cap_tasks ]; then return 0;
  else
    accurate=$(stat -f%m ~/.zsh_cache/cap_tasks-$(echo $PWD | sha512sum))
    changed=$(stat -f%m config/deploy.rb)
    return $(expr $accurate '>=' $changed)
  fi
}

_cap () {
  if [ -f config/deploy.rb ]; then
    if _cap_does_task_list_need_generating; then
      cap -T | grep '^cap' | cut -d' ' -f2 >! ~/.zsh_cache/cap_tasks-$(echo $PWD | sha512sum)
    fi
    compadd `cat ~/.zsh_cache/cap_tasks-$(echo $PWD | sha512sum)`
  fi
}

compdef _cap cap
```

I have the above in `~/.zsh.d/S50_capistrano`, which automatically gets loaded
on startup.

``` bash ~/.zshrc
for zshrc_snipplet in ~/.zsh.d/S[0-9][0-9]*[^~] ; do
    source $zshrc_snipplet
done
```

*Update (2010-09-29):* Use archive.org link to brynary's blog post.

[list-post]: http://www.mail-archive.com/capistrano@googlegroups.com/msg00994.html "Setting up Capistrano completion"
[brynary-bash-completion]: http://web.archive.org/web/20071028153929/http://www.brynary.com/2007/5/3/tab-completion-for-capistrano-tasks-in-bash "Archive.org link to brynary's post"
