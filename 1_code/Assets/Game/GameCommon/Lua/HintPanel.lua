
local basefunc = require "Game.Common.basefunc"

HintPanel = basefunc.class()
local M = HintPanel
M.name = "HintPanel"

--[[提示板parm
    msg - 显示的消息
    title - 抬头
    parent - 父节点
    prefab_name - 加载的预制体名字
    close_callback -退出回调
    show_close_btn -显示退出按钮

    yes_callback -确定回调
    show_yes_btn -显示确定按钮

    no_callback -取消回调
    show_no_btn -显示取消按钮

    理论上来说应该只有一个实例，不会有两个提示板同时存在
    但是这里仍然使用类进行，即可以多个实例
    层级应当比菊花还要高
]]
function M.Create(parm)
    return M.New(parm)
end

--[[错误提示板
    直接提供错误编号即可
]]
function M.ErrorMsg(errorID,callback)
    local msg
    if errorID then
        if errorID == 0 then
            return
        elseif errorID == -666 then
            return
        else
            msg = errorCode[errorID] or ("错误："..errorID)
        end
    else
        msg = "错误：errorID is nil"
    end
    local parm = {
        msg = msg,
        show_yes_btn = true,
        yes_callback = callback,
    }  
    return M.New(parm)
end


function M:ctor(parm)
    dump(parm,"<color=white>HintPanel</color>")
    self.parm = parm
    local prefab_name = self.parm.prefab_name or M.name
    local parent = self.parm.parent
    if not parent then
        local tf = GameObject.Find("Canvas/LayerLv50") or GameObject.Find("Canvas/LayerLv5")
        tf = tf or GameObject.Find("Canvas")
        parent = tf.transform
    end
    self.gameObject = newObject(prefab_name,parent)
    self.transform = self.gameObject.transform
    basefunc.GeneratingVar(self.transform,self)
    
    self:Init()

    DOTweenManager.OpenPopupUIAnim(self.center)
end

function M:Init()
    self.bg_btn.onClick:AddListener(function ()
        self:OnCloseClient()
    end)
    
    self.close_btn.onClick:AddListener(function ()
        self:OnCloseClient()
    end)

    self.yes_btn.onClick:AddListener(function ()
        self:OnYesClient()
    end)

    self.no_btn.onClick:AddListener(function ()
        self:OnNoClient()
    end)

    if self.parm.title then
        self.title_txt.text = self.parm.title
    end

    if self.parm.msg then
        self.msg_txt.text = self.parm.msg
    end

    self.close_btn.gameObject:SetActive(self.parm.show_close_btn)
    self.yes_btn.gameObject:SetActive(self.parm.show_yes_btn)
    self.no_btn.gameObject:SetActive(self.parm.show_no_btn)
end

function M:MyExit()
    destroy(self.gameObject)
    clear_table(self)
end

function M:OnCloseClient()
    if self.parm.close_callback then
        self.parm.close_callback()
    end
    self:MyExit()
end

function M:OnYesClient()
    if self.parm.yes_callback then
        self.parm.yes_callback()
    end
    self:MyExit()
end

function M:OnNoClient()
    if self.parm.no_callback then
        self.parm.no_callback()
    end
    self:MyExit()
end