#!/bin/bash
#INSTALL@ /usr/local/bin/a-notate

my_editor=${EDITOR:-vim}
tmpfile=$(mktemp)

if [ ! -d "$HOME/.a-notations" ] ; then
	mkdir -p "$HOME/.a-notations"
fi

if [ ! -f "$HOME/.a-notations/overview" ] ; then
	touch "$HOME/.a-notations/overview"
fi


# Possibilities:
# - There file and md5 are available and correct
# - file is available, but md5 is not correct
# - md5 is available, but filename is not the same
# - all is new.

if [ -z $1 ] ; then
	echo "yes, but wich file should I annotate?"
	exit
else
	file2do=$1
fi


checksum=$(md5sum -b "$file2do" | sed 's/ .*//')

if grep -q "$checksum:$file2do" ~/.a-notations/overview ; then
	both=true
else
	both=false
fi
if grep -q "$checksum:" ~/.a-notations/overview ; then
	cks=true
else
	cks=false
fi
if grep -q ":$file2do" ~/.a-notations/overview ; then
	fle=true
else
	fle=false
fi

if $both ; then
	$my_editor ~/.a-notations/$checksum
else
	if $cks  ; then
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
		if $fle ; then
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


