--- 
layout: post
title: "Fun with the upcoming 1.7 release of Git: rebase --interactive --autosquash"
date: 2010-02-07T17:50:00-08:00
comments: true
categories: [development, git, tips]
updated_at: 2010-02-13T22:37:28-08:00
---

The upcoming Git 1.7 has a _lot_ of really nice improvements, and new features.
One of the big new features is the `--autosquash` argument for `git rebase
--interactive`.

<!--more-->

If you're anything like me, then you commit a _lot_, while you're working on
something, and use `git rebase --interactive` judiciously to clean up all these
incremental commits into a presentable format.  If you're a bit more like me,
then you'll often end up doing multiple `git rebase --interactive` passes to
split commits apart, and squash them back into other commits.

Git just gained the ability to make this a little faster.  If you know what
commit you want to squash something in to you can commit it with a message of
"squash! $other_commit_subject".  Then if you run `git rebase --interactive
--autosquash commitish`, the line will automatically be set as `squash`, and
placed below the commit with the subject of `$other_commit_subject`.

For example:

``` bash Prepare commits for use with --autosquash
$ vim Foo.txt
$ git commit -am 'Change all the "Bar"s to "Foo"s'
[topic 8374d8e] Change all the "Bar"s to "Foo"s
 1 files changed, 2 insertions(+), 2 deletions(-)
$ vim Bar.txt
$ git commit -am 'Change all the "Foo"s to "Bar"s'
[topic 2d12ce8] Change all the "Foo"s to "Bar"s
 1 files changed, 1 insertions(+), 1 deletions(-)
$ vim Foo.txt
$ git commit -am 'squash! Change all the "Bar"s'
[topic 259a7e6] squash! Change all the "Bar"s
 1 files changed, 2 insertions(+), 1 deletions(-)
```

If we run `git rebase --interactive --autosquash origin/master` from here, the
pick-list will look like this:

``` bash Generated picklist
pick 8374d8e Change all the "Bar"s to "Foo"s
squash 259a7e6 squash! Change all the "Bar"s
pick 2d12ce8 Change all the "Foo"s to "Bar"s

# Rebase b6bee12..259a7e6 onto b6bee12
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#
# If you remove a line here THAT COMMIT WILL BE LOST.
# However, if you remove everything, the rebase will be aborted.
#
```

When you get to the `squash`, you'll have a commit message like:

``` bash Generated commit message
# This is a combination of 2 commits.
# The first commit's message is:

Change all the "Bar"s to "Foo"s

# This is the 2nd commit message:

squash! Change all the "Bar"s

# Please enter the commit message for your ch anges. Lines starting
# with '#' will be ignored, and an empty mess age aborts the commit.
# Not currently on any branch.
# Changes to be committed:
#	modified:   Foo.txt
#
```

If you were paying attention earlier to the pick-list, you'll notice that
there's also a `fixup` command available.  If we had specified `fixup!`,
instead of `squash!` as the commit message's prefix, then the pick list would
have ended up as:

``` bash Generated picklist
pick 8374d8e Change all the "Bar"s to "Foo"s
fixup cfc6e54 fixup! Change all the "Bar"s
pick 2d12ce8 Change all the "Foo"s to "Bar"s

# Rebase b6bee12..cfc6e54 onto b6bee12
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#
# If you remove a line here THAT COMMIT WILL BE LOST.
# However, if you remove everything, the rebase will be aborted.
#
```

With the following in your editor for the combined commit message:

``` bash Generated commit message
# This is a combination of 2 commits.
# The first commit's message is:

Change all the "Bar"s to "Foo"s

# The 2nd commit message will be skipped:

#	fixup! Change all the "Bar"s

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# Not currently on any branch.
# Changes to be committed:
#	modified:   README.markdown
#
```

Notice that the `fixup!` commit's message is already commented out.  You can
just save out the message as-is, and your original commit message will be kept.
Very handy for including changes when you realize that you forgot to add part
of an earlier commit.

Here's a few aliases I have setup to make all this easier:

``` ini ~/.gitconfig aliases
[alias]
    fixup = !sh -c 'git commit -m \"fixup! $(git log -1 --format='\\''%s'\\'' $@)\"' -
    squash = !sh -c 'git commit -m \"squash! $(git log -1 --format='\\''%s'\\'' $@)\"' -
    ri = rebase --interactive --autosquash
```

Here's how they would be used in our previous example:

``` bash Example using aliases
$ vim Foo.txt
$ git commit -am 'Change all the "Bar"s to "Foo"s'
[topic 8374d8e] Change all the "Bar"s to "Foo"s
 1 files changed, 2 insertions(+), 2 deletions(-)
$ vim Bar.txt
$ git commit -am 'Change all the "Foo"s to "Bar"s'
[topic 2d12ce8] Change all the "Foo"s to "Bar"s
 1 files changed, 1 insertions(+), 1 deletions(-)
$ vim Foo.txt
$ git add Foo.txt
$ git squash HEAD~2
[topic 259a7e6] squash! Change all the "Bar"s to "Foo"s
 1 files changed, 2 insertions(+), 1 deletions(-)
$ git ri origin/master
```

Similarly, `git fixup HEAD~2` would create a `fixup!` commit to be used with
`git rebase --interactive --autosquash` (Aliased as: `git ri`).

*Edit 2010-02-13:* Fix alias examples.
*Edit 2011-12-11:* Change 'Foo's to "Foo"s to avoid grammar confusion.
