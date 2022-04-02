local basefunc = require "Game/Common/basefunc"

DriveSelectToolOPPanel = basefunc.class()
local M = DriveSelectToolOPPanel
M.name = "DriveSelectToolOPPanel"

local instance
function M:AddListener()
    for proto_name, func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M.Init()
    return M.Create()
end

function M.Exit()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function M.Create(player_op)
    if not instance then
        instance = M.New(player_op)
    end
    instance:MyRefresh(player_op)
    return instance
end

function M.Instance()
    return instance
end

function M.PlayCloseAni(data)
    if not instance then
        M.Create(data.op_data)
    end
    instance:PlayAnimClose(data.op_arg_1)
end

function M:MakeListener()
    self.listener = {}
    self.listener["model_correct_op_timeout"] = basefunc.handler(self, self.on_model_correct_op_timeout)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function M:MyExit()
    if self.select_seq then
        self.select_seq:Kill()
        self.select_seq = nil
    end
    self:RemoveListener()
    destroy(self.gameObject)
    clear_table(self)
    if instance then
        instance = nil
    end
end

function M:ctor(player_op)
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    self.gameObject = newObject(M.name, parent)
    self.transform = self.gameObject.transform
    self.for_select_vec = player_op.for_select_vec
    self.tool_id = player_op.tool_id
	self.tools_cfg = ToolsManager.GetToolsCfgById(self.tool_id)
    basefunc.GeneratingVar(self.transform, self)

    self:MakeListener()
    self:AddListener()
    self:InitUI()
end

function M:InitUI()
    local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
    if not player_op then
        self.status_txt.text = "等待对手选择..."
    else
        self.status_txt.text = "请选择..."
    end
    self:MyRefresh()
end

function M:MyRefresh(player_op)
    if player_op then
		if player_op.for_select_vec then
			self.for_select_vec = player_op.for_select_vec
		end
		if player_op.tool_id then
			self.tool_id = player_op.tool_id
			self.tools_cfg = ToolsManager.GetToolsCfgById(self.tool_id)
		end
    end

	if not self.tools_cfg then return end

    if self.select_objs and next(self.select_objs) then
        for k, v in ipairs(self.select_objs) do
            destroy(v.obj)
            v = nil
        end
        self.select_objs = nil
    end

	for i=1,3 do
		self["title_" .. i .. "_txt"].text = self.tools_cfg.name
	end
	self.title_img.sprite = GetTexture(DriveMapManager.GetMapAssets(self.tools_cfg.icon))

    for k, v in ipairs(self.for_select_vec) do
        local cfg = self.tools_cfg
        if cfg then
            local pre = GameObject.Instantiate(self.select_obj.gameObject, self.select_layout)
            local tbl = basefunc.GeneratingVar(pre.transform)
            tbl.tools_name_txt.text = cfg.name
            for i = 1, 2 do
                tbl["tools_name_" .. i .. "_txt"].text = cfg.name
            end
            if cfg.tools_desc then
                tbl.tools_desc_txt.text = cfg.tools_desc
                tbl.tools_desc_txt.gameObject:SetActive(true)
            else
                tbl.tools_desc_txt.gameObject:SetActive(false)
            end

			if v == 1 then
				self.tools_type_txt.text = "放入背包"
			elseif v == 2 then
				self.tools_type_txt.text = "使用道具"
			end

            tbl.select_tools_btn.onClick:AddListener(
                function()
                    self:OnSelect(v)
                end
            )
            pre.gameObject:SetActive(true)
            self.select_objs = self.select_objs or {}
            self.select_objs[v] = {
                obj = pre.gameObject,
                tbl = tbl,
                cfg = cfg,
				op_arg_1 = v,
            }
        end
    end
end

function M:on_model_correct_op_timeout(data)
    self.timer_txt.text = math.floor(data.op_timeout) .. "S"
    if data.op_timeout == 0 then
        self:MyExit()
    end
end

function M:OnSelect(op_arg_1)
    local player_op = DriveModel.data.players_info[DriveModel.data.seat_num].player_op
    if not player_op then
        TipsShowUpText.Create("当前不该你操作")
        return
    end
	dump({op_type = DriveModel.OPType.select_tool_op, op_arg_1 = op_arg_1},"<color=white>选择道具？？？</color>")
    if op_arg_1 and self.select_objs[op_arg_1] then
        DriveModel.SendRequest("drive_game_player_op_req", {op_type = DriveModel.OPType.select_tool_op, op_arg_1 = op_arg_1})
    end
end

function M:PlayAnimClose(op_arg_1)
    local fx_time = 2
    local seq = DoTweenSequence.Create()
    self.select_seq = seq
    local now_select = self.select_objs[op_arg_1]
    now_select.obj.transform:Find("dianji").gameObject:SetActive(true)
    now_select.obj.transform:Find("guangbi").gameObject:SetActive(true)
    seq:AppendInterval(fx_time)
    for k, v in pairs(self.select_objs) do
        if k ~= op_arg_1 then
            seq:Join(v.obj.transform:GetComponent("CanvasGroup"):DOFade(0, fx_time))
        end
    end
    seq:AppendCallback(
        function()
            now_select.obj.transform:Find("guangbi").gameObject:SetActive(false)
            now_select.obj.transform:Find("guangbi").gameObject:SetActive(true)
            now_select.obj.transform:Find("dianji").gameObject:SetActive(false)
        end
    )
    seq:Join(now_select.obj.transform:GetComponent("CanvasGroup"):DOFade(0, 1))
    seq:Append(self.transform:GetComponent("CanvasGroup"):DOFade(0, 0.5))
    seq:AppendCallback(
        function()
            self.select_seq = nil
            Event.Brocast("process_play_next")
            self:MyExit()
        end
    )
end
