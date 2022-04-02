-- 说明：公用的 枚举变量

-- 条件的处理方式
NOR_CONDITION_TYPE = {
    CONSUME = 1, -- 消费：必须大于等于，并扣除
    EQUAL = 2, -- 等于
    GREATER = 3, -- 大于等于
    LESS = 4, -- 小于等于
    NOT_EQUAL = 5 -- 不等于
}

-- 玩家财富类型
PLAYER_ASSET_TYPES =
{
	

}

-- 玩家财富类型集合 以及 所有 prop_ 开头的东西
PLAYER_ASSET_TYPES_SET =
{
	
}

--财富改变类型
ASSET_CHANGE_TYPE = {
    
}

--需要给tips的资产类型
TIPS_ASSET_CHANGE_TYPE = {
    
}

-- 支付： 支持的渠道类型
PAY_CHANNEL_TYPE = {
    alipay = true,
    weixin = true
}

--商品类型
GOODS_TYPE = {
    goods = "goods",
    jing_bi = "jing_bi",
    item = "item",
    gift_bag = "gift_bag",
    shop_gold_sum = "shop_gold_sum",
}

--道具类型
ITEM_TYPE = {
    expression = "expression",
    jipaiqi = "jipaiqi",
    room_card = "room_card",
    qys_ticket = "prop_2",
}

-- 活动提示状态值
ACTIVITY_HINT_STATUS_ENUM = {
    AT_Nor = "常态",
    AT_Red = "红点",
    AT_Get = "领奖",
}

--玩家类型
PLAYER_TYPE = {
    PT_New = "新玩家",
    PT_Old = "老玩家",
}

-- 服务器名字(类型)
SERVER_TYPE = {
    ZS = "zs", -- 正式
    CS = "cs", -- 测试
}