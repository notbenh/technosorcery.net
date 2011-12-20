---
layout: post
title: "Using Git's @{upstream} notation"
date: 2011-12-19T02:01:10-0500
comments: true
categories: [git]
---

One useful feature Git has had since 1.7.0 is the ability to refer to
the branch that another one is tracking using `[branch]@{upstream}`
notation.  I've found this especially handy while working on projects
with multiple committers.

<!--more-->

When working on projects with multiple committers, I usually set my
local copies of the integration branches to track the branch from the
canonical repository (which I typically have as the `upstream` remote)
instead of tracking the copy of the integration branch from my fork of
the repository.  By doing this I can quickly bring my local copy of
the tracking branch up to date with the canonical repository.

``` console Updating the integration branch before merging a topic
% git checkout 2.7.x
% git fetch --all
Fetching origin
Fetching upstream
remote: Counting objects: 20, done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 11 (delta 8), reused 7 (delta 4)
Unpacking objects: 100% (11/11), done.
From git://github.com/puppetlabs/puppet
   45f0855..2fd94d2  2.7.x      -> upstream/2.7.x
% git reset --hard 2.7.x@{upstream}
HEAD is now at 2fd94d2 Merge branch 'tickets/2.7.x/8119' into 2.7.x
```

Normally I don't use the `2.7.x@{upstream}` form, however.  Instead, I
use `@{u}`, which takes advantage of the shorter form, as well as
`@{u}` and `@{upstream}` defaulting to the current branch if none is
specified.  `git reset --hard @{u}` is fairly easy to type, and
trivially aliased to use as a shortcut to make sure the integration
branch is up to date before merging.
