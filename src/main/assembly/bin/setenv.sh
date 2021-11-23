#!/bin/bash
echo "info 加载CAT agent v1.0.2 2020-03-09"
echo "info 适用于tomcat应用（码上行、支付、出行平台、数字票务）"

#env setting
APP_HOME=$(cd `dirname $0`;cd ..;pwd)
SERVICE_NAME=${APP_HOME##*/}
BIN_DIR=$APP_HOME/bin

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

##***********以下加载CAT agent***********
## CAT安装目录和日志目录
CAT_HOME=/opt/app/cat
CAT_LOG=/opt/logs/cat

CAT_CONFIG_FILE="$CAT_HOME/client.xml"
##判断CAT配置文件是否存在
if [[ -f "$CAT_CONFIG_FILE" ]]; then
    #日志目录不存在则创建
    if [ ! -d $CAT_LOG ]; then
        mkdir $CAT_LOG
        echo "info CAT的日志存放路径创建完成, log dir = $CAT_LOG"
    fi

    ##CAT的app.name获取，优先从环境变量中读取，读取不到则根据主机名进行截取
    if [ -z $CAT_APP_NAME ]; then
        echo "info 环境变量没有配置CAT_APP_NAME, 即将从主机名称中解析!"
        TMP_HOST_NAME=`hostname`
        echo "debug 主机名称=$TMP_HOST_NAME"

        SPLIT_COUNT=$(grep -o "-" <<< "$TMP_HOST_NAME" | wc -l)
        if [ $SPLIT_COUNT -lt 2 ]; then
            CAT_APP_NAME="default"
            echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
            echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
            echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
        else
            CAT_APP_NAME=`echo $TMP_HOST_NAME| cut -d "-" -f 1,2`
        fi
    else 
       echo "info 使用环境变量的CAT_APP_NAME配置, CAT_APP_NAME="$CAT_APP_NAME 
    fi


    if [ -z "$CAT_APP_NAME" ]; then
        CAT_APP_NAME="default"
	      echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
	      echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
	      echo "warn CAT_APP_NAME无法正确获取，默认设置为default，请及时修改主机名（格式: 区域-产品线-模块-xxx）"
    fi

    echo "info CAT_HOME=$CAT_HOME"
    echo "info CAT_LOG=$CAT_LOG"
    echo "info CAT_APP_NAME=$CAT_APP_NAME"

    LIB_CAT_JARS=`ls $CAT_HOME|grep .jar|awk '{print "'$CAT_HOME'/"$0}'|tr "\n" ":"`
    LIB_CAT_PLUGIN_JARS=`ls $CAT_HOME/plugin|grep .jar|awk '{print "'$CAT_HOME/plugin'/"$0}'|tr "\n" ":"`
    LIB_JARS=${LIB_CAT_JARS}${LIB_CAT_PLUGIN_JARS}$LIB_JARS
    CLASSPATH=$LIB_JARS:$CLASSPATH

    JAVA_OPTS="$JAVA_OPTS -Daj.weaving.verbose=true"
    JAVA_OPTS="$JAVA_OPTS -javaagent:$CAT_HOME/agent/aspectjweaver-1.8.10.jar"
    JAVA_OPTS="$JAVA_OPTS -javaagent:$CAT_HOME/agent/cat-client-agent-0.0.1-SNAPSHOT.jar=$CAT_HOME/catagent-conf.properties"
    JAVA_OPTS="$JAVA_OPTS -Dorg.aspectj.weaver.loadtime.configuration=file:$CAT_HOME/aop.xml"
    JAVA_OPTS="$JAVA_OPTS -DCATPLUGIN_CONF=$CAT_HOME/catplugin-conf.properties "
    JAVA_OPTS="$JAVA_OPTS -DCAT_HOME=$CAT_HOME/"
    JAVA_OPTS="$JAVA_OPTS -DCAT_LOG=$CAT_LOG/"
    JAVA_OPTS="$JAVA_OPTS -DCAT_APP_NAME=$CAT_APP_NAME"

    echo "JAVA_OPTS=$JAVA_OPTS"
    echo "info CAT agent加载完成"
else
    echo "error CAT agent没有正确安装!!! 安装目录必须是$CAT_HOME"
    echo "error CAT agent没有正确安装!!! 安装目录必须是$CAT_HOME"
    echo "error CAT agent没有正确安装!!! 安装目录必须是$CAT_HOME"
fi


echo "info setenv.sh执行完成"
echo ""
