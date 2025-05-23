{
    "name": "分享",
    "entry": "Share",
    "doc": "进入对应的发布内容页面再启动，无限循环分享，需要手动结束",
    "pipeline_override": {
        "ReplyShareToQQ": {
            "next": [
                "Share"
            ]
        }
    }
},
{
    "name": "阅读量分享",
    "entry": "ShareContM",
    "doc": "进入个人发布内容页面，划至上方再启动，无限循环分享最上方内容，需要手动结束",
    "pipeline_override": {
        "ReplyShareToQQ": {
            "next": [
                "ShareImageVideoExit",
                "Share"
            ]
        }
    }
},
{
    "name": "分享（自定义）",
    "entry": "ToShare",
    "doc": "设置分享次数，Weibo分享设置1次\n作品编号为分享该页面第几个作品\n关闭阅读量，运行完成不会返回内容页，可自行添加返回任务",
    "repeatable": true,
    "repeat_count": 1,
    "option": [
        "是否阅读量",
        "分享至",
        "作品编号"
    ]
},
{
    "name": "个人内容分享",
    "entry": "ToContent",
    "doc": "分享个人号内容，设置次数、时间、循环次数",
    "repeatable": true,
    "repeat_count": 1,
    "option": [
        "分享次数",
        "从何时开始",
        "分享至何时"
    ],
    "pipeline_override": {
        "ToContentAll": {
            "next": [
                "ToShareC"
            ]
        }
    }
},
{
    "name": "微博阅读量",
    "entry": "Weibo",
    "doc": "进入微博应用程序，账号对应的发布内容页面再启动，无限循环分享，需要手动结束",
    "repeatable": true,
    "repeat_count": 10,
    "option": [
        "微博编号",
        "等待时间"
    ]
},
{
    "name": "微博阅读量（自定义）",
    "entry": "Weibo",
    "doc": "进入微博应用程序，账号对应的发布内容页面再启动，设置阅读次数\n微博编号为阅读该页面第几个微博",
    "repeatable": true,
    "repeat_count": 600,
    "option": [
        "微博编号",
        "等待时间"
    ],
    "pipeline_override": {
        "WeiboBack": {
            "next": [
                "Stop"
            ]
        }
    }
},
{
    "name": "进入个人微博",
    "entry": "StartWeibo",
    "doc": "进入微博应用程序个人微博页面"
}