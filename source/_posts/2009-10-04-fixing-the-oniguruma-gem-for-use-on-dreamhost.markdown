--- 
layout: post
title: "Fixing the Oniguruma Gem for use on DreamHost"
date: 2009-10-04T10:33:00-07:00
comments: true
categories: [dreamhost, gems, oniguruma, ruby]
updated: 2010-04-02T21:00:36-07:00
---

While looking at how to get syntax highlighted source back up on here
after switching to Mephisto, I kept running across references to the
Ultraviolet gem.  Some of the dependencies are a little old
(Oniguruma: [Gem][oniguruma-gem], [Library][oniguruma-library]), but
the output looks very nice, from the examples I'd seen.

The problem comes in, that the Oniguruma gem won't install without you
already having the Oniguruma library installed (in a standard system
location).  This is a pretty well documented problem, with a
[simple fix][extconf-patch].

<!--more-->

Unfortunately, I wasn't even able to get the gem to build at all with
the original `Rakefile` that comes with it, and gave up very quickly
on trying to fix it.  Fortunately, there is a wonderful gem out there
called [Jeweler][jeweler].  This allowed me to trivially setup a
working build environment, drop in the original gem code, and get
something up and running.

After adding `dir_config` to the `extconf.rb`, you can happily install
the Oniguruma gem (provided your `LD_LIBRARY_PATH` includes wherever
you installed the library).  This gets to be a problem, when using
Passenger on a shared host (such as DreamHost), like I'm trying to do.
Fortunately, there's a way to fix this (at least on Linux).  When
linking in the libraries, you can tell `ld` to include path
information on where to look for them.  This is very handy.

Here's the `extconf.rb` that I ended up going with:

``` ruby extconf.rb
require 'mkmf'
onig_dirs = dir_config('onig')
onig_libs = onig_dirs.pop
ldshared = CONFIG['LDSHARED']
if !onig_libs.nil?
    onig_libs.split(File::PATH_SEPARATOR).each do |p|
        ldshared += " -Wl,-rpath,#{p}"
    end
end
CONFIG['LDSHARED'] = ldshared
have_library("onig")
$CFLAGS='-Wall'
create_makefile( "oregexp" )
```

With this, I was able to build the gem, install it locally, and still
have it work with passenger.  I can't guarantee it's the best way to
do it, but it works.

I've put the modified Oniguruma gem on [GitHub][github-gem].

Until GitHub gets the gem building back up and running, you'll have to
download, and make the `.gem` file yourself, unfortunately.

``` bash Clone and build
git clone git://github.com/jhelwig/oniguruma
cd oniguruma
rake build
gem install pkg/oniguruma-$(rake version | sed -e '/oniguruma/d' -e 's/Current version: //').gem -- --with-onig-dir $HOME
```

[extconf-patch]: http://rubyforge.org/tracker/index.php?func=detail&aid=16169&group_id=3289&atid=12696 "extconf.rb patch"
[github-gem]: https://github.com/jhelwig/oniguruma/ "modified Oniguruma gem"
[jeweler]: https://github.com/technicalpickles/jeweler "Jeweler GitHub project"
[oniguruma-gem]: http://oniguruma.rubyforge.org/ "Oniguruma RubyForge project"
[oniguruma-library]: http://www.geocities.jp/kosako3/oniguruma/ "Oniguruma homepage"
