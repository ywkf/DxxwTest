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
},
{
            "name": "圈子点赞收藏(beta)",
            "entry": "Circle",
            "doc": "循环点赞收藏（评论）圈子内容\n视频评论需要用到XF输入法的语录功能，需要自行添加\n视频评论语录次数 需要设置语录发送方式为 手动上屏\n开启至1天前，会在1天前的内容后停止",
            "repeatable": true,
            "repeat_count": 1,
            "option": [
                "圈子选择",
                "滑动速度",
                "是否评论",
                "视频评论语录次数",
                "从时间点开始",
                "何时结束",
                "识别列表成员",
                "误入动态判断"
            ],
            "pipeline_override": {
                "NameList": {
                    "enabled": false
                }
            }
        },
        {
            "name": "圈子点赞收藏(beta)自定义",
            "entry": "CircleSwipe0",
            "doc": "进入圈子后再启动，循环点赞收藏（评论）圈子内容，需要手动结束\n视频评论需要用到XF输入法的语录功能，需要自行添加\n视频评论语录次数 需要设置语录发送方式为 手动上屏",
            "option": [
                "滑动速度",
                "是否评论",
                "视频评论语录次数",
                "从时间点开始",
                "何时结束",
                "识别列表成员",
                "误入动态判断"
            ],
            "pipeline_override": {
                "NameList": {
                    "enabled": false
                },
                "IsTop": {
                    "enabled": false
                },
                "IsCompleted": {
                    "enabled": false
                }
            }
        },
        {
            "name": "圈子点赞收藏(beta)评论列表",
            "entry": "Circle",
            "doc": "默认启用评论，评论列表账号\n循环点赞收藏圈子内容\n视频评论需要用到XF输入法的语录功能，需要自行添加\n视频评论语录次数 需要设置语录发送方式为 手动上屏\n开启至1天前，会在1天前的内容后停止",
            "repeatable": true,
            "repeat_count": 1,
            "option": [
                "圈子选择",
                "滑动速度",
                "视频评论语录次数",
                "从时间点开始",
                "何时结束",
                "误入动态判断"
            ],
            "pipeline_override": {
                "NameList": {
                    "next": [
                        "ClickName"
                    ]
                },
                "CCommentBack02": {
                    "next": [
                        "CircleCollect",
                        "CircleSwipe2"
                    ]
                }
            }
        },
        {
            "name": "回赞与收藏(beta)",
            "entry": "RepkyLike",
            "doc": "进入对应的账号页面再启动，点赞收藏评论账号内所有图文和视频\n视频评论需要用到XF输入法的语录功能，需要自行添加",
            "option": [
                "从视频开始",
                "是否分享",
                "视频评论",
                "视频评论语录次数",
                "至何时结束"
            ],
            "advanced": [
                "自定义账号"
            ]
        },