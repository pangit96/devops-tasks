#!/bin/bash

count=`ps aux | grep sz | wc -l`
if [ $count -eq 2 ]
    then
bash /replsetup.sh
    
fi


sleep 20 
mongo <<EOF
use admin

db.createUser({user : 'mongoadmin', pwd : '$adminpass', roles : ['root']})
EOF

mongo -umongoadmin -p"$adminpass" <<EOF
use admin
db.createUser({user : 'global-onboarding', pwd : '$userpass', roles : [{role: 'readWrite', db: "global-onboarding"}]})
db.createUser({user : 'rmProduct', pwd : '$userpass', roles : [{role: 'readWrite', db: "rmProduct"}]})
db.createUser({user : 'apiBlender', pwd : '$userpass', roles : [{role: 'readWrite', db: "apiBlender"}]})
db.createUser({user : 'persist', pwd : '$userpass', roles : [{role: 'readWrite', db: "persist"}]})
db.createUser({user : 'VideoConf', pwd : '$userpass', roles : [{role: 'readWrite', db: "VideoConf"}]})
db.createUser({user : 'vcip', pwd : '$userpass', roles : [{role: 'readWrite', db: "vcip"}]})

EOF
