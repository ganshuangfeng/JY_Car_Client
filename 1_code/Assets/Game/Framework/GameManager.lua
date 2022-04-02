GameManager = {}
local M = GameManager

local runCall = function (call)
	if call then
		call()
	end
end

-- parm = {_goto 前往， frontcall 前调,backcall 回调 ，frontdata, backdata, parent, rul ...}
function M.Goto(parm)
	dump(parm,"<color=white>parm</color>")
	if not parm or not next(parm) then return end
	if not parm._goto then return end

	local _goto = parm._goto
	if SceneHelper.CheckGotoIsScene(_goto) then
		--前往场景
		if not parm.scene_name then
			parm.scene_name = parm._goto
		end
		return SceneHelper.GotoScene(parm)
	elseif _goto == "open_url" then
		runCall(parm.frontcall)
		UnityEngine.Application.OpenURL(parm.url)
	elseif _goto == "TipsShowUpText" then
		TipsShowUpText.Create(parm.str)
	else
		if _G[_goto] and _G[_goto].Create then
			runCall(parm.frontcall)
			return _G[_goto].Create(parm.parent, parm.backcall, parm.goto_parm)
		end
		local pre = GameModuleManager.Goto(parm)
		if pre then
			return pre
		end
		print("<color=red>找策划确认这个值要跳转到那里 _goto =" .. _goto .. "</color>")
		dump(parm)
		print(debug.traceback())
	end
end