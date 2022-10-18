#!/bin/sh
. /data/user.conf
export DIUN_VERSION111=$DIUN_VERSION
export DIUN_ENTRY_STATUS111=$DIUN_ENTRY_STATUS
export DIUN_HOSTNAME111=$DIUN_HOSTNAME
export DIUN_ENTRY_PROVIDER111=$DIUN_ENTRY_PROVIDER
export DIUN_ENTRY_IMAGE111=$DIUN_ENTRY_IMAGE
export DIUN_ENTRY_HUBLINK111=$DIUN_ENTRY_HUBLINK
export DIUN_ENTRY_MIMETYPE111=$DIUN_ENTRY_MIMETYPE
export DIUN_ENTRY_DIGEST111=$DIUN_ENTRY_DIGEST
export DIUN_ENTRY_CREATED111=$DIUN_ENTRY_CREATED
export DIUN_ENTRY_PLATFORM111=$DIUN_ENTRY_PLATFORM

if [[ "$DIUN_ENTRY_HUBLINK111" = *".docker"* ]]; then
    DIUN_ENTRY_HUBLINK111="${DIUN_ENTRY_HUBLINK111}/tags"
fi
imagename1="$(echo "$DIUN_ENTRY_IMAGE111" | cut -d / -f3)"
imagename2="$(echo "$DIUN_ENTRY_IMAGE111" | cut -d / -f2-3)"
imagename2="$(echo "${imagename2##*:}")"
imagename3="$(echo "$imagename1" | cut -d : -f1)"
imagename="$(echo "$imagename1" | sed 's/[:][:]*//g')"
# 通知标题首字母大写
imagename="$(echo ${imagename:0:1} | tr '[a-z]' '[A-Z]')${imagename:1}"
imagename1="$(echo ${imagename1:0:1} | tr '[a-z]' '[A-Z]')${imagename1:1}"
imagename2="$(echo ${imagename2:0:1} | tr '[a-z]' '[A-Z]')${imagename2:1}"
imagename3="$(echo ${imagename3:0:1} | tr '[a-z]' '[A-Z]')${imagename3:1}"
DIUN_ENTRY_PLATFORM111="$(echo ${DIUN_ENTRY_PLATFORM111:0:1} | tr '[a-z]' '[A-Z]')${DIUN_ENTRY_PLATFORM111:1}"

DIUN_ENTRY_CREATED222="$(echo "$DIUN_ENTRY_CREATED111" | cut -d . -f1)"
time_end="$(echo "$DIUN_ENTRY_CREATED111" | cut -d \  -f3)"

if [  "$time_end" = "+0000" ]; then
    time="$DIUN_ENTRY_CREATED222"
    seconds=`date -d "$time" +%s`
    seconds_cst=`expr $seconds + 28800`
    DIUN_ENTRY_CREATED111=`date -d @$seconds_cst "+%Y-%m-%d %H:%M:%S"`
    # echo $DIUN_ENTRY_CREATED  ${imagename2} "utc" $DIUN_ENTRY_CREATED111  >> /data/log.txt
else
    DIUN_ENTRY_CREATED111=$DIUN_ENTRY_CREATED222
    # echo $DIUN_ENTRY_CREATED  ${imagename2} "cst" $DIUN_ENTRY_CREATED111  >> /data/log.txt
fi

if [[ -z $DIUN_ENTRY_CREATED111 ]]; then
    DIUN_ENTRY_CREATED111="未获取到更新时间"
fi

function bark()
{   
    BARK_URL="https://api.day.app/push"

    cat>/data/${imagename}_bark<<EOF
{
    "title": "${imagename3} 更新啦 💬",
    "body": "标签：${imagename2}\n时间：${DIUN_ENTRY_CREATED111}\n平台：${DIUN_ENTRY_PLATFORM111}\n",
    "device_key": "${BARK_KEY}",
    "badge": 1,
    "sound": "minuet.caf",
    "icon": "https://crazymax.dev/diun/assets/logo.png",
    "group": "Docker_update",
    "url": "${DIUN_ENTRY_HUBLINK111}"
}
EOF

    /data/tools/curl -d @/data/${imagename}_bark -XPOST https://api.day.app/push --header 'Content-Type: application/json; charset=utf-8' 
    rm /data/${imagename}_bark
}

function qywx()
{
    RET=$(/data/tools/curl -s https://qyapi.weixin.qq.com/cgi-bin/gettoken?"corpid="${CORPID}"&corpsecret="${CORP_SECRET}"")
    KEY=$(echo ${RET} | /data/tools/jq -r .access_token)
    cat>/data/${imagename}_qywx<<EOF
{
   "touser" : "${TOUSER}",
   "msgtype" : "news",
   "agentid" : "${AGENTID}",
   "news" : {
       "articles":[
           {
               "title": "${imagename3} 更新啦 💬",
               "description": "标　　签：${imagename2}\n更新时间：${DIUN_ENTRY_CREATED111}\n平　　台：${DIUN_ENTRY_PLATFORM111}\n",
               "url": "${DIUN_ENTRY_HUBLINK111}"
            }
       ]
   },
   "enable_id_trans": 0,
   "enable_duplicate_check": 0,
   "duplicate_check_interval": 1800
}
EOF
    /data/tools/curl -d @/data/${imagename}_qywx -XPOST https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="${KEY}"
    rm /data/${imagename}_qywx
}

function qywxurl()
{
    RET=$(/data/tools/curl -s https://qyapi.weixin.qq.com/cgi-bin/gettoken?"corpid="${CORPID}"&corpsecret="${CORP_SECRET}"")
    KEY=$(echo ${RET} | /data/tools/jq -r .access_token)
    cat>/data/${imagename}_qywxurl<<EOF
{
   "touser" : "${TOUSER}",
   "msgtype" : "news",
   "agentid" : "${AGENTID}",
   "news" : {
       "articles":[
           {
               "title": "${imagename3} 更新啦 💬",
               "picurl": "${MEDIA_ID}",
               "description": "标　　签：${imagename2}\n更新时间：${DIUN_ENTRY_CREATED111}\n平　　台：${DIUN_ENTRY_PLATFORM111}\n",
               "url": "${DIUN_ENTRY_HUBLINK111}"
            }
       ]
   },
   "enable_id_trans": 0,
   "enable_duplicate_check": 0,
   "duplicate_check_interval": 1800
}
EOF
    /data/tools/curl -d @/data/${imagename}_qywxurl -XPOST https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="${KEY}"
    rm /data/${imagename}_qywxurl
}

function qywxmediaid()
{
    RET=$(/data/tools/curl -s https://qyapi.weixin.qq.com/cgi-bin/gettoken?"corpid="${CORPID}"&corpsecret="${CORP_SECRET}"")
    KEY=$(echo ${RET} | /data/tools/jq -r .access_token)
    cat>/data/${imagename}_qywxmediaid<<EOF
{
   "touser" : "${TOUSER}",
   "msgtype" : "mpnews",
   "agentid" : "${AGENTID}",
   "mpnews" : {
       "articles":[
           {
               "title": "${imagename3} 更新啦 💬",
               "thumb_media_id": "${MEDIA_ID}",
               "content": "标　　签：${imagename2}<br/>更新时间：${DIUN_ENTRY_CREATED111}<br/>平　　台：${DIUN_ENTRY_PLATFORM111}\n",
               "digest": "标　　签：${imagename2}\n更新时间：${DIUN_ENTRY_CREATED111}\n平　　台：${DIUN_ENTRY_PLATFORM111}\n",
               "content_source_url": "${DIUN_ENTRY_HUBLINK111}"
            }
       ]
   },
   "enable_id_trans": 0,
   "enable_duplicate_check": 0,
   "duplicate_check_interval": 1800
}
EOF
    /data/tools/curl -d @/data/${imagename}_qywxmediaid -XPOST https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="${KEY}"
    rm /data/${imagename}_qywxmediaid
}

function telegram()
{
    TG_URL='https://api.telegram.org/bot'${TG_TOKEN}'/sendMessage'
    cat>/data/${imagename}_tg<<EOF
{
    "chat_id": "${TG_CHAT_ID}",
    "parse_mode":"Markdown",
    "text": "*${imagename3} 更新啦 💬*\n\n*标　　签：* ${imagename2}\n*地　　址：* ${DIUN_ENTRY_HUBLINK111}\n*更新时间：* ${DIUN_ENTRY_CREATED111}\n*平　　台：* ${DIUN_ENTRY_PLATFORM111}\n"
}
EOF
    /data/tools/curl --location --request POST ${TG_URL} --header 'Content-Type: application/json' -d @/data/${imagename}_tg
    rm /data/${imagename}_tg
}

function discord()
{
    DISCORD_URL=${DISCORD_WEBHOOK}
    cat>/data/${imagename}_discord<<EOF
{   
    
    "avatar_url": "https://crazymax.dev/diun/assets/logo.png",
    "username": "Diun推送",
    "tts": true,
    "embeds": [
      {
        "color": 5486156,
        "image": {
          "url": "${DISCORD_PICURL}"
        },
        "fields": [
          {
            "name": "标签",
            "value": "${imagename2}"
          },
          {
            "name": "创建时间",
            "value": "${DIUN_ENTRY_CREATED111}"
          },
          {
            "name": "平台",
            "value": "${DIUN_ENTRY_PLATFORM111}"
          }
        ],
        "title": "${imagename3} 更新啦 💬",
        "description": "",
        "footer": {
          "text": "推送时间",
          "icon_url": ""
        },
        "timestamp": "$(date "+%Y-%m-%dT%H:%M:%S%:z")",
        "url": "${DIUN_ENTRY_HUBLINK111}"
      }
    ]
}
EOF
    /data/tools/curl --location --request POST ${DISCORD_URL} --header 'Content-Type: application/json' -d @/data/${imagename}_discord
    rm /data/${imagename}_discord
}

if [ ! -n "${TG_TOKEN}" ]; then
    echo "未配置电报参数或者配置不全，跳过通知！"
else
    telegram
fi

if [ ! -n "${CORP_SECRET}" ]; then
    echo "未配置企业微信参数或者配置不全，跳过通知！"
elif [[ "$MEDIA_ID" = "http"* ]]; then
    qywxurl
elif [ "$MEDIA_ID" = "" ]; then
    qywx
else  
    qywxmediaid
fi

if [ ! -n "${BARK_KEY}" ]; then
    echo "未配置Bark参数，跳过通知！"
else
    bark
fi

if [ ! -n "${DISCORD_WEBHOOK}" ]; then
    echo "未配置DISCORD_WEBHOOK参数或者配置不全，跳过通知！"
else
    discord
fi
