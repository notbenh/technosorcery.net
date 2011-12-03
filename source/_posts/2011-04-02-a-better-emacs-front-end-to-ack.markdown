--- 
layout: post
title: A better emacs front-end to ack
date: 2011-04-02T10:41:10-07:00
comments: true
categories: [ack, emacs, lisp]
updated_at: 2011-04-12T20:51:58-07:00
---

I've been giving emacs a try after having probably the most civilized
"emacs vs. vim" discussion I've ever seen or been a part of.  The
discussion took place just over two weeks ago at the
[PDX Hackathon](http://twitter.com/pdxhackathon) with
[Brian Rice](http://twitter.com/BrianTRice "Brian Rice's Twitter account")
(emacs) and [Ben Hengst](http://twitter.com/notbenh "Ben Hengst's Twitter account")
(vim).

<!--more-->

I've discovered a few things in working with emacs that I really wish
vim had, and I've really missed a few things that I had from vim.  I'm
trying to make sure that I give emacs a fair shot, so I'm trying out a
few elisp scripts, and tweaking things as I go along, since my vim
setup is hardly "stock".

This tweaking has led me to try out
[ack.el](http://rooijan.za.net/code/emacs-lisp/ack-el) and
[full-ack.el](http://nschum.de/src/emacs/full-ack/).  I liked
`ack.el`'s usage of emacs's compilation mode, but hated having to
construct the `ack` command line myself (including the directory to
`ack`).  `full-ack.el` handled constructing the `ack` command line
much better, however I hated how it put the `ack` output into a
temporary buffer of its own, instead of using `emacs`'s compilation
support.  These two scripts seemed ripe for merging into one
super-script with the best features from each.

Thus was born [ack-and-a-half.el](https://github.com/jhelwig/ack-and-a-half)!

Just download the `.el`, and throw something like the following into
your `~/.emacs.d/init.el`

``` common-lisp Add to your init.el
(add-to-list 'load-path "/path/to/ack-and-a-half")
(autoload 'ack-and-a-half-same "ack-and-a-half" nil t)
(autoload 'ack-and-a-half "ack-and-a-half" nil t)
(autoload 'ack-and-a-half-find-file-samee "ack-and-a-half" nil t)
(autoload 'ack-and-a-half-find-file "ack-and-a-half" nil t)
;; Create shorter aliases
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)
```
