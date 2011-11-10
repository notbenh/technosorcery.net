--- 
kind: article
title: "Soft resolution of Request Tracker tickets."
tags: [extension, perl, rt]
created_at: 2007-09-06T05:51:00-04:00
---

We wanted to be able to close a ticket, without actually "closing" it.
Thus the "pending" ticket status was born.  We can set a ticket's
status as "pending", and have it automatically marked as "closed" _n_
days later, if there haven't been any replies in that time.

I have received permission from my employer to release this under the
[GNU GPLv2][gpl-license].

Now that the background info is done with, here's the solution I came
up with to be able to have a soft resolution of tickets.

First up: Add the status itself to the list of inactive statuses,
since supposedly the ticket is done with, or the requester just
doesn't care enough anymore to be bothered with replying to it.

Put the following in `etc/RT_SiteConfig.pm`:
<pre><code class="language-perl">
@InactiveStatus = qw(resolved rejected pending deleted) unless @InactiveStatus;
</code></pre>


You'll then need to create `local/lib/RT/Action/AutoResolve.pm`
(I'd love to give credit on where I found the code that this is based on, but
I can't seem to find it on the RT Wiki anymore.  If you can find the original,
let me know so I can give proper credit for this) with the following content:
<pre><code class="language-perl">
package RT::Action::AutoResolve;
require RT::Action::Generic;

use strict;
use vars qw/@ISA/;
@ISA=qw(RT::Action::Generic);

sub Describe  {
    my $self = shift;
    return (ref $self );
}

sub Prepare {
    my $self = shift;

    # if the ticket is already resolved don't re-resolve it.
    if ( ( $self->TicketObj->Status eq 'resolved' ) ) {
        return undef;
    } else {
        return (1);
    }
}

sub Commit {
    my $self = shift;
    $self->TicketObj->SetStatus( 'resolved' );

    return (1);
}

1;
</code></pre>
This will be used as the `--action` argument to `rt-crontool`.

Create `local/lib/RT/Condition/UntouchedInDays.pm` (Modified from
[UntouchedInHours][UntouchedInHours].)  for the `--condition` used
with `rt-crontool`:
<pre><code class="language-perl">
package RT::Condition::UntouchedInDays;
require RT::Condition::Generic;

use RT::Date;

@ISA = qw(RT::Condition::Generic);

use strict;
use vars qw/@ISA/;

sub IsApplicable {
        my $self = shift;
        if ((time()-$self->TicketObj->LastUpdatedObj->Unix)/3600/24 >= $self->Argument) {
                return 1
        }
        else {
                return 0;
        }
}

1;
</code></pre>

`local/lib/RT/Search/PendingTicketsInQueue.pm` will be used for the
`--search`.  I can't seem to find where I got this code from
originally.  If you recognize it, or are the original author, please
let me know.
<pre><code class="language-perl">
package RT::Search::PendingTicketsInQueue;

use strict;
use base qw(RT::Search::Generic);

sub Describe  {
  my $self = shift;
  return ($self->loc("No description for [_1]", ref $self));
}

sub Prepare  {
  my $self = shift;

  $self->TicketsObj->LimitQueue(VALUE => $self->Argument);

  $self->TicketsObj->LimitStatus(VALUE => 'pending');

  return(1);
}
1;
</code></pre>

Now that the pre-requisites are in place, we can create the
`rt-pending` script that should be called daily to resolve tickets
that have been set as pending for _n_ days (in this example: `n = 7`).
I just dropped this script into `/etc/cron.daily/`, but I'm using
Debian.  You should adjust as appropriate for your distribution.
<pre><code class="language-bash"
#! /bin/sh

/opt/rt3/bin/rt-crontool --search RT::Search::PendingTicketsInQueue --search-arg 'Help Desk' --condition RT::Condition::UntouchedInDays --condition-arg 7 --action RT::Action::AutoResolve
</code></pre>

That finishes up the portion to mark the tickets as resolved, after the given
number of days have passed, with no updates to a ticket.  Next up is re-opening
the ticket if someone replies to it.

Now we'll create the pre-requisites necessary to setup the queue, and global
scrips relating to pending tickets.
`local/lib/RT/Condition/ReplyToPending.pm`, heavily based on [ReplyToResolved.pm][ReplyToResolved.pm]:
<pre><code class="language-perl">
package RT::Condition::ReplyToPending;
use strict;
use base qw(RT::Condition::Generic);
sub IsApplicable {
   my $self = shift;
   my $ticket = $self->TicketObj;
   my $transaction = $self->TransactionObj;
   if ( $transaction->Type eq 'Correspond' &&
       $ticket->Status eq 'pending' &&
       $transaction->Creator != 1 )  { # prevent loop
       return(1);
   }
   else {
       return(undef);
   }
}
1;
</code></pre>

You can use the following template (also taken from
[ReplyToResolved][ReplyToResolved.pm] on the [RT Wiki][RT Wiki]) to
make the conditions, and actions described here available through the
web scrip interface:
<pre><code class="language-perl">
#!/usr/bin/perl
use strict;
use Unicode::String qw(utf8 latin1);
# Replace this with your RT_LIB_PATH
use lib "/opt/rt3/lib";
# Replace this with your RT_ETC_PATH
use lib "/opt/rt3/etc";
use RT;
use RT::Interface::CLI qw( CleanEnv GetCurrentUser );
use RT::ScripCondition;
CleanEnv();
RT::LoadConfig();
RT::Init();
##Drop setgid permissions
RT::DropSetGIDPermissions();
##Get the current user all loaded
our $CurrentUser = GetCurrentUser();
unless( $CurrentUser->Id ) {
    print "No RT user found. Please consult your RT administrator.\n";
    exit 1;
}
my $sc = new RT::ScripCondition($CurrentUser);

$sc->Create(
           Name                 => 'On Reply to Pending',
           Description          => "Reply to a ticket marked as pending.",
           ExecModule           => 'ReplyToPendingTicket',
           ApplicableTransTypes => 'Any'
           );
</code></pre>

Now that these steps are done, you can create a global scrip with the
condition set to `On Reply to Pending`, and the action set to `Open
Ticket`.  This will re-open any tickets as soon as someone replies to
them, but not if anyone comments on them.  (Commenting will, however
delay the resolution of a ticket.)

You'll then need to create either a global scrip, or a queue specific
scrip for each queue where you want people to be able to reply to a
pending ticket, and have it re-opened. (Personally I recommend the
global scrip method.)

This step requires direct DB access.  You'll need to be able to do an insert on
the `ScripConditions` table. <%= escape_code('<user_id>') %> should be
replaced with a valid user ID, taken from one of the other entries in the
`ScripConditions` table.

<%= highlight('sql', <<-HERE)
INSERT INTO ScripConditions(
  Name,
  Description,
  ExecModule,
  Argument,
  ApplicableTransTypes,
  Creator,
  Created,
  LastUpdatedBy,
  LastUpdated
) VALUES (
  'On Pending',
  'Whenever a ticket is marked as pending resolution',
  'StatusChange',
  'pending',
  'Status',
  <user_id>,
  NOW(),
  <user_id>,
  NOW()
);
HERE
%>

This sets up the "On Pending" scrip condition, so that you'll be able
to create a scrip such as "On Pending Reply to Requesters with
template XXXXXX", and have a custom message sent out to inform the
requester that the ticket will close itself in _n_ days, unless they
reply to it.

[RT Wiki]: http://wiki.bestpractical.com/ "RT Wiki"
[ReplyToResolved.pm]: http://wiki.bestpractical.com/view/ReplyToResolved "ReplyToResolved on RT Wiki"
[UntouchedInHours]: http://wiki.bestpractical.com/view/UntouchedInHours "UntouchedInHours on RT Wiki"
[gpl-license]: http://www.gnu.org/copyleft/gpl.html "GNU GPLv2"
