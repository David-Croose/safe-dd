#!/bin/bash

CONFIG_MAX_BLK_SIZE=8*1024*1024*1024

[ "$1" ] || {
	echo "usage: $0 </dev/blkdev> <FILE>"
	exit 0
}

BLKDEV=$1
FILE=$2

ls $BLKDEV 2>/dev/null 1>/dev/null || {
	echo "error: $BLKDEV is absent"
	exit 1
}
ls $FILE 2>/dev/null 1>/dev/null || {
	echo "error: $FILE is absent"
	exit 1
}

BLKSIZE=$(lsblk $BLKDEV -bl | sed -n 2p | awk '{print $4}')
[ "$BLKSIZE" -gt 0 ] || {
	echo "error: get size of $BLKDEV error"
	exit 2
}

[[ $BLKSIZE -gt $CONFIG_MAX_BLK_SIZE ]] && {
	echo "warning: $BLKDEV size $BLKSIZE is greater then $CONFIG_MAX_BLK_SIZE!!! input CTRL+C to exit if you don't wanna go on"
	read
}

echo "======================================================="
echo "that't what you want?(N/y)"
lsblk $BLKDEV -l
echo "======================================================="

read INPUT
case $INPUT in
'N'|'')	echo "exit without any flash"
	exit 0
	;;

'y')	echo "now flash $BLKDEV..."
	dd if=$FILE of=$BLKDEV
	;;
esac

echo "error: input error"
exit 1
