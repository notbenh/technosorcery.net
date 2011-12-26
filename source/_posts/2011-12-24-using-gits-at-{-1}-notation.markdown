---
layout: post
title: "Using Git's @{-1} notation"
date: 2011-12-26T03:54:08-0500
comments: true
categories: [git]
---

There are a number of features Git has had for some time that go
largely unnoticed by most people.  Being able to refer to branches
using the `@{-1}` notation (and its `-` alias) is one of the features
I use on a regular basis that most people seem unaware of, even though
they've been around since version 1.6.2.

<!--more-->

Being able to refer to the previously checked out branch using a
consistent notation is particularly handy if you tend to keep around a
number of topic branches with similar enough names to make tab
completion a bit of a hassle.  When working on the Puppet codebase,
for example, I will often have a number of branches of the form
`${ticket}/${integration_branch}/${ticket_number}-${description}`.
Tab completing one of these can be annoying at times (especially with
multiple tickets that are close together numerically and are intended
for the same integration branch).  Where `@{-1}` comes in handy is
when I go to merge the topic branch into the integration branch to
make sure it merges cleanly, and all the tests still pass.

``` console Using @{-1} to merge my topic branch
% git checkout fix-instrumentation-file-case
Switched to branch 'fix-instrumentation-file-case'
# Time passes...
% git checkout 2.7.x
Switched to branch '2.7.x'
% git merge --no-ff @{-1}
Merge made by the 'recursive' strategy.
 .../{Instrumentable.rb => instrumentable.rb}       |    0
 1 files changed, 0 insertions(+), 0 deletions(-)
 rename lib/puppet/util/instrumentation/{Instrumentable.rb => instrumentable.rb} (100%)
% git log -1
commit 8735fea6c116e608292fbe294a622b5c09aed773
Merge: d4c8094 b2411b6
Author: Jacob Helwig <jacob@puppetlabs.com>
Date:   Mon Dec 26 04:08:56 2011

    Merge branch 'fix-instrumentation-file-case' into 2.7.x

    * fix-instrumentation-file-case:
      Use all lower-case file name for
      Puppet::Util::Instrumentation::Instrumentable
```

After running the tests, getting back to the topic branch for any
further work is quite simple, using the `-` alias for `@{-1}`.  For
people used to using `cd -`, switching branches like this will
probably come quite naturally.

``` console Switch to previous branch using -
% git checkout -
Switched to branch 'fix-instrumentation-file-case'
```

In addition to referring to the previously checked out branch `@{-N}`
will refer to the Nth previously checked out branch (`@{-2}`, etc).
