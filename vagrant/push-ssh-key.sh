#!/usr/bin/expect -f
spawn ssh-copy-id $argv
expect "Are you sure you want to continue connecting (yes/no)?"
send "yes\n"
expect "password:"
send "vagrant\n"
expect eof