#!/usr/bin/env bash

PATH=/var/distcc/x-tools7h/aarch64-unknown-linux-gnu/bin:/usr/bin 
/usr/bin/distccd --user nobody --allow-private --no-detach --daemon --log-stderr --listen 0.0.0.0 --port 3632 --stats-port 3633