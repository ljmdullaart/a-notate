#!/bin/bash
#INSTALL@ /usr/local/bin/a-notate

if [ "$EDITOR" = "" ] ; then
	my_editor=/usr/bin/vim
else
	my_editor="$EDITOR"
fi

tmpfile=/tmp/anotate.$$.$RANDOM


if [ ! -d ~/.a-notations ] ; then
	mkdir ~/.a-notations
fi

if [ ! -f ~/.a-notations/overview ] ; then
	touch ~/.a-notations/overview
fi


# Possibilities:
# - There file and md5 are available and correct
# - file is available, but md5 is not correct
# - md5 is available, but filename is not the same
# - all is new.

file2do=$1
if [ "$file2do" = "" ] ; then
	echo "yes, but wich file should I annotate?"
	exit
fi


checksum=$(md5sum -b "$file2do" | sed 's/ .*//')

if grep "$checksum:$file2do" ~/.a-notations/overview > /dev/null ; then
	both=ok
else
	both=nok
fi
if grep "$checksum:" ~/.a-notations/overview > /dev/null ; then
	cks=ok
else
	cks=nok
fi
if grep ":$file2do" ~/.a-notations/overview > /dev/null ; then
	fle=ok
else
	fle=nok
fi

if [ $both = ok ] ; then
	$my_editor ~/.a-notations/$checksum
else
	if [ $cks = ok ] ; then
		oldfile=$(grep "$checksum:" ~/.a-notations/overview | sed 's/[^:]*://')
		echo "Hmmm.. this looks like $oldfile"
		echo "Did you move or copy that file?"
		echo "enter to edit the original notes, control-c to abort"
		read line
		grep -v "$oldfile" ~/.a-notations/overview > $tmpfile
		mv $tmpfile ~/.a-notations/overview
		echo "$checksum:$file2do">>~/.a-notations/overview
		$my_editor ~/.a-notations/$checksum
	else
		if [ $fle = ok ] ; then
			echo "Hmmm.. Seems like the file $file2do has changed"
			oldcksum=$(grep ":$file2do" ~/.a-notations/overview | sed 's/:.*//')
			cp ~/.a-notations/$oldcksum ~/.a-notations/$checksum
			echo "Copied $oldcksum to $checksum"
			grep -v "$oldcksum" ~/.a-notations/overview > $tmpfile
			mv $tmpfile ~/.a-notations/overview
			echo "$checksum:$file2do">>~/.a-notations/overview
			$my_editor ~/.a-notations/$checksum
		else
			echo "New file $file2do ($checksum)"
			echo "$checksum:$file2do">>~/.a-notations/overview
			$my_editor ~/.a-notations/$checksum
		fi
	fi
fi


