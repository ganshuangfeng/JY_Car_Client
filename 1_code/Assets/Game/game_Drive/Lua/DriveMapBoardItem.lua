local basefunc = require "Game/Common/basefunc"

DriveMapBoardItem = basefunc.class()
local C = DriveMapBoardItem
C.name = "DriveMapBoardItem"

function C.Create(parent,item_data)
	return C.New(parent,item_data)
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.listener) do
        Event.RemoveListener(proto_name, func)
    end
    self.listener = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
	clear_table(self)
end

function C:ctor(parent,item_data)
	local parent = parent
	local obj = newObject(C.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	self.item_data = item_data
	self.gameObject.name = self.item_data.road_id
	basefunc.GeneratingVar(self.transform, self)
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

function C:InitUI()
	self.transform.localPosition = self.pos or Vector3.New(0,0,-0.1)
	if self.item_data.road_id == 12 then
		self.select_type = 2
		self.small_acc = 2
	elseif self.item_data.road_id == 3 or self.item_data.road_id == 10 or self.item_data.road_id == 14 or self.item_data.road_id == 21 then
		self.select_type = 3
		local select_node = self["select_type_" .. self.select_type]
		local select_rotate = {
			[3] = {
				pos = {
					x = -55 / 100,
					y = 55 / 100,
				},
				euler_z = 0
			},
			[10] = {
				pos = {
					x = -55 / 100,
					y = -55 / 100
				},
				euler_z = 90
			},
			[14] = {
				pos = {
					x = 55 / 100,
					y = -55 / 100
				},
				euler_z = -180
			},
			[21] = {
				pos = {
					x = 55 / 100,
					y = 55 / 100,
				},
				euler_z = -90
			},

		}
		local rotate_data = select_rotate[self.item_data.road_id]
		if rotate_data then
			select_node.transform.localPosition = Vector3.New(rotate_data.pos.x,rotate_data.pos.y,-0.1)
			select_node.transform.localRotation = Quaternion:SetEuler(0,0,rotate_data.euler_z) 
		end

		self.small_acc = 3
		local small_acc_node = self["small_acc_" .. self.small_acc]
		local small_acc_txt = self["small_acc_" .. self.small_acc .. "_txt"]
		local rotate_data = select_rotate[self.item_data.road_id]
		if rotate_data then
			small_acc_node.transform.localPosition = Vector3.New(rotate_data.pos.x,rotate_data.pos.y,-0.1)
			small_acc_node.transform.localRotation = Quaternion:SetEuler(0,0,rotate_data.euler_z) 
			small_acc_txt.transform.localRotation = Quaternion:SetEuler(0,0,-rotate_data.euler_z) 
		end
	else
		self.select_type = 1
		self.small_acc = 1
		local select_node = self["select_type_" .. self.select_type]
		local small_acc_node = self["small_acc_" .. self.small_acc]
		local small_acc_txt = self["small_acc_" .. self.small_acc .. "_txt"]
		if self.item_data.road_id == 1 or self.item_data.road_id == 2 or self.item_data.road_id == 11 or self.item_data.road_id == 13 or self.item_data.road_id == 22 then
			select_node.transform.localRotation = Quaternion:SetEuler(0,0,90) 
			small_acc_node.transform.localRotation = Quaternion:SetEuler(0,0,90) 
			small_acc_txt.transform.localRotation = Quaternion:SetEuler(0,0,-90) 
		end
	end
	self.select_btn = self["select_type_" .. self.select_type].transform:Find("@select_btn")
	EventTriggerListener.Get(self.select_btn.gameObject).onClick = basefunc.handler(self, self.OnClick)
	self:MyRefresh()
end

function C:OnClick(  )
	--5 :选择道路操作
	local s_road_id = C.GetServerRoadId(self.item_data.road_id)
	if DriveModel.data.players_info[DriveModel.data.seat_num].player_op then
		local optype = DriveModel.data.players_info[DriveModel.data.seat_num].player_op.op_type
		DriveModel.SendRequest("drive_game_player_op_req",{op_type = optype,op_arg_1 = s_road_id})
	end
end

--获得本格在服务器上对应的road_id
function C.GetServerRoadId(road_id)
	local s_road_id = (road_id - (DriveMapManager.first_id - 1) + DriveMapManager.map_count) % DriveMapManager.map_count
	if s_road_id == 0 then s_road_id = DriveMapManager.map_count end
	return s_road_id
end

function C:MyRefresh()

end

function C:ActiveSelectBtn(b)
	self["select_type_" .. self.select_type].gameObject:SetActive(b)
end

function C:ActiveSmallAcc(b,num)
	self["small_acc_" .. self.small_acc].gameObject:SetActive(b)
	if num then
		self["small_acc_" .. self.small_acc .. "_txt"].text = num
		self["small_acc_" .. self.small_acc .. "_txt"].gameObject:SetActive(true)
	else
		self["small_acc_" .. self.small_acc .. "_txt"].gameObject:SetActive(false)
	end
end