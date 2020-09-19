---自定义玩家数据存储系统。作用类似与NetTable。只不过可以指定玩家去更新而不用每次都更新所有人的数据
PlayerTables = require("libraries.PlayerTables")

require('libraries.util')--语言级的一些工具方法
--用来向ui发送消息
Notifications = require('libraries.notifications')
require('libraries.timers') --可以用来方便的创建定时器
TimerUtil = require("libraries.TimerUtil")--计时器工具类

require('libraries.projectiles') --投射物工具类。弹道物品

JSON = require("libraries.dkjson")
 --数字提示
require("libraries.PopupNumbers")
require("libraries.bit") 
require("libraries.DotaEx")

sha1 = require("libraries.sha1")
--require("libraries.ApiDumper")--解析dota2 API用，里面有些接口不能用了，比如bit，所以解析不了了
