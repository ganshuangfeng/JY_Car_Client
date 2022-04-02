

local basefunc = require "Game/Common/basefunc"

SkillBase = basefunc.class()
local M = SkillBase
M.name = "SkillBase"

function M.Create(skill_data)
	return M.New(skill_data)
end

function M:ctor(skill_data)
	self:MakeListener()
	self:AddListener()
	self:Refresh(skill_data)
	self:SetObjCheckFunc()
	self.skill_buff = SkillBuffBase.Create(self)
end

function M:MyExit()
	self:MyExitSubclass()
	self:RemoveListener()
	self.skill_buff:MyExit()
	clear_table(self)
end

function M:MyExitSubclass()
end

function M:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function M:MakeListener()
	self.listener = {}
end

function M:RemoveListener()
	if self.listener then
		for proto_name,func in pairs(self.listener) do
			Event.RemoveListener(proto_name, func)
		end
	end
    self.listener = {}
end

function M:InitUI(parent)
	self.InitUISubclass()
	self.skill_buff:InitUI(parent)
end

function M:RefreshView(parent)
	self.RefreshViewSubclass()
	if self.skill_buff then
		self.skill_buff:RefreshView(parent)
	end
end

function M:InitUISubclass()
	
end

function M:RefreshViewSubclass()
	
end

function M:Refresh(skill_data)
	self.skill_data = skill_data or self.skill_data
	if self.skill_data.skill_id then
		self.skill_cfg = SkillManager.GetSkillCfgById(self.skill_data.skill_id)
	end
	if not self.skill_cfg then
		dump(self.skill_data,"<color=red>技能配置错误skill_data</color>")
	end

    if self.skill_data.launcher then
        local launcher = self.skill_data.launcher[1]
		self.launcher_car = DriveCarManager.GetCarByNo(launcher)
		self.launcher = launcher
	end
    if self.skill_data.effecter then
        local effecter = self.skill_data.effecter[1]
		self.effecter_car = DriveCarManager.GetCarByNo(effecter)
		self.effecter = effecter
	end
	self:RefreshSubclass()
	self:RefreshView()
end

function M:RefreshSubclass()
	
end

function M:OnActStart(act,data)
	local act = act or self.skill_data.act
	if act == SkillManager.act_enum.create then
		self:SetCreateData()
		self:OnCreate()
	elseif act == SkillManager.act_enum.dead then
		self:SetDeadData()
		self:OnDead()
	elseif act == SkillManager.act_enum.trigger then
		self:SetTriggerData()
		self:OnTrigger()
	elseif act == SkillManager.act_enum.change then
		self:SetChangeData(data)
		self:OnChange(data)
	else
		dump(act,"<color=red>不存在的skill_act</color>")
		self:OnActEnd()
	end
end

---创建时回调，默认在地图上创建一个
function M:OnCreate()
	self:OnActEnd()
end

---移除时回调，默认在地图上移除
function M:OnDead()
	self:OnActEnd()
end

---改变时回调
function M:OnChange()
	self:OnActEnd()
end

---触发时回调
function M:OnTrigger()
	self:OnTriggerBefore()
end

---技能前摇，在子类中重写
function M:OnTriggerBefore()
	dump("before_anim")
	--在这里将未实现的技能的数据set_use
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

---技能主效果，在子类中重写
function M:OnTriggerMain()
	dump("main_anim_playing")
	self:OnTriggerEnd()
end

---技能后摇，在子类中重写
function M:OnTriggerEnd()
	dump("end_anim_playing")
	self:OnActEnd()
end

function M:OnActEnd()
	if self.skill_data.status == SkillManager.status_enum.dead then
		self:MyExit()
	end
	Event.Brocast("process_play_next")
end

function M:SetCreateData()
	self.skill_data.status = SkillManager.status_enum.create
end

function M:SetTriggerData()
	self.skill_data.status = SkillManager.status_enum.trigger
end

function M:SetDeadData()
	self.skill_data.status = SkillManager.status_enum.dead
end

function M:SetChangeData(data)
	self.skill_data = data
	self.skill_data.status = SkillManager.status_enum.change
end

function M:SetObjCheckFunc()
	
end

function M:GetObj(check_use)
	local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.skill_data.process_no)
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if obj_data and (not check_use or (check_use and not obj_data.use)) then
				if self.obj_check_func and self.obj_check_func(obj_data) then
					return obj_data
				elseif not self.obj_check_func then
					return obj_data
				end
			end
		end
    end
end

function M:GetObjs()
	local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.skill_data.process_no)
	local _obj_datas = {}
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if self.obj_check_func and self.obj_check_func(obj_data) then
				_obj_datas[#_obj_datas + 1] = obj_data
			elseif not self.obj_check_func then
				_obj_datas[#_obj_datas + 1] = obj_data
			end
		end
    end
	return _obj_datas
end

function M:PlayObjData(obj_data,callback,funcs,other_data)
	if obj_data then
		dump(obj_data,"<color=yellow>skill obj: </color>")
		DriveLogicProcess.on_process_play_by_no(obj_data,funcs,other_data)
	end
	if callback and type(callback) == "function" then
		callback()
	end
end

function M:PlayObj(callback,funcs)
	local obj_data = self:GetObj()
	if obj_data then
		dump(obj_data,"<color=yellow>skill obj: </color>")
		DriveLogicProcess.on_process_play_by_no(obj_data,funcs)
	end
	if callback and type(callback) == "function" then
		callback()
	end
end

function M:PlayObjs(callback,funcs)
	local obj_datas = self:GetObjs()
    if obj_datas and next(obj_datas) then
		for i,obj_data in ipairs(obj_datas) do
			if obj_data then
				dump(obj_data,"<color=yellow>skill obj: </color>")
				DriveLogicProcess.on_process_play_by_no(obj_data,funcs)
			end
		end        
    end
	if callback and type(callback) == "function" then
		callback()
	end
end

--通用的伤害效果，连击，暴击，miss等效果也先暂时在这里处理
function M:PlayDamageFx(obj_car_modify_property,cbk)
	dump(obj_car_modify_property,"<color=red>obj_car_modify_property</color>")
	if not obj_car_modify_property or
	not obj_car_modify_property.modify_key_name or
	not (obj_car_modify_property.modify_key_name == "hp" or obj_car_modify_property.modify_key_name == "hd") then
		dump(obj_car_modify_property,"<color=red>obj_car_modify_property 不合法</color>")
		return
	end
	local modify_key_name = obj_car_modify_property.modify_key_name
	local modify_type = obj_car_modify_property.modify_type
	local damage_count = obj_car_modify_property.modify_value
	local cur_v = DrivePlayerManager.GetShowAttribute(self.effecter_car.car_data.seat_num,self.effecter_car.car_data.car_id,modify_key_name)
	local total_v = DrivePlayerManager.GetShowAttribute(self.effecter_car.car_data.seat_num,self.effecter_car.car_data.car_id,modify_key_name .."_max")
	local damage_desc = damage_count
	if modify_type == 2 then
		damage_desc = math.floor(damage_count / total_v  * 100) .. "%"
	end
	local bj_flag = false
	local miss_flag = false
	if obj_car_modify_property.modify_tag and next(obj_car_modify_property.modify_tag) then
		for k,v in ipairs(obj_car_modify_property.modify_tag) do
			if v == "bj" then
				--如果存在暴击标签则走暴击的逻辑
				bj_flag = true
				DriveAnimManager.PlayCritDamageFx(damage_desc,self.effecter_car:GetCenterPosition(),cur_v,cur_v + damage_count,total_v,function()
					if cbk then cbk() end
				end,modify_key_name)
			elseif v == "lj" then
				-- local car_no = self.launcher
				-- DriveAnimManager.PlayAttributeChangeFx("miss_fx","com_img_lj","",true,DriveCarManager.GetCarByNo(car_no):GetCenterPosition())
			elseif v == "miss" then
				miss_flag = true
				local car_no = self.effecter
				DriveAnimManager.PlayAttributeChangeFx("miss_fx","com_img_miss_map3","",true,DriveCarManager.GetCarByNo(car_no):GetCenterPosition(),function()
					if cbk then cbk() end
				end)
			end
		end
	end

	if not bj_flag and not miss_flag then
		DriveAnimManager.PlayDamageFx(damage_desc,self.effecter_car:GetCenterPosition(),cur_v,cur_v + damage_count,total_v,function()
			if cbk then cbk() end
		end,modify_key_name)
	end
end