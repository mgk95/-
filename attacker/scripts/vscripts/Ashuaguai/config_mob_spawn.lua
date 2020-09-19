return {
    -- 刷怪开始时间（秒）
    spawn_start_time = 1,
    -- 波次配置
    waves = {
        -- 每一个{}都是一波兵
        {
            -- 怪物单位名称
            name = "yang",
            -- 本波个数
            num = 5,
             -- 怪物等级
            level = 5,
            -- 刷怪点的名字，这里直接用了路径起始点
            location = "shuaguai_1",
            -- 怪物寻路的路径起始点
            path = "shuaguai_2"
        };

        {
            -- 怪物单位名称
            name = "niu",
            -- 本波个数
            num = 5,
            -- 怪物等级
            level = 10,
            -- 刷怪点的名字，这里直接用了路径起始点
            location = "shuaguai_1",
            -- 怪物寻路的路径起始点
            path = "shuaguai_2"

        };

        {
            -- 怪物单位名称
            name = "huoren",
            -- 本波个数
            num = 5,
            -- 怪物等级
            level = 15,
            -- 刷怪点的名字，这里直接用了路径起始点
            location = "shuaguai_1",
            -- 怪物寻路的路径起始点
            path = "shuaguai_2"
        };

        {
            -- 怪物单位名称
            name = "wolf",
            -- 本波个数
            num = 5,
            -- 怪物等级
            level = 20,
            -- 刷怪点的名字，这里直接用了路径起始点
            location = "shuaguai_1",
            -- 怪物寻路的路径起始点
            path = "shuaguai_2"
        };
--]]
    }
}