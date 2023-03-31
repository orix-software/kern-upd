#! /bin/bash
HOMEDIR=build/
HOMEDIRDOC=docs/
mkdir  -p build/usr/share/man
mkdir -p ../build/usr/share/man/

PATH_MD2HLP=../md2hlp/src/md2hlp.py3

# if command -v md2hlp.py3 &> /dev/null
# then
# PATH_MD2HLP=md2hlp.py3
# fi

LIST_COMMAND='bankupd orixcfg'
echo Generate hlp
for I in $LIST_COMMAND; do
echo Generate $I
cat $HOMEDIRDOC/$I.md | $PATH_MD2HLP -c $HOMEDIRDOC/md2hlp.cfg > build/usr/share/man/$I.hlp
done
