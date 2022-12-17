#!/bin/bash

mongo <<EOF
use test
config={"_id":"sz","members":[{"_id":0,"host":"mongo1.prv:51903","priority": 1},{"_id":1,"host":"mongo2.prv:51903","priority": 0.5},{"_id":2,"host":"mongo3.prv:51903","priority": 0.5}]}
rs.initiate(config)
EOF
