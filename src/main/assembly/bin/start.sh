#!/bin/bash
echo "info 最后修改日期 2020年06月25日"
cd `dirname $0`

CURR_DIR=$(cd `dirname $0`;pwd)
APP_HOME=$(cd `dirname $0`;cd ..;pwd)
SERVICE_NAME=${APP_HOME##*/}
BIN_DIR=$APP_HOME/bin
CONF_DIR=$APP_HOME/conf
LIB_DIR=$CONF_DIR:$APP_HOME/lib/*
LOG_DIR=/opt/logs/$SERVICE_NAME
#JAR_NAME=`ls $APP_HOME|grep .jar|awk '{print "'$APP_HOME'/"$0}'`
MAIN_CLASS=org.apache.rocketmq.dashboard.App

if [ ! -n "$APP_HOME" ]; then
    echo "error 变量 APP_HOME 值为空！！！"
    exit 1
fi
if [ ! -n "$SERVICE_NAME" ]; then
    echo "error 变量 SERVICE_NAME 值为空！！！"
    exit 1
fi


echo "info APP_HOME=$APP_HOME"
echo "info SERVICE_NAME=$SERVICE_NAME"
echo "info BIN_DIR=$BIN_DIR"
echo "info CONF_DIR=$CONF_DIR"
echo "info LOG_DIR=$LOG_DIR"
echo "info MAIN_CLASS=$MAIN_CLASS"

P_ID=`ps -ef | grep java | grep -w "$SERVICE_NAME" | grep -v "grep" | awk '{print $2}'`
if [ "$P_ID" != "" ]; then
   echo ""
   echo ""
   echo "error!!  $SERVICE_NAME alreddy started! process pid is:$P_ID"
   echo ""
   echo ""
   exit 1
fi

#检查setenv.sh是否存在
ENV_FILE=$BIN_DIR/setenv.sh
echo "info ENV_FILE=$ENV_FILE"
if [ ! -f "$ENV_FILE" ]; then
    echo "error $ENV_FILE 文件不存在!!!"
    exit 1
fi

##执行setenv.sh并确认
. "$ENV_FILE"
EXCODE=$?
if [ ! "$EXCODE" == "0" ]; then
    echo "error $ENV_FILE 启动失败!!!"
    exit 1
fi


JAVA_OPTS="$JAVA_OPTS -Dapp.name=$SERVICE_NAME"
JAVA_MEM_OPTS=" -server -Xms256m -Xmx512m -Xmn256m -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m  -XX:+UseG1GC -XX:MaxGCPauseMillis=200"


echo -e "Starting the java $JAVA_MEM_OPTS $JAVA_OPTS -classpath $CONF_DIR:$LIB_DIR $MAIN_CLASS ...\c"

##注意下面的cd不能删除...
cd ..

nohup java $JAVA_MEM_OPTS $JAVA_OPTS -classpath $CONF_DIR:$LIB_DIR $MAIN_CLASS >/dev/null 2>&1 &
#java $JAVA_MEM_OPTS $JAVA_OPTS -classpath $CONF_DIR:$LIB_DIR $MAIN_CLASS

COUNT=0
while [ $COUNT -lt 1 ]; do
    echo -e ".\c"
    sleep 1
    COUNT=`ps -ef | grep java | grep "$SERVICE_NAME" |awk '{print $2}' | wc -l`
    if [ $COUNT -gt 0 ]; then
        break
    fi
done
echo "OK!"

P_ID=`ps -ef | grep java | grep -w "$SERVICE_NAME" | grep -v "grep" | awk '{print $2}'`
echo "$SERVICE_NAME Started and the PID is ${P_ID}."
