#! /bin/bash
HOMEDIR=build/
HOMEDIRDOC=docs/
mkdir  -p build/usr/share/man
mkdir -p ../build/usr/share/man/
LIST_COMMAND='romupd orixcfg'
echo Generate hlp
for I in $LIST_COMMAND; do
echo Generate $I
cat $HOMEDIRDOC/$I.md | ../md2hlp/src/md2hlp.py3 -c $HOMEDIRDOC/md2hlp.cfg > build/usr/share/man/$I.hlp
done
