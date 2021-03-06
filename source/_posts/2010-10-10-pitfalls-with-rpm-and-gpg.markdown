--- 
layout: post
title: Pitfalls with RPM and GPG
date: 2010-10-10T00:16:50-07:00
comments: true
categories: [GPG, RPM, packaging]
updated: 2011-04-07T09:28:37-07:00
---

As part of automating the packaging process for
[Puppet Dashboard](http://www.puppetlabs.com/puppet/related-projects/dashboard/ "Puppet Dashboard")
we ran into some baffling issues regarding the package signatures.
Initially, we ended up with a package that was recognized as having a
valid signature on some systems, but not others (Good with RPM 4.7.2,
bad with 4.4.2.3).  Additionally, when we tried signing the package with
our "normal" GPG keys to try and debug this, we were unable to get a
good signature from _any_ of the systems we were testing with.

After much cursing, and Googling, we were able to find the correct
incantation to get past the gauntlet of bizarre RPM behavior.

<!--more-->

In order to reliably build/sign an RPM, you must:

* Have a signing-only RSA key.
* Your key cannot have any sub-keys.
* Your key must be > 1024-bit.
* You must generate the RPM with a V3 GPG signature (CentOS 5.5 can't verify V4 signatures).

To top it all off (and this might just be my Google-fu failing me, and not
knowing where to look) _none_ of this is actually documented anywhere outside
of bugs.

The first three conditions are rather annoying, but not that hard to meet.  The
last one is a bit trickier.  We were able to find a self-contained work-around
for `rpm` failing to verify V4 GPG signatures in older versions by picking
apart one of the
[bugs filed against rpm](https://bugzilla.redhat.com/show_bug.cgi?id=436812 "RPM Bug").
If you add the following to your `~/.rpmmacros` file, replacing `omg@kitte.ns`
with your key ID (provided your key meets the other three conditions above), then
you should be all set.

``` bash ~/.rpmmacros
%_signature gpg
%_gpg_name  omg@kitte.ns
%__gpg_sign_cmd %{__gpg} \
    gpg --force-v3-sigs --digest-algo=sha1 --batch --no-verbose --no-armor \
    --passphrase-fd 3 --no-secmem-warning -u "%{_gpg_name}" \
    -sbo %{__signature_filename} %{__plaintext_filename}
```
