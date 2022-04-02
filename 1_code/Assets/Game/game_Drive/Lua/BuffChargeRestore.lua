local basefunc = require "Game/Common/basefunc"

BuffChargeRestore = basefunc.class(BuffBase)

local M = BuffChargeRestore
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffChargeRestore.super.ctor(self,buff_data)
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
end

function M:MakeListener()
	self.listener = {}
    self.listener["logic_drive_game_process_data_msg_player_action"] = basefunc.handler(self,self.on_drive_game_process_data_msg_player_action)
end
--创建回调
function M:OnCreate()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.2)
    
    seq:AppendCallback(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_nengliangchubei.audio_name)
        if not self.fx_pre then
            self.fx_pre = newObject("nengliangchubei",self.car.car.transform)
        end
        self.fx_pre.transform:Find("nengliangchubei_cheshen").gameObject:SetActive(false)
        self.fx_pre.transform:Find("nengliangchubei_zhongjiang").gameObject:SetActive(false)
        self.fx_pre.transform:Find("nengliangchubei_zhongjiang").gameObject:SetActive(true)
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        self.fx_pre.transform:Find("nengliangchubei_cheshen").gameObject:SetActive(true)
    end)
    seq:AppendCallback(function()
        self:OnTrigger()
    end)
end
--刷新时回调
function M:OnRefresh()
    self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.fx_pre = newObject("nengliangchubei",self.car.car.transform)
        self.fx_pre.transform:Find("nengliangchubei_cheshen").gameObject:SetActive(true)
	end
end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>能量储备技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end

function M:on_drive_game_process_data_msg_player_action(data)
	local player_action = DriveModel.data.players_info[self.car.car_data.seat_num].player_action
	if player_action then
        if player_action.op_type == DriveModel.OPType.accelerator_big then
            local seq = DoTweenSequence.Create()
            local fx_pre = newObject("dayoumen_nengliangchubei",self.car.car.transform)
            fx_pre.gameObject:SetActive(false)
            seq:AppendInterval(0.5)
            seq:AppendCallback(function()
                fx_pre.gameObject:SetActive(true)
            end)
            seq:AppendInterval(2)
            seq:AppendCallback(function()
                destroy(fx_pre)
            end)
		end
	end
end