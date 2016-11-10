#!/bin/bash

/opt/mysql-proxy/bin/mysql-proxy \
--keepalive \
--log-level=debug \
--plugins=proxy \
--proxy-address=0.0.0.0:${PROXY_DB_PORT} \
--proxy-backend-addresses=${REMOTE_DB_HOST}:${REMOTE_DB_PORT}
