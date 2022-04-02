-- 创建时间:2021-01-19
-- 技能动画效果类：瞬间移动
local basefunc = require "Game/Common/basefunc"

SkillTransferRandom = basefunc.class(SkillBase)

local C = SkillTransferRandom
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillTransferRandom.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_transfer then
            return true
        end
    end
end

function C:OnTriggerBefore()
    local road_obj = DriveMapManager.GetMapPrefabByRoadID(DriveMapManager.ServerPosConversionRoadId(self.launcher_car.car_data.pos),true).transform:Find("skill_node")
    local fx_pre = newObject("chuansong_zong",road_obj)
    local obj_datas = self:GetObjs()
    for k,v in ipairs(obj_datas) do 
        if v.obj_car_transfer then
            self.obj_car_transfer = v
            -- DriveLogicProcess.set_process_data_use(self.obj_car_transfer.process_no)
        end
    end
    local circle_count = 0
    local move_count = 0
    if self.obj_car_transfer then
        move_count = self.obj_car_transfer.obj_car_transfer.end_pos - self.obj_car_transfer.obj_car_transfer.pos
        local cur_circle = math.floor(self.obj_car_transfer.obj_car_transfer.pos/DriveMapManager.map_count)
        local end_circle = math.floor(self.obj_car_transfer.obj_car_transfer.end_pos/DriveMapManager.map_count)
        circle_count = end_circle - cur_circle
    end
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    if circle_count > 0 then
        self.circle_font_pre = DriveAnimManager.PlayNewAttributeChangeFx("df_car_exchange_circle","com_img_quan",1,true,self.launcher_car:GetCenterPosition(),nil,nil,true,2)
        local font_txt = self.circle_font_pre.transform:Find("@add_desc_txt"):GetComponent("TMP_Text")

        self.chuansong_fx_pre = newObject("chuansong",GameObject.Find("Canvas/LayerLv3").transform)
        self.chuansong_fx_pre.transform.position = self.launcher_car:GetUICenterPosition()
        local particle_speed = 2
        self.chuansong_fx_pre.transform:Find("Particle System"):GetComponent("ParticleSystem").main.simulationSpeed = particle_speed
        for i = 1,circle_count do
            seq:AppendCallback(function()
                AudioManager.PlaySound(audio_config.drive.com_main_map_chaojichuansong.audio_name)
                self.chuansong_fx_pre.gameObject:SetActive(false)
                self.chuansong_fx_pre.gameObject:SetActive(true)
                font_txt.text = TMPNormalStringConvertTMPSpriteStr(i)
            end)
            seq:AppendInterval(1/particle_speed)
        end
        local font_target = DriveModel.Get3DTo2DPoint(DrivePlayerManager.cur_panel.circle_node_img.transform.position)
        seq:Append(self.circle_font_pre.transform:DOMove(font_target,1))
        seq:Join(self.circle_font_pre.transform:DOScale(Vector3.New(0.5,0.5,0.5),1))
        seq:AppendCallback(function()
            destroy(self.circle_font_pre)
            local info_panel = DrivePlayerManager.cur_panel
            local parm = {
                modify_key_name = "circle",
                modify_value = circle_count,
                car_no = self.launcher_car.car_data.car_no,
            }
            info_panel:OnAttributeChange(parm)
            info_panel:RefreshCircle()
        end)
    end
    seq:AppendCallback(function()
        destroy(fx_pre)
        self:OnActEnd()
    end)
end