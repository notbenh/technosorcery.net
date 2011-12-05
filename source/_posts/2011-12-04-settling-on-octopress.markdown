---
layout: post
title: "Settling on Octopress"
date: 2011-12-04T16:20:08-0800
comments: true
categories: 
---

A while back, I ditched Mephisto in favor of a static site generator
I'd written in Perl (WWW::StaticBlog).  When setting up a new laptop,
and preparing to write a new post, I discovered that one of its
dependencies (Text::Multi) is no longer on CPAN.  In my haste to set
something up I ended up deploying a new version of the site using
[nanoc][], before fully working out the kinks.  Turns out that nanoc
[doesn't really support having pygments output line numbers in the "table" format][nanoc-issue],
and working on fixing this was more work than I was willing to put in
when there are many alternatives out there.

<!--more-->

When I was looking around at static site generators, I'd also run
across [Octopress][], and was initially turned off of it because of
the instructions for [bootstrapping][setup-octopress] and
[updating][update-octopress] encourage users to fork the upstream
repository, and build their site directly in the fork.  I would have
expected (and still would like) something more along the lines of how
Ruby on Rails handles this with `octopress new site` creating a site
directory with all of the skeleton files in there.

The handling of syntax highlighting code blocks is handles well enough
that I'm willing to live with throwing the code directly in the
Octopress repository (as long as I keep reminding myself that
Octopress is just a set of Jekyll filters/plugins and a default
theme), especially since I'm comfortable enough working with
repositories with multiple remotes.

So...if you've noticed the RSS feed seeming to "reset", it's because
of the WWW::StaticBlog to nanoc to Octopress migrations that the site
has been going through, and this should be the last reset for a while.

[nanoc]: http://nanoc.stoneship.org/ "nanoc site generator"
[nanoc-issue]: https://github.com/ddfreyne/nanoc/issues/71 "ColorizeSyntax filter removes all code with ':pygmentize => { :linenos => :table }'"
[octopress]: http://octopress.org/ "Octopress: A blogging framework for hackers."
[setup-octopress]: http://octopress.org/docs/setup/ "Instructions for installing Octopress"
[update-octopress]: http://octopress.org/docs/updating/ "Instructions for keeping Octopress up to date"
