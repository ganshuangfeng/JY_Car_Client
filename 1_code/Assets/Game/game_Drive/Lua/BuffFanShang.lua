local basefunc = require "Game/Common/basefunc"

BuffFanShang = basefunc.class(BuffBase)

local M = BuffFanShang
function M.Create(buff_data)
    return M.New(buff_data)
end

function M:ctor(buff_data)
    BuffFanShang.super.ctor(self,buff_data)
end

function M:MakeListener()
	self.listener = {}
    self.listener["play_process_obj_car_modify_property"] = basefunc.handler(self,self.on_play_process_obj_car_modify_property)
end

-- function M:OnCreate()
--     if not self.car then
--         self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
--     end
--     local img_font = "com_img_ftzj_map3"
--     if self.buff_data.buff_id == 114 then
--         img_font = "com_img_cjftzj_map3"
--     end
--         self:PlayObjs()
--     DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx",img_font,"",true,self.car:GetCenterPosition(),function()
--         self:OnActEnd()
--     end,true)
-- end

--移除回调
function M:OnDead()
    dump(self.buff_data,"<color=red>反伤技能移除 buff_data</color>")
    if self.fx_pre then
        destroy(self.fx_pre)
        self.fx_pre = nil
    end
    self:PlayObjs()
    self:OnActEnd()
end

--刷新时回调
function M:OnRefresh()
    if not self.fx_pre and self.buff_data.act ~= BuffManager.act_enum.dead then
        self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
        self.fx_pre = newObject("chelianghudun",self.car.car.transform)
        self.fx_pre.transform:Find("hudun"):GetComponent("Animator").enabled = true
        self.fx_pre.transform:Find("hudun"):GetComponent("Animator"):Play("fantanzhuangjian",0,0)
	end
end

function M:on_play_process_obj_car_modify_property(data)
    if (data[data.key].modify_key_name == "hp" or data[data.key].modify_key_name == "hd") and data.process_no then
        local datas = DriveLogicProcess.get_process_data_by_father_process_no(data.process_no)
        if datas and next(datas) then
            --判断这次伤害是否有反伤
            for k,v in ipairs(datas) do 
                local parm = v[v.key]
                if parm.modify_tag and next(parm.modify_tag) then
                    for _k,tag in ipairs(parm.modify_tag) do
                        if tag == "damage_rebound" then
                            DriveLogicProcess.on_process_play_by_no(v)
                            self:PlayReboundAttack(parm)
                        end
                    end
                end
            end
        end
    end
end

function M:PlayReboundAttack(parm)
    if self.fx_pre and IsEquals(self.fx_pre) then
        self.fx_pre.transform:Find("hudun"):GetComponent("Animator").enabled = true
        self.fx_pre.transform:Find("hudun"):GetComponent("Animator"):Play("fantanzhuangjia_shouji",0,0)
        local launcher_car = self.car
        local effecter_car = DriveCarManager.GetCarByNo(parm.car_no)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            if IsEquals(self.fx_pre) then
                self.fx_pre.transform:Find("hudun"):GetComponent("Animator"):Play("fantanzhuangjian",0,0)
            end
        end)
        local modify_key_name = parm.modify_key_name
        local damage_count = parm.modify_value
        local cur_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,modify_key_name)
        local total_v = DrivePlayerManager.GetShowAttribute(effecter_car.car_data.seat_num,effecter_car.car_data.car_id,modify_key_name .."_max")
        if not self.car then
            self.car = DriveCarManager.GetCarByNo(self.buff_data.owner_id)
        end
        local damage_fx_pre = newObject("fantan_feixinglizi",effecter_car.transform)
        damage_fx_pre.transform.position = Vector3.New(self.car.transform.position.x,self.car.transform.position.y,-1)
        local damage_desc = damage_count
        local _seq = DoTweenSequence.Create()
        -- _seq:AppendInterval(0.1)
        _seq:Append(damage_fx_pre.transform:DOLocalMove(Vector3.New(0,0,-1),0.5))
        _seq:OnForceKill(function()
            destroy(damage_fx_pre.gameObject)
            DriveAnimManager.PlayDamageFx(damage_desc,effecter_car:GetCenterPosition(),cur_v,cur_v + damage_count,total_v,nil,modify_key_name)
        end)
    end
end