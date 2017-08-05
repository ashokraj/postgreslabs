#!/bin/bash 


[ -p /tmp/input ] || mkfifo /tmp/input
psql "application_name=pgbench" -f /tmp/input >/dev/null 2>&1  & 
sqlpid=$!

sleep 2
kill -0 $sqlpid || exit 2

i=0
while true ; do 
   if [ $i -eq 0 ] ; then 
      echo "BEGIN;"
      i=1
   fi
   echo "UPDATE pgbench_accounts SET abalance = abalance + 682 WHERE aid = 78573;" 
   sleep 5 
   echo "SELECT abalance FROM pgbench_accounts WHERE aid = 1163788;"
   sleep 5
done > /tmp/input & 

sleep 5
psql "application_name=pgbench" <<EOF >/dev/null 2>&1  & 
ALTER TABLE pgbench_accounts ADD IF NOT EXISTS name name;  
ALTER TABLE pgbench_accounts DROP IF EXISTS name; 
EOF

sleep 5
pgbench -t 100 -j 10 -c 10 >/dev/null 2>&1 &  
