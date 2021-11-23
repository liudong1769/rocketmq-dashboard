#!/bin/bash
#shell version 1.0.0 2019-10-20
CURR_DIR=$(cd `dirname $0`;pwd)
APP_HOME=$(cd `dirname $0`;cd ..;pwd)
SERVICE_NAME=${APP_HOME##*/}
BIN_DIR=$APP_HOME/bin
CONF_DIR=$APP_HOME/conf
LOG_DIR=/opt/logs/$SERVICE_NAME
JAR_NAME=`ls $APP_HOME|grep .jar|awk '{print "'$APP_HOME'/"$0}'`

tail -f $LOG_DIR/application.log

#viewLog.sh