--[[
ganshuangfeng spine管理器
2018-4-26
]]
SpineManager = {}
local DDZPlayerSpine = {}
SpineManager.TrackIndex = 0

function SpineManager.AddDDZPlayerSpine(spine, seatNum)
	DDZPlayerSpine[seatNum] = spine
end
function SpineManager.RemoveDDZPlayerSpine(seatNum)
	if DDZPlayerSpine[seatNum] then
		destroy(DDZPlayerSpine[seatNum].gameObject)
	end
end
function SpineManager.RemoveAllDDZPlayerSpine()
	for k,v in pairs(DDZPlayerSpine) do
		if IsEquals(v) then
			destroy(v.gameObject)
		end
	end
    DDZPlayerSpine = {}
end

function SpineManager.GetSpine(seatNum)
	return DDZPlayerSpine[seatNum]
end

function SpineManager.SwitchAnimation(spine, animation, animation2)
	if not spine or not spine.AnimationState then return end
	DDZPlayerSpine[seatNum].skeleton:SetSlotsToSetupPose()
    local spineEvent = spine.AnimationState:SetAnimation(0, animation, false)
    spineEvent.Complete = spineEvent.Complete + function()
            OBJ.AnimationState:SetAnimation(0, animation2, true)
    end
end

function SetSortingOrder(seatNum, sorting_num)
	local spine = DDZPlayerSpine[seatNum]
	if not spine or not spine.AnimationState then return end
    local m_Mr = spine:GetComponent("MeshRenderer")
    m_Mr.sortingOrder = sorting_num
end