#!/bin/bash
cd `dirname $0`

CURR_DIR=$(cd `dirname $0`;pwd)
APP_HOME=$(cd `dirname $0`;cd ..;pwd)
SERVICE_NAME=${APP_HOME##*/}
BIN_DIR=$APP_HOME/bin
CONF_DIR=$APP_HOME/conf
LOG_DIR=/opt/logs/$SERVICE_NAME
JAR_NAME=`ls $APP_HOME|grep .jar|awk '{print "'$APP_HOME'/"$0}'`

PIDS=`ps -ef | grep java | grep -w "$SERVICE_NAME" | grep -v "grep" | awk '{print $2}'`
if [ -z "$PIDS" ]; then
    echo "ERROR: The $SERVICE_NAME does not started!"
    exit 1
fi

echo -e "Stopping the $SERVICE_NAME ...\c"
for PID in $PIDS ; do
    kill $PID > /dev/null 2>&1
done

COUNT=0
while [ $COUNT -lt 1 ]; do    
    echo -e ".\c"
    sleep 1
    COUNT=1
    for PID in $PIDS ; do
        PID_EXIST=`ps -f -p $PID | grep java |awk '{print $2}'`
        if [ -n "$PID_EXIST" ]; then
            COUNT=1
            kill -9 $PID
            break
          else
            COUNT=1
            break
        fi
    done
done

echo "OK!"
echo "PID: $PIDS"
