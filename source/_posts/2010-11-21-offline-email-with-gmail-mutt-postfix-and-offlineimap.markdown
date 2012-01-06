--- 
layout: post
title: Offline email with gmail, mutt, postfix and offlineimap
date: 2010-11-21T23:43:25-08:00
comments: true
updated: 2010-11-21T23:43:25-08:00
---

One of my co-workers recently asked me to send him my setup for being
able to read & write email while fully disconnected from the internet
using mutt.

<!--more-->

The portion of my setup for "sending" email while offline comes almost
verbatim from [a post on The Grand Fallacy](http://paul.frields.org/?p=2616 "Best in show.")
and [the follow-up update](http://paul.frields.org/?p=2636 "Best in show gets better.").

### Sending offline

Install Postfix (Be sure to select "internet site" on Debian based
systems).

Add the following to `/etc/postfix/main.cf`:

``` ini /etc/postfix/main.cf
smtp_sender_dependent_authentication = yes
sender_dependent_relayhost_maps = hash:/etc/postfix/sender_relay
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_policy_maps = hash:/etc/postfix/tls_policy
smtp_use_tls = yes
smtp_tls_note_starttls_offer = yes
smtp_tls_CApath = /etc/pki/tls/certs
```

Create `/etc/postfix/sender_relay` mapping sender addresses to SMTP
servers:

``` raw /etc/postfix/sender_relay
# per-sender provider; see also /etc/postfix/sasl_passwd
your_gmail_address@gmail.com [smtp.gmail.com]:587
another@address.example.com  [smtp.gmail.com]:587
```

Create `/etc/postfix/sasl_passwd` to store the authentication
information for each server that requires it:

``` raw /etc/postfix/sasl_passwd
your_gmail_address@gmail.com username:password
another@address.example.com  username2:password2
```

Create `/etc/postfix/tls_policy` to let Postfix know how to pass the
authentication information to each server:

``` raw /etc/postfix/tls_policy
smtp.gmail.com:587 encrypt
```

Create the lookup tables that Postfix uses:
``` bash Generate hashes of config files
sudo postmap /etc/postfix/sender_relay
sudo postmap /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/tls_policy
```

Create `/etc/NetworkManager/dispatcher.d/99offline-postfix` to handle
automatically defer attempts to deliver mail when there isn't an
available network connection, and resume delivery attempts when an
internet connection becomes available again:

``` bash /etc/NetworkManager/dispatcher.d/99offline-postfix (Ubuntu)
#!/bin/sh

if [ "$2" == "down" ]; then
    ( [ -z "`ip route show 0.0.0.0/0`" ] && \
    /usr/sbin/postconf -e 'defer_transports = smtp' && \
    /sbin/service postfix reload ) || :
elif [ "$2" == "up" ]; then
    ( /usr/sbin/postconf -e 'defer_transports =' && \
    /sbin/service postfix reload && \
    /sbin/service postfix flush ) || :
fi
```


One thing that The Grand Fallacy didn't mention was that there is some
setup required in Mutt to get this to work.  You'll need to make sure
that you have Mutt setup to pass along the from address used in the
composed email.

Put the following in your `.muttrc`:
``` bash
set envelope_from=yes
```

### Reading offline

Now that you can send email while offline, it'd probably be handy to be
able to be able to read email while offline, too.  I use offlineimap for
this, and setup Mutt to read the local maildirs that it sets up.

The `~/.offlineimaprc` file:

``` ini ~/.offlineimaprc
[general]
ui = Noninteractive.Basic
accounts = GMail, OtherGMail
maxsyncaccounts = 5
maxconnections = 3

[mbnames]
enabled = yes
filename = ~/.mutt/muttrc.mailboxes
header = "mailboxes "
peritem = ="%(foldername)s"
sep = " "
footer = "\n"

[Account GMail]
localrepository = GMailLocal
remoterepository = GMailRemote
autorefresh = 2

[Repository GMailLocal]
type = Maildir
localfolders = ~/IMAP/GMail

[Repository GMailRemote]
type = Gmail
realdelete = no
remoteuser = name@gmail.com
remotepass = password1
holdconnectionopen = true
keepalive = 60
timeout = 120

[Account OtherGMail]
localrepository = OtherGmailLocal
remoterepository = OtherGmailRemote
autorefresh = 2

[Repository OtherGmailLocal]
type = Maildir
localfolders = ~/IMAP/OtherGmail

[Repository OtherGmailRemote]
type = Gmail
realdelete = no
remoteuser = other@gmail.com
remotepass = password2
holdconnectionopen = true
keepalive = 60
timeout = 120
```

I like having a (relatively) clear separation between my work, and
personal email, so I have my `.muttrc` split out into three files:
`.muttrc_common`, `.muttrc`, and `.muppetrc`.  The `.muppetrc` makes a
bit more sense knowing that I currently work at [Puppet Labs](http://puppetlabs.com "Puppet Labs")
(Mutt + Puppet = Muppet).  I call `mutt` from the command line
normally, when I want my personal email, and I use a `muppet` alias
(`mutt -F ~/.muppetrc`) to use my work email.

In the `.muttrc_common` I have a bunch of things that are common to both
my work, and personal email:

{% include_code ~/.muttrc_common lang:bash 2010-11-21-offline-email-with-gmail-mutt-postfix-and-offlineimap/muttrc_common %}

This sets up some really nice things like colorized diffs in email
(really handy for reading the puppet-dev, and git mailing lists), an
X-PGP-Key header with a link to my GPG public key, and going straight to
the editor when I want to compose an email, instead of prompting me for
a subject, and recipients (I can change these headers directly in the
editor, anyway).  Sourcing `~/.mutt/muttrc.mailboxes` gives me new mail
notifications for all of the tags I have setup through GMail, since they
each show up as their own folder.

In my `.muttrc`, I have:

``` bash ~/.muttrc
source ~/.muttrc_common

# GMail Setup
set folder=$HOME/IMAP/GMail

alternates "^(jacob|jhelwig)@(technosorcery.net|perlninja.com)"
set from = "jacob@technosorcery.net"
# END GMail Setup
```

In my `.muppetrc`, I have:

``` bash ~/.muppetrc
source ~/.muttrc_common

# Puppet Setup
set folder=$HOME/IMAP/Puppet

alternates "^jacob@(puppetlabs.com|reductivelabs.com)"
set from = "jacob@puppetlabs.com"
save-hook .* ~/work/review # default mbox to (s)ave mail
# END Puppet Setup
```

There really isn't much that's specific to each.
