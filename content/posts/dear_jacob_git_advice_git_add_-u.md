--- 
kind: article
title: "\"Dear Jacob\" Git advice: git add -u"
tags: [git]
created_at: 2010-05-01T22:15:08-07:00
---

I recently received a request that I start a "Dear Jacob" advice column
for git, and thought that it was a pretty nifty idea.  I needed a good
excuse to post more frequently, and I do end up answering a lot of
questions about Git for the people that I know.

Welcome to the first installment of the "Dear Jacob" Git advice column!

The first tip comes about because of wanting to add all of the modified
files to the index, without adding any test, or experimental files that
might also be in your tree.

My first thought would be to try `git add -a`.  Unfortunately, that
doesn't work at all (even though `-a` is what you'd want if you were
doing [git commit][git-commit] in this case).  With [git add][git-add],
you actually want `-u`.

Anyway, the disjunction resulted in the person doing
`git diff --name-only | xargs git add` whenever they wanted to add only
the modified files in their repo.  They couldn't use `git add .` to add
_everything_, since they potentially had some test/experiment files that
they didn't want to track.

[git-add]: http://kernel.org/pub/software/scm/git/docs/git-add.html "git-add(1)"
[git-commit]: http://kernel.org/pub/software/scm/git/docs/git-commit.html "git-commit(1)"
