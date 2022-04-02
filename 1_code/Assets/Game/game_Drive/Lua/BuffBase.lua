

local basefunc = require "Game/Common/basefunc"

BuffBase = basefunc.class()
local M = BuffBase
M.name = "BuffBase"

function M.Create(buff_data)
	return M.New(buff_data)
end

function M:ctor(buff_data)
	self:MakeListener()
	self:AddListener()
	self:Refresh(buff_data)
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
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
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

function M:Refresh(buff_data)
	dump(buff_data,"<color=white>buff_data refresh</color>")
	self.buff_data = buff_data or self.buff_data
	if self.buff_data.buff_id then
		self.buff_cfg = BuffManager.GetBuffCfgById(self.buff_data.buff_id)
	end
	if not self.buff_cfg then
		dump(self.buff_data,"<color=red>buff配置错误buff_data</color>")
	end
	self:OnRefresh()
end

--刷新时回调
function M:OnRefresh()
	
end

function M:OnActStart(act)
	local act = act or self.buff_data.act
	if act == BuffManager.act_enum.create then
		self:SetCreateData()
		self:OnCreate()
	elseif act == BuffManager.act_enum.dead then
		self:SetDeadData()
		self:OnDead()
	elseif act == BuffManager.act_enum.trigger then
		self:SetTriggerData()
		self:OnTrigger()
	elseif act == BuffManager.act_enum.refresh then
		self:SetRefreshData()
		self:OnRefreshAct()
	else
		dump(act,"<color=red>不存在的buff_act</color>")
		self:OnActEnd()
	end
end

---创建时回调，默认在地图上创建一个
function M:OnCreate()
	--创建了默认立即触发
	self:OnTrigger()
end

---移除时回调，默认在地图上移除
function M:OnDead()
	self:PlayObjs()
	self:OnActEnd()
end

function M:OnRefreshAct()
	self:PlayObjs()
	self:OnActEnd()
end

---触发时回调
function M:OnTrigger()
	self:OnTriggerBefore()
end

---buff前摇，在子类中重写
function M:OnTriggerBefore()
	dump("before_anim")
	self:OnTriggerMain()
end

---buff主效果，在子类中重写
function M:OnTriggerMain()
	dump("main_anim_playing")
	self:PlayObjs()
	self:OnTriggerEnd()
end

---buff后摇，在子类中重写
function M:OnTriggerEnd()
	dump("end_anim_playing")
	self:OnActEnd()
end

function M:OnActEnd()
	if not self.buff_data then
		Event.Brocast("process_play_next")
		return
	end
	if self.buff_data.status == BuffManager.status_enum.create then
		Event.Brocast("process_play_next")
	elseif self.buff_data.status == BuffManager.status_enum.dead then
		self:MyExit()
		Event.Brocast("process_play_next")
	elseif self.buff_data.status == BuffManager.status_enum.trigger then
	elseif self.buff_data.status == BuffManager.status_enum.refresh then
		Event.Brocast("process_play_next")
	end
end

function M:SetCreateData()
	self.buff_data.status = BuffManager.status_enum.create
end

function M:SetTriggerData()
	self.buff_data.status = BuffManager.status_enum.trigger
end

function M:SetRefreshData()
	self.buff_data.status = BuffManager.status_enum.refresh
end

function M:SetDeadData()
	self.buff_data.status = BuffManager.status_enum.dead
end

function M:SetObjCheckFunc()
	
end

function M:GetObj(check_use)
	local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.buff_data.process_no)
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
	if self.buff_data then
		local obj_datas = DriveLogicProcess.get_process_data_by_father_process_no(self.buff_data.process_no)
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
	else 
		return {} 
	end
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
			--这里buff往往会带来skill_change但是skill_change在skill里面已经有处理了
			if obj_data and not obj_data.skill_change then
				DriveLogicProcess.on_process_play_by_no(obj_data,funcs)
			end
		end        
    end
	if callback and type(callback) == "function" then
		callback()
	end
end

--修改车辆攻击范围
function M:SetBuffModify(buff_data,buff_cfg)
    if not buff_data or not buff_cfg then return end
    local sd = {}
    sd.owner_type = buff_data.owner_type
    sd.owner_id = buff_data.owner_id
    sd.skill_id = buff_data.skill_id
    local skill_item = SkillManager.GetSkill(sd)
    if not skill_item then return end
    if buff_data.owner_type == 2 then
        local car_data = {
            car_no = buff_data.owner_id
        }
        --作用于车
        local car = DriveCarManager.GetCar(car_data)
        if not car then return end
        if buff_data.modify_key_name == "attack_radius" then
            --修改攻击范围
            if car.set_effect_field_radius then
                car:set_effect_field_radius(buff_data)
            elseif car[car.config.car_type].set_effect_field_radius then
                car[car.config.car_type]:set_effect_field_radius(buff_data)
            else
                dump(car,"<color=red>未实现修改攻击范围方法</color>")
            end
        end
    end
end