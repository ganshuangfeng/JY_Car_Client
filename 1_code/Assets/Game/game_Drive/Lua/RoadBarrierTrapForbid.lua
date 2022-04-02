-- 创建时间:2021-03-29
-- 路障类型：禁停路障

local basefunc = require "Game/Common/basefunc"

RoadBarrierTrapForbid = basefunc.class(RoadBarrierBase)
local M = RoadBarrierTrapForbid
M.name = "RoadBarrierTrapForbid"



function M.Create(data)
    return M.New(data)
end

function M:MyExit()
    if self.listener then
        self:RemoveListener()
    end
    destroy(self.gameObject)
    clear_table(self)
end

function M:MakeListener()
    self.listener = {}
    self.listener["logic_drive_game_process_data_msg_player_op"] = basefunc.handler(self,self.on_logic_drive_game_process_data_msg_player_op)
end

function M:ctor(data)
    RoadBarrierTrapForbid.super.ctor(self,data)
end

function M:OnCreate()
    AudioManager.PlaySound(audio_config.drive.com_main_map_jintingbiaozhi.audio_name)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.5)
    seq:AppendCallback(function()
        local tran = DriveMapManager.GetMapPrefabByRoadID(self.road_barrier_data.road_id,true).transform:Find("skill_node").transform
        
        self.jinzhishiyong.transform.position = tran.position 
        self.jinzhishiyong.transform.rotation = tran.rotation
        self.jinzhishiyong.gameObject:SetActive(true)
    end)
end

function M:SetEnemyMeStyle()
    local mat = GetMaterial("InLightOutLine")
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) then
        mat = GetMaterial("InLightOutLineGreen")
        if self.jinzhishiyong then
            set_sprite_renderer_alpha(self.jinzhishiyong.transform,0.5)
        end
    else
        mat = GetMaterial("InLightOutLineRed")
        if self.jinzhishiyong then
            set_sprite_renderer_alpha(self.jinzhishiyong.transform,0.5)
        end
    end
    self.icon_img.material = mat
    self.item_img.material = mat
end

function M:MyRefresh(data)
    --如果是自己回合取消显示
    if DriveModel.CheckOwnerIsMe(self.road_barrier_data) and DriveModel.data.players_info[DriveModel.data.seat_num].player_op then
        if IsEquals(self.jinzhishiyong) then
            set_sprite_renderer_alpha(self.jinzhishiyong.transform,0)
        end
    else
        self:SetEnemyMeStyle()
    end
	
end

function M:Refresh()
end

function M:on_logic_drive_game_process_data_msg_player_op()
    self:MyRefresh()
end