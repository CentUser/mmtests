#!/bin/bash

if [ ! -e /sys/kernel/debug/tracing/ ]; then
	mount -t debugfs none /sys/kernel/debug 2>&1 || exit -1
fi

for EVENT in $MONITOR_FTRACE_EVENTS; do
	SUBSYSTEM=`echo $EVENT | awk -F / '{print $1}'`
	if [ "$SUBSYSTEM" = "probe_func_return" ]; then
		EVENT=`echo $EVENT | awk -F / '{print $2}'`
		perf probe "$EVENT%return"
		EVENT="probe/$EVENT"
	fi
	echo 1 > /sys/kernel/debug/tracing/events/$EVENT/enable 2>&1 || exit -1
done

exec cat /sys/kernel/debug/tracing/trace_pipe
