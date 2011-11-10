--- 
kind: article
title: "Git + Lighthouse"
tags: [git, hooks, lighthouse]
created_at: 2008-05-18T10:43:00-07:00
---

I've been playing around with [Git][git], [CIA.vc][cia.vc], and
[Lighthouse][lighthouse] on a project of mine that's recently been
resurrected.

There is a pretty good update hook for CIA.vc integration called
[ciabot.pl][ciabot.pl] that I've been using, without any complaints.
Unfortunately, I haven't been able to find anything to integrate Git
with Lighthouse that hasn't needed modification out of the box.  I
tried the (pre|post)-receive hooks provided at
[Obvious Code][obv-code], but it had a few issues.  It would use the
author/committer information of the first rev it saw, and use that for
every revision it handled.  Lighthouse couldn't understand the
"changed-at" time format it was using.  The hook also relied on
writing out a file with the last rev it saw, so it knew where to pick
up, which I didn't really like.

So, I decided to write my own in Perl.  The latest version is
available via [Git][git] on [GitHub][github-repo].
<pre><code class="language-bash">
git clone git://github.com/jhelwig/lighthouseapp-git-hook.git
</code></pre>
The script can either be called straight from an existing update hook,
or can be the update hook.  It will split out commits on its own given
the old and new SHA1.

<pre><code class="language-perl">
#!/usr/bin/perl -w

use strict;
binmode STDIN, ':utf8';

use LWP::UserAgent ();

use Date::Format          qw/ time2str /;
use HTTP::Request::Common qw/ POST     /;
use XML::Simple           qw/ XMLout   /;
use YAML                  qw/ Dump     /;

#################################################
# Configuration Options                         #
#################################################
my $git = '/home/jhelwig/bin/git';
my %tokens = (
    # Fallback token to use if one isn't found for an author.
    'default' => '',
    # Individual tokens for author/committer.
    # If author email can't be found, committer's email will be tried.
    'jacob@technosorcery.net' => undef,
    'Another Author' => undef,
);
my $lighthouseapp_account_url = 'http://account-name.lighthouseapp.com';
my $lighthouseapp_project_id = 0;

#################################################

shift @ARGV;
my $old_sha1 = shift @ARGV;
my $new_sha1 = shift @ARGV;

my $rev_list = `$git rev-list --pretty=format:"" $old_sha1..$new_sha1`;
$rev_list =~ s/^commit //gm;

my @revs = reverse(split("\n", $rev_list));

foreach my $rev (@revs) {
    chomp(my $author_name = `$git show --pretty=format:"%an" $rev | sed q`);
    chomp(my $author_email = `$git show --pretty=format:"%ae" $rev | sed q`);
    chomp(my $author_date = `$git show --pretty=format:"%aD" $rev | sed q`);
    chomp(my $committer_name = `$git show --pretty=format:"%cn" $rev | sed q`);
    chomp(my $committer_email = `$git show --pretty=format:"%ce" $rev | sed q`);
    chomp(my $committer_date = `$git show --pretty=format:"%cD" $rev | sed q`);
    chomp(my $changed_at = time2str("%Y-%m-%dT%TZ", `$git show --pretty=format:"%ct" $rev | sed q`, 'GMT'));
    chomp(my $commit_log = `$git log -n1 --pretty=medium $rev | sed '1,4d'`);

    my $body = <<"HERE";
$commit_log

Author:     $author_name <$author_email>
AuthorDate: $author_date
Commit:     $committer_name <$committer_email>
CommitDate: $committer_date
HERE

    chomp(my $commit_subject = `$git show --pretty=format:"%s" $rev | sed q`);
    my $changes_yaml = Dump([
        map { [ split(/\s+/, $_) ] } split("\n", `$git diff-tree -r --name-status $rev | sed '1d'`)
    ]);

    my $xml = XMLout({ 'changeset' => {
            'title'      => [ $commit_subject, ],
            'body'       => [ $body, ],
            'revision'   => [ $rev, ],
            'changes'    => {
                'type'    => 'yaml',
                'content' => $changes_yaml,
            },
            'changed-at' => {
                'type'    => 'datetime',
                'content' => $changed_at,
            },
        }},
        KeepRoot => 1,
    );

    my $lh_token = defined($tokens{$author_email})
        ? $tokens{$author_email}
        : defined($tokens{$committer_email})
            ? $tokens{$committer_email}
            : $tokens{'default'};

    my $ua = LWP::UserAgent->new();
    $ua->timeout(3);
    $ua->env_proxy();

    my $response = $ua->simple_request(POST(
        "$lighthouseapp_account_url/projects/$lighthouseapp_project_id/changesets.xml",
        'content-type' => 'application/xml',
        'X-LighthouseToken' => $lh_token,
        Content => $xml
    ));

    unless ($response->is_success()) {
        print $response->status_line() . "\n"
            . $response->content() . "\n\n";

    }
}
</code></pre>

[cia.vc]: http://cia.vc/ "CIA.vc"
[ciabot.pl]: http://git.kernel.org/?p=cogito%2Fcogito.git;a=blob;hb=HEAD;f=contrib%2Fciabot.pl "ciabot.pl from Cogito"
[git]: http://git.or.cz/ "Git - Fast Version Control System"
[github-repo]: https://github.com/jhelwig/lighthouseapp-git-hook "GitHub project"
[lighthouse]: http://lighthouseapp.com "Lighthouse"
[obv-code]: http://obvcode.blogspot.com/2007/10/using-git-with-lighthouse.html "Obviouse Code: Using Git with Lighthouse"
