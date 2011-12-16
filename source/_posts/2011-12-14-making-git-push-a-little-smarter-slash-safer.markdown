---
layout: post
title: "Making 'git push' a little smarter/safer"
date: 2011-12-15T16:41:47-0800
comments: true
categories:
---

Without any additional command line options `git push`'s behavior is
almost never what I actually want it to do, since I rarely wish to
push more than one branch at once, and often work with multiple
remotes where I have push access.

Even though I am generally in the habit of always supplying both the
remote and a list of refs when pushing (`git push <remote> <ref1> [..<refN>]`)
I'd rather not have anything potentially dangerous or unwanted happen
if I happen to leave off the ref(s) (or very rarely both the remote and
the ref(s)).

<!--more-->

By default Git will first pick a remote to use for the push by
checking the value of `branch.${current-branch}.remote`.  You can see
which remote this will be by running the command shown below.  Git
will skip this bit if you specify the remote but still leave off the
ref(s) to push.


``` bash Show the default push remote for current branch
git config branch.$(git rev-parse --abbrev-ref HEAD).remote
```

Next, Git will compare the list of local branches with the list of remote
branches in the remote repository found earlier, and will attempt to
update all branches with the same name.

This automatic discovery of not only the remote to use, but also what
to push is almost never going to end up being what I want.
Thankfully, since 1.6.3 Git has had a configuration option
(`push.default`) to specify what the default behavior should be.  This
config option is fully documented from `git help config`.

My preferred setting is `nothing` (do not push anything), since
leaving off the ref is almost always an error given how I work with
Git.  I used to use the `current` (push the current branch to a branch
of the same name) setting, but found that the few times I did leave
off the ref portion of the push command, it was almost always in
error.

By setting `git config --global push.default nothing`, it forces me to
be explicit about where I wish to push, and what I wish pushed there
every time I run `git push`.  While this may seem like a bit of a
pain, it is a small hurdle that I quickly got used to.  It also
significantly lessens the likelihood that I am going to affect the
remote repository in unexpected ways, which is a huge win when I'm
working with shared repositories (whether they're internal "corporate"
repositories, or public open source projects).
