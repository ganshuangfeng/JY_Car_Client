-- 创建时间:2018-05-29
package.loaded["Game.game_Loding.Lua.LodingModel"] = nil
require "Game.game_Loding.Lua.LodingModel"
package.loaded["Game.game_Loding.Lua.LodingPanel"] = nil
require "Game.game_Loding.Lua.LodingPanel"
package.loaded["Game.game_Loding.Lua.LodingSmallPanel"] = nil
require "Game.game_Loding.Lua.LodingSmallPanel"

LodingLogic = {}
local this -- 单例
local lodingModel

-- 是不是小的过渡界面
function LodingLogic.Init(parm, cbk, isSmall)
    this = LodingLogic
    this.parm = parm
    this.cbk = cbk
    lodingModel = LodingModel.Init()
    if isSmall then
        LodingSmallPanel.Create()
	else
	    LodingPanel.Create()
	end
end
-- 场景加载完成，启动游戏Logic
function LodingLogic.LoadSceneFinish( )
	local sceneName = MainModel.myLocation
	resMgr:LoadSceneFinish(sceneName)
	gameMgr:LoadSceneFinish()
	coroutine.start(function ( )
        -- 下一帧
        Yield(0)

		resMgr:LoadSceneLuaBundle(sceneName)
	    local ns = StringHelper.Split(sceneName, "_")
	    if #ns ~= 2 then
	        print("<color=red> Error GotoScene ".. sceneName .. " </color>")
	        return
	    end

	    local layerLv50 = GameObject.Instantiate(GetPrefab("LayerLv50"), GameObject.Find("Canvas").transform)
	    if layerLv50 then
	    	layerLv50.name = "LayerLv50"
	    end

	    if MainModel.UserInfo and MainModel.UserInfo.user_id then
	    	if ns[2] == "Login" then
				AudioManager.ChangePattern()
	        else
				AudioManager.ChangePattern("hall_" .. MainModel.UserInfo.user_id)
	        end
	    else
	    	AudioManager.ChangePattern()
	    end


	    local canvasS = GameObject.Find("Canvas").transform:GetComponent("CanvasScaler")
	    if canvasS then
	    	local width = Screen.width
	    	local height = Screen.height
	    	if width / height < 1 then
				width,height = height,width
				canvasS.referenceResolution = {x = 1080,y = 2340}
	    	end
		    canvasS.matchWidthOrHeight = MainLogic.GetScene_MatchWidthOrHeight(width, height)
	    else
	    	print("<color=red>适配策略 Error</color>")
		end

	    local needR = "Game." .. sceneName .. ".Lua.".. ns[2] .. "Logic"
	    package.loaded[needR] = nil
	    MainModel.CurrLogic = require (needR)
	    MainModel.CurrLogic.Init(this.parm)

	    MainLogic.EnterScene()
	    if this.cbk then
	    	this.cbk()
	    	this.cbk = nil
	    end

	end)
end
function LodingLogic.Exit()
	if this then
		lodingModel.Exit()
		
		this = nil
	end
end
