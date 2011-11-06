--- 
kind: article
title: Helper script for creating posts with WWW::StaticBlog
tags: [www-staticblog, yak shaving]
created_at: 2010-04-10T13:40:42-07:00
updated_at: 2010-04-10T13:43:28-07:00
---

There's always another yak that needs shaving.  Since creating posts with
[WWW::StaticBlog](https://github.com/jhelwig/WWW-StaticBlog "WWW::StaticBlog")
wasn't fast enough for my tastes, I made a small script to make it even
faster!

Before, I would create the directory hirarchy, if I haven't yet made a
post this month, coming up with a file name that has some relavence to
the post contents, but is still sane for a file name, and opening it up
in the editor, creating the `Title:`, and `Author:` "headers", and
finally getting down to writing the silly post.

<pre><code class="language-bash">
#!/bin/bash

post_date="$(date +%Y/%m)"

title="$*"

if [ "$title" == "" ];
then
    read -e -p 'Post title: ' title
fi

filename="$(echo -n "$title" | tr -c '[:alnum:]' '_')"

mkdir -p articles/$post_date

new_post="articles/$post_date/$filename"

echo "Title: $title"                    > $new_post
echo "Author: $(git config user.name)" >> $new_post
echo                                   >> $new_post
echo                                   >> $new_post

git add $new_post

vim -c 'set tw=72' '+/^$/+' -c 'nohl' $new_post
</code></pre>

By saving this as `~/bin/git-new-post`, I automatically get a new Git command.
Now, I can just type `git new-post` from my site's repository, and I'll be
prompted for the post's title (with readline support), and the directories will
be created for me, the title will be sanitized into a reasonable file name, the
empty post with just the headers will be added to Git, and the file will be
opened up in vim, with the cursor at the end, ready for me to just start
writing.

Optionally, I can provide the title to new-post with `git new-post Some title`,
and it won't bother prompting me.
