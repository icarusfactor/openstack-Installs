#!/bin/bash

# This will setup an sflow monitor that logstash can track.
#This needs to be ran each system startup to enable.

#If I need to remove the bridge
#Get UUID of sflow
# $ ovs-vsctl list sflow
# $ ovs-vsctl remove bridge $BRIDGENAME sflow <sFlow UUID>
#Troubleshoot sflow
# $ tcpdump -ni $AGENT_IP udp port 6343

export COLLECTOR_IP=192.168.1
export COLLECTOR_PORT=6343
export AGENT_IP=enp0s3
export HEADER_BYTES=128
export SAMPLING_N=64
export POLLING_SECS=10
export BRIDGENAME=br-ex

ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
	    target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" header=${HEADER_BYTES} \
	        sampling=${SAMPLING_N} polling=${POLLING_SECS} \
		      -- set bridge $BRIDGENAME sflow=@sflow

