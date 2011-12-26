---
layout: post
title: "How I use different fetch &amp; push URLs in Git"
date: 2011-12-26T15:10:28-0500
comments: true
categories: [git]
---

I hate having to enter my ssh key passphrase just to fetch from public
Git repositories where I have push access.  Fortunately, since version
1.6.4 Git has had the ability to separately specify the URLs to use
when fetching, and when pushing.  In addition to no longer requiring
me to have my SSH key loaded when I go to fetch, I've noticed that
fetching is now faster without the overhead of SSH.

In order to configure different fetch, and push URLs, you'll need to
add a `pushURL` setting in the `.git/config` for the remotes you want
configured.  With the `url` setting configured to use a `git://` style
URL, and the `pushURL` setup to use an SSH URL (`git@` or `ssh://`),
you can avoid the overhead of SSH when fetching, but still be able to
push to the repository.

``` ini .git/config in the repository
[remote "origin"]
    url = git://github.com/jhelwig/technosorcery.net.git
    pushURL = git@github.com:jhelwig/technosorcery.net.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

This particularly comes in handy on machines where I have GPG Agent
setup to be my SSH Agent (since I have GPG Agent setup with a timeout
which requires unlocking the keys again), and also with projects where
I have multiple remotes where I can push.
