#!/bin/bash
# read from an input file, compose excutable.sh to trigger chain login
# by using expect.
#
# Usage: Create a text file, type in the ssh user name. password, host
# address like following
# user1|password1|host1
# user2|password2|host2
# ...
#
# example:
# root|passwd|192.168.1.15
# user|w@e%%$$|192.168.1.102
#
# Then save it, for example, as input.txt.
# Run ./sshchain.sh input.txt

input=$1
lnumber=0
line=''
linecount=0
executable='executable.sh'
user=''
passwd=''
host=''
eof='n'

function readline ()
{
	# auto skip empty line
	line=''
	while [[ $eof = 'n' && -z $line ]];do
		lnumber=$((lnumber + 1))
		line=`awk "NR == $lnumber" $input`
		if [ $lnumber -ge $linecount ];then
			eof='y'
		fi
	done
}

function initialize ()
{
	echo '#!/usr/bin/expect' > $executable
	echo 'set timeout 60'
	echo "" >> $executable
	chmod +x $executable
	echo "spawn ssh $1@$3 -o ServerAliveInterval=300" >> $executable
	echo 'expect "*?assword:"' >> $executable
	echo "send \"$(printf "%q" $2)\\r\"" >> $executable
	echo "" >> $executable

}

function composechain ()
{
	echo 'expect "*@*~]*?"' >> $executable
	echo "send \"ssh $1@$3 -o ServerAliveInterval=120\\r\"" \
		>> $executable
	echo 'expect "*?assword:"' >> $executable
	echo "send \"$(printf "%q" $2)\\r\"" >> $executable
	echo "" >> $executable

}

function lastline ()
{
	echo "interact" >> $executable
}

# main flow
# if no argument present
if [ -z $1 ];then
	echo "Usage: $0 <input file>"
	exit 0
fi

# save total line number of the file
# wc will print number and file name as one line, so we need to strip
# file name from that line, and transfer the number from string to integer.
echo "Counting input file lines..."
linecount=`wc -l $input`
linecount=${linecount%$input}
linecount=$((linecount))

# first ssh connection is unique, cannot be done in a loop.
echo "Read first host."
readline

if [ -z $line ];then
	echo "Cannot find even one valid line from file $input."
	exit 0
fi

# start composing excutable for first ssh connection
echo "Composing executable..."
initialize ${line//'|'/' '}
# compose other chain ssh connections
until [[ -z $line || $eof = 'y' ]];do
	readline
	composechain ${line//'|'/' '}
done
# finish up
lastline

# run it
echo "Run executable..."
expect -f $executable
