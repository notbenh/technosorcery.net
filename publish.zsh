#!/bin/zsh

typeset -A opts
zparseopts -D -A opts -- -debug -dry-run -publish

debug=''
if (( ${+opts[--debug]} )); then
    debug='--debug'
fi

www-staticblog --configfile www-staticblog.yaml $debug || exit 1

find build -type d -exec chmod a+rx {} \;
find build -type f -exec chmod a+r  {} \;

if (( ${+opts[--publish]} )); then
    dry_run=''
    if (( ${+opts[--dry-run]} )); then dry_run='--dry-run'; fi
    rsync $dry_run -vrlptSPhi --copy-unsafe-links --delete-after --delay-updates --stats build/. technosorcery.net:technosorcery.net/
fi
