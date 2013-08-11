sshLoginScript
==============

script that takes an input file and performs multiple login actions as defined in input file.
This script generates an expect script and run it. So make usre expect is installed.

Input File
==========

An input file exmaple: input.txt
user1|password1|192.168.1.123
user2|password2|192.168.2.123
user3|password3|192.168.3.123

Use Script
==========

./sshchain.sh input.txt

The sciprt will first login to 192.168.1.123 using user1 as user name and password1 as password.
Then when logged in, perform ssh connection to 192.168.2.123. And then 192.168.3.123.
So we will have a connection from 1.123 to 3.123 through 2.123.
This will be useful for connecting to a machine in private network via a gateway.

Notice
======

It's obviously not secure to save user names and passwords in a plain text file.
