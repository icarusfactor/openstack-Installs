#!/bin/bash

# This will setup sflow monitors that logstash can track.
#This only needs to be ran one time and should be persitant. 

#If I need to remove the bridge
#Get UUID of sflow
# $ ovs-vsctl list sflow
# $ ovs-vsctl remove bridge $BRIDGENAME sflow <sFlow UUID>
# $ ovs-vsctl clear Bridge br-ex sflow
#Troubleshoot sflow
# $ tcpdump -ni $AGENT_IP udp port 6343

export COLLECTOR_IP=192.168.1
export COLLECTOR_PORT=6343
export AGENT_IP=enp0s3
export HEADER_BYTES=128
export SAMPLING_N=64
export POLLING_SECS=10
export BRIDGENAME1=br-ex
export BRIDGENAME2=br-int


ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
	    target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" header=${HEADER_BYTES} \
	        sampling=${SAMPLING_N} polling=${POLLING_SECS} \
		      -- set bridge $BRIDGENAME1 sflow=@sflow


ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
	    target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" header=${HEADER_BYTES} \
	        sampling=${SAMPLING_N} polling=${POLLING_SECS} \
		      -- set bridge $BRIDGENAME2 sflow=@sflow
