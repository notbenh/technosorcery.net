--- 
kind: article
title: Ditching dynamic blog engines.
tags: [mephisto, perl, ruby, wordpress, www-staticblog]
created_at: 2010-04-02T21:45:43-07:00
---

A while back, I'd ditched [WordPress][WordPress] in favor of
[Mephisto][Mephisto].  I'd grown tired of constantly being under
attack from spammers, and really disliked that it was one gigantic PHP
app.

Once I was on Mephisto, I really liked the syntax highlighting I got
with the [Ultraviolet Gem][Ultraviolet], but it requires
[Oniguruma][Oniguruma], which was a pain to setup on my shared host
(they have since added it to their hosts).  Life was good.

Except that it wasn't.  It was a little annoying how long it took pages
to come up in the "cold cache" case, and I'd actually gotten a few
complaints about that.  After this, I decided that I was just going to
do away with "dynamic blog engines" entirely.

Enter [WWW::StaticBlog][WWW-StaticBlog].  I decided that I was just
going to statically generate every page, and upload them to the shared
host.  No more worrying about spammers trying to "hack" my site, and
no more slow page loads waiting for a full Ruby on Rails app to start
up.

So far the features of WWW::StaticBlog are:

* Pluggable templating system.  (Currently only has a plugin for
  [Template::Toolkit][Template-Toolkit])
* Support for tagging articles, and browsing articles by arbitrary
  combinations of tags.
* Atom feed for posts.
* Support for purely static content.

Things I plan on adding:

* Author pages, with the ability to browse posts by author.
* Support for more templating engines ([Template::Mustache][Template-Mustache]
  will probably be the next one.)
* Archives pages to view past posts by year/month.
* Only generate the pages that have actually changed, instead of
  regenerating everything, every time.

The idea behind [WWW::StaticBlog][WWW-StaticBlog] is that the host
does not need to have support for _anything_, other than serving up
static files, and you'll still have what would look like a dynamically
generated site.

As a live example of how to use [WWW::StaticBlog][WWW-StaticBlog], you
can check out the
[Git repository for this site](https://github.com/jhelwig/technosorcery.net "Git repository for technosorcery.net").

[Mephisto]: http://mephistoblog.com/ "Mephisto blog engine"
[Oniguruma]: http://oniguruma.rubyforge.org/ "Oniguruma gem"
[Template-Mustache]: https://github.com/pvande/Template-Mustache "Mustache for Perl"
[Template-Toolkit]: http://template-toolkit.org/ "Perl's Template::Toolkit"
[Ultraviolet Gem]: http://ultraviolet.rubyforge.org/ "Ultraviolet gem"
[WWW-StaticBlog]: https://github.com/jhelwig/WWW-StaticBlog "WWW::StaticBlog 'engine'"
[WordPress]: http://wordpress.org/ "WordPress blog engine"
