#!/bin/bash
cd /flosight

# Use Env variables in Config
## Change Network Config if needed
echo "Setup configs..."
if [ "$NETWORK" == "testnet" ]
then
	sed -i 's/livenet/testnet/g' flocore-node.json
fi
if [ "$NETWORK" == "regtest" ]
then
  sed -i 's/livenet/regtest/g' flocore-node.json
fi
## Add Seednode config for fcoin if needed
if ! [ -z "$ADDNODE" ]
then
	echo nodes="$ADDNODE" > /data/fcoin.conf
fi
## Add any custom config values
if [ ! -z "$CUSTOM_FCOIN_CONFIG" ]
then
	echo -e "${CUSTOM_FCOIN_CONFIG}" >> /data/fcoin.conf
fi

## Download the Blockchain Bootstrap if set
if [ ! -z "$BLOCKCHAIN_BOOTSTRAP" ] && [ "$(cat /data/bootstrap-url.txt)" != "$BLOCKCHAIN_BOOTSTRAP" ]
then
  # download and extract a Blockchain boostrap
  echo 'Downloading Blockchain Bootstrap...'
  RUNTIME="$(date +%s)"
  curl -L $BLOCKCHAIN_BOOTSTRAP -o /data/bootstrap.tar.gz --progress-bar | tee /dev/null
  RUNTIME="$(($(date +%s)-RUNTIME))"
  echo "Blockchain Bootstrap Download Complete (took ${RUNTIME} seconds)"
  echo 'Extracting Bootstrap...'
  RUNTIME="$(date +%s)"
  tar -xzf /data/bootstrap.tar.gz -C /data
  RUNTIME="$(($(date +%s)-RUNTIME))"
  echo "Blockchain Bootstrap Extraction Complete! (took ${RUNTIME} seconds)"
  rm -f /data/bootstrap.tar.gz
  echo 'Erased Blockchain Bootstrap `.tar.gz` file'
  echo "$BLOCKCHAIN_BOOTSTRAP" > /data/bootstrap-url.txt
  ls /data
fi

# Currently fcoin requires us to create these directories
echo "Pregenerate fcoin directories"
mkdir /data/blocks
mkdir /data/testnet
mkdir /data/testnet/blocks
mkdir /data/regtest
mkdir /data/regtest/blocks

# Nginx http config
mkdir -p /data/nginx/
cp /nginx/http-proxy.conf /data/nginx/http-proxy.conf

echo "Config setup complete!"

# Startup Nginx (since docker has it stopped at startup)
echo "Starting Nginx..."
service nginx start
echo "Nginx Started."

# Initial Startup of Flosight
echo "Starting FLO Explorer $NETWORK"
./node_modules/flocore-node/bin/flocore-node start > /data/latest.log &
# Store PID for later
echo $! > flosight.pid

# Every 5 minutes
while true; do
	
	# Wait 5 minutes before checking again
	timeout 5m tail -f /data/latest.log

	# Check the health of the node and restart if needed
	if [ "$(cat healthcheck.status)" == "UNHEALTHY" ] && [ "$(cat healthcheck.ready)" == "1" ]; then
		# Restart instance
		echo "$(date): UNHEALTHY - RESTARTING PROCESS" >> /data/latest.log
		kill -2 $(cat flosight.pid)
		wait $(cat flosight.pid)
		./node_modules/flocore-node/bin/flocore-node start >> /data/latest.log &
		# Store PID for later
		echo $! > flosight.pid
	fi

done;