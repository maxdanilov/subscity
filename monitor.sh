#!/bin/sh

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
PIDFILE=$(realpath "${SCRIPTPATH}/tmp/pids/server.pid")
RESTART="cd $SCRIPTPATH && ./restart.sh"

restart()
{
	echo "Restarting with ${RESTART}..."
	eval $RESTART
}

check()
{
	if [ -z $PIDFILE ]; then
		echo "PIDFILE not found"
		restart
	else
		PID=$(cat $PIDFILE)
		if [ -z $PID ]; then
			echo "empty PID"
			restart
		else
			if ps -p $PID > /dev/null ; then
   				echo "$PID is running"
			else
				echo "$PID is not running"
				restart
			fi
		fi
	fi
}

check
