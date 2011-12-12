---
layout: post
title: "Making Git a little less verbose"
date: 2011-12-11T18:31:34-0800
comments: true
categories: [git]
---

Git has some output that can be very helpful to people getting started
with it.  Once you've been using Git for a while, however, you may
find that the advice that Git provides to help deal with certain
situations just ends up taking up screen real estate.  Fortunately,
there is a way to turn off a number of these messages.

<!--more-->

There are currently six settings to adjust the extra help messages
that Git provides by default:

``` ini ~/.gitconfig with all optional messages off
[advice]
  pushNonFastForward = false
  statusHints = false
  commitBeforeMerge = false
  resolveConflict = false
  implicitIdentity = false
  detachedHead = false
```

## pushNonFastForward

`pushNonFastForward` will turn off the extra help output by
`git-push(1)` when attempting to push a non-fast-forward without using
`-f`, or the `+<ref>` form of a ref.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-push-non-fast-forward-with-advice.png Non-fast-forward push with advice %}

Above, we see the output of attempting to push a non-fast-forward, and
below we see the output after setting `advice.pushNonFastForward`.
The difference is only three lines, but the output feels a lot cleaner
especially if you already know how to deal with non-fast-forward
pushes (merging, or forcing as appropriate).

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-push-non-fast-forward-without-advice.png 'Non-fast-forward push without advice' %}

## statusHints

`statusHints` will turn off the hints provided by `git-status(1)` to
help work with changed & new files in the repository.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-status-with-advice.png 'git status' with advice %}

Again, we see the command output above with the advice setting left at
the default of `true`.  Below we can see that we save about four lines of
output every time we run `git status` on the command-line.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-status-without-advice.png 'git status' without advice %}

## commitBeforeMerge

`commitBeforeMerge` will turn off the reminder to commit, or stash
your changes if you have uncommitted changes that conflict with what
you are attempting to merge.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-merge-dirty-tree-with-advice.png 'git merge topic-branch' with advice %}

The difference with `advice.commitBeforeMerge` doesn't save us any
lines of output, but it does help visually distinguish the error
message that includes the list of files, from the line telling us that
Git is aborting our attempt to merge (shown below).

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-merge-dirty-tree-without-advice.png 'git merge topic-branch' without advice %}

## resolveConflict

`resolveConflict` affects multiple commands, all of which share the
scenario of the command aborting due to unresolved conflicts in the
work tree/staging-area.  The example I will show below is trying to
commit before marking all conflicts as resolved.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-commit-conflicts-with-advice.png 'git commit' with unresolved conflicts and advice %}

This is another setting that can save us a couple of lines of output
that don't really help us much after we've done this task a couple of
times.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/git-commit-conflicts-without-advice.png 'git commit' with unresolved conflicts and advice turned off%}

## implicitIdentity

`implicitIdentity` is one that I don't personally use since I have my
name and email set in my `~/.gitconfig`, but can come in handy if you
rely on Git automatically guessing your name and email from the system
you're on.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/guessed-identity-with-advice.png Output from 'git commit' when your identity is guessed and advice is enabled %}

The output after running `git commit` when Git guesses your name and
email is...well...massive.  If you rely on having an email generated
from the FQDN of the current host, you really should turn off this
advice, and save yourself a ton of wasted screen real estate.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/guessed-identity-without-advice.png Output from 'git commit' when your identity is guessed and advice is disabled %}

## detachedHead

`detachedHead` is quite handy if you're comfortable working with Git
in a 'detached HEAD' state (doubly so, if you have your shell prompt
setup to help you remember if you're currently in a detached head
state or not.

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/detached-head-with-advice.png Output from 'git checkout HEAD^0' with advice %}

Turning off the advice when entering a 'detached HEAD' state is
another one that will end up saving huge amounts of screen real estate
once you get comfortable working with this aspect of Git (especially
if you have your prompt remind you)..

{%img /images/posts/2011-12-11-making-git-a-little-less-verbose/detached-head-without-advice.png Output from 'git checkout HEAD^0' without advice %}
