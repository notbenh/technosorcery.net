---
layout: post
title: "Colorizing Git output"
date: 2011-12-10T19:34:32-0800
comments: true
categories: [git]
---

There is a simple tweak to make working with Git a lot nicer that
people often don't know about, or forget to do is turn on Git's
ability to colorize its output.

<!--more-->

From the command line you can `git config --global color.ui auto`, or
edit your `.gitconfig` directly.

``` ini ~/.gitconfig
[color]
  ui = auto
```

This will automatically colorize (among other things) the output from
`git log`, `git status`, `git show`, and `git add -i`.

For example, `git status` will now show files with staged changes in
green, and unstaged and untracked files in red.  As shown below:

{% img /images/posts/2011-12-10-colorizing-git-output/colorized-git-status.png Colorized 'git status' output %}

Another example of the improved output after setting the colorization
option is how `git add -i` will colorize the shortcut letters of its
various commands.

{% img /images/posts/2011-12-10-colorizing-git-output/colorized-git-add-i.png Colorized 'git add -i' output %}
