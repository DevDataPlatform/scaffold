#!/bin/sh

ssh -i ../secrets/monitoring.pem -L 3001:localhost:3000 -L 9090:localhost:9090 ubuntu@13.232.234.233

