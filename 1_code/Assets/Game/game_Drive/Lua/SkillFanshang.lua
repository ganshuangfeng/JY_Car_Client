-- 技能动画效果类：黑夜
local basefunc = require "Game/Common/basefunc"

SkillFanshang = basefunc.class(SkillBase)

local C = SkillFanshang
local fx_name = "violent_weapon_buff_fx"
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillFanshang.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_modify_property and v.obj_car_modify_property.modify_key_name == "at" then
            return true
        end
    end
end

function C:OnTriggerBefore()
    AudioManager.PlaySound(audio_config.drive.com_main_fantanzhuangjia.audio_name)
    local skill_data = self.skill_data
	local data = DriveLogicProcess.get_process_data_by_father_process_no(skill_data.process_no)
	if data and next(data) then
		for k,v in ipairs(data) do
			--不进行处理的与技能相关的obj
			if not (v.player_op or v.status_change or v.buff_create or v.tool_create) then
				DriveLogicProcess.set_process_data_use(v.process_no)
			end
		end
	end
    self:OnTriggerMain()
end

function C:OnTriggerMain()
    local img_font = "com_img_ftzj_map3"
    if self.skill_data.skill_id == 20018 then
        img_font = "com_img_cjftzj_map3"
    end
    DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.launcher_car:GetCenterPosition(),function()
        self:OnActEnd()
    end,true)
end