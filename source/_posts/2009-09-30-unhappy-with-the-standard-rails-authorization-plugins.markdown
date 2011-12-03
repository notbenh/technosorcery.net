--- 
layout: post
title: "Unhappy with the standard Rails Authorization plugins"
date: 2009-09-30T14:37:00-07:00
comments: true
categories: [authorization, ruby, ruby on rails]
---

Recently, I've decided to start learning Ruby on Rails (2.3.4).  Things have
been going along more-or-less smoothly (I'm still not sure whether or not I
hate ActiveRecord, or can tolerate it, but that's a post for another time.).
That is, until I started looking into the various plugins/frameworks for doing
Authorization in Rails.

<!--more-->

After searching around for a bit, the two main contenders I found were
[rails-authorization-plugin][rails-authorization-plugin], and
[acl9][acl9]. acl9 seemed to be, by far, the more commonly recommended
of the two.

I wasn't really impressed with the Apache style allow/deny used by acl9.  Just
wasn't what I was looking for with my project, so I started looking at
rails-authorization-plugin.  This is where I ran into trouble.

rails-authorization-plugin allows you to assign roles for objects, and
have an optional scope.
For example:

``` ruby Assign permissions
# Assign user the "global" role 'administrator'
user.has_role 'administrator'
# Assign user the role "moderator" for the class Group
user.has_role 'moderator', Group
# Assigns user the role "member" for the instance (of class Group)
user.has_role 'member', club
```

So far, so good.

Now, let's check what roles this user has:

``` ruby Check the permissions
user.has_role? 'administrator'        # => true
user.has_role? 'administrator', Group # => false
user.has_role? 'administrator', club  # => false

user.has_role? 'moderator'        # => true
user.has_role? 'moderator', Group # => true
user.has_role? 'moderator', club  # => false

user.has_role? 'member'        # => true
user.has_role? 'member', Group # => true
user.has_role? 'member', club  # => true
```

Wait?  What?  That's right: Inheritance of roles flows from instance, to class,
to global.  If you have a role for any instance, you also have it globally.
This is <strong>completely backwards</strong> from what I would have expected,
and from what I wanted.

Ok, time to go back to looking at acl9.  Guess what?  It does the
*exact same thing*.  Given these findings, I did what
any developer, with access to Git would do.  I forked the code to make
it do what I want.  Thus
[my fork of rails-authorization-plugin][rap-fork] (and
[it's tests][rap-tests-fork]) was born.  I decided to base my changes
off of rails-authroization plugin, simply because I didn't like the
Apache style allow/deny syntax of acl9.

Now, given the initial role assignments above, we get the following:

``` ruby Check the permissions again
user.has_role? 'administrator'        # => true
user.has_role? 'administrator', Group # => true
user.has_role? 'administrator', club  # => true

user.has_role? 'moderator'        # => false
user.has_role? 'moderator', Group # => true
user.has_role? 'moderator', club  # => true

user.has_role? 'member'        # => false
user.has_role? 'member', Group # => false
user.has_role? 'member', club  # => true
```

Inheritance is handled as follows: Global -> Class -> Instance.  If a role is
assigned at a "higher" level (further left), then it applies at all levels
"lower" than it (further right).

While I was in there monkeying around, I decided that I didn't like strings as
role names.  They seemed a little more special to me than just plain old
strings.

Now we can use symbols as role names:

``` ruby Symbol role names
user.has_role :administrator
user.has_role? :administrator, Group
```

Things still didn't quite seem right though.  The whole role to scope mapping
seemed like it deserved to be emphasized a little more, and assigning multiple
roles at once was a little clunky.

Now we can use hashes for assignment, and lookup:

``` ruby Multiple role assignment and checking
user.has_role :administrator => nil,
  :moderator => Group,
  :member    => club

user.has_role? :administrator => Group, :moderator => club # => true
user.has_role? :administrator => nil, :moderator => nil    # => false
```

This actually demonstrates two things.  First using a scope of
`nil`, is the same as saying that the scope is global.  Secondly,
when doing `has_role?` with a hash, all role requirements must be
met for `has_role?` to be true.

[acl9]: https://github.com/be9/acl9 "acl9"
[rails-authorization-plugin]: https://github.com/DocSavage/rails-authorization-plugin "rails-authorization-plugin"
[rap-fork]: https://github.com/jhelwig/rails-authorization-plugin "My fork of rails-authorization-plugin"
[rap-tests-fork]: https://github.com/jhelwig/rails-authorization-plugin-test "My fork of rails-authorization-plugin's tests"
