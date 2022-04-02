-- 创建时间:2021-06-04
-- Panel:SysSettingView
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- AudioManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SysSettingView = basefunc.class()
local C = SysSettingView
C.name = "SysSettingView"


local instance
function C.Create()
	if instance == nil then
		instance = C.New()
	end
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddListener()
    for proto_name,func in pairs(self.listener) do
        Event.AddListener(proto_name, func, true)
    end
end

function C:MakeListener()
    self.listener = {}
    self.listener["player_quit_succeed"] = basefunc.handler(self, self.ExitGame)
	self.listener["ExitScene"] = basefunc.handler(self,self.onExitScene)
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
	instance = nil
	clear_table(self)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	-- add by ryx
	--现在改为用Lua实现的GeneratingVar
	basefunc.GeneratingVar(self.transform, self)
	
	self:MakeListener()
	self:AddListener()
	self:InitUI()
end

local function MakeTog(togObj, togSli)
	local tog = {}
	tog.isOn = false
	tog.openImg = togObj.transform:Find("open_img"):GetComponent("Image")
	tog.closeImg = togObj.transform:Find("close_img"):GetComponent("Image")
	tog.slider = togSli
	tog.openTog = function()
		tog.openImg.enabled = true
		tog.closeImg.enabled = false
		tog.isOn = true
		if tog.slider and tog.slider.value == 0 then
			tog.slider.value = 1
		end
	end

	tog.closeTog = function()
		tog.openImg.enabled = false
		tog.closeImg.enabled = true
		tog.isOn = false
		if tog.slider then
			tog.slider.value = 0
		end
	end
	return tog
end

function C:InitUI()
	self.musicSlider = self.music_slider:GetComponent("Slider")
	self.soundSlider = self.sound_slider:GetComponent("Slider")

	self.musicTog = MakeTog(self.music_tog_btn, self.musicSlider)
	self.soundTog = MakeTog(self.sound_tog_btn, self.soundSlider)
	self.shakeTog = MakeTog(self.shake_tog_btn)

	self.music_tog_btn.onClick:AddListener(function()
		self:OnMusicClick()
	end)
	self.sound_tog_btn.onClick:AddListener(function()
		self:OnSoundClick()
	end)
	self.shake_tog_btn.onClick:AddListener(function()
		self:OnShakeClick()
	end)
	
	self.musicSlider.onValueChanged:AddListener(function(value)
		self:OnMusicSliderChange(value)
	end)
	self.soundSlider.onValueChanged:AddListener(function(value)
		self:OnSoundSliderChange(value)
	end)
	
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.quit_btn.onClick:AddListener(function()
		self:OnQuitClick()
	end)
	self.surrender_btn.onClick:AddListener(function()
		self:OnSurrenderClick()
	end)
	
	self:MyRefresh()
end

function C:ChangeBtnView(togView, isOpen)
	if togView.isOn == isOpen then
		return
	end
	if togView.isOn then
		togView.closeTog()
	else
		togView.openTog()
	end
end

function C:UpdateMusicBtnView()
	self:ChangeBtnView(self.musicTog, audioMgr:GetIsMusicOn(AudioManager.GetParrern()))
end

function C:UpdateSoundBtnView()
	self:ChangeBtnView(self.soundTog, audioMgr:GetIsSoundOn(AudioManager.GetParrern()))
end

function C:UpdateShakeBtnView()
	self:ChangeBtnView(self.shakeTog, audioMgr:GetIsShakeOn(AudioManager.GetParrern()))
end

function C:UpdateExitBtnView()

end

function C:OnMusicClick()
	audioMgr:SetIsMusicOn(not audioMgr:GetIsMusicOn(AudioManager.GetParrern()), AudioManager.GetParrern())
	self:UpdateMusicBtnView()
end

function C:OnSoundClick()
	audioMgr:SetIsSoundOn(not audioMgr:GetIsSoundOn(AudioManager.GetParrern()), AudioManager.GetParrern())
	self:UpdateSoundBtnView()
end

function C:OnShakeClick()
	audioMgr:SetIsShakeOn(not audioMgr:GetIsShakeOn(AudioManager.GetParrern()), AudioManager.GetParrern())
	if audioMgr:GetIsShakeOn(AudioManager.GetParrern()) then
		sdkMgr:RunVibrator(500)
	end
	self:UpdateShakeBtnView()
end

function C:OnMusicSliderChange(value)
	audioMgr:SetMusicVolume(value, AudioManager.GetParrern())
	if audioMgr:GetMusicVolume(AudioManager.GetParrern()) > 0.0001 then
		audioMgr:SetIsMusicOn(true, AudioManager.GetParrern())
		self:ChangeBtnView(self.musicTog, true)
	else
		audioMgr:SetIsMusicOn(false, AudioManager.GetParrern())
		self:ChangeBtnView(self.musicTog, false)
	end
end

function C:OnSoundSliderChange(value)
	audioMgr:SetSoundVolume(value, AudioManager.GetParrern())
	if audioMgr:GetSoundVolume(AudioManager.GetParrern()) > 0.0001 then
		audioMgr:SetIsSoundOn(true, AudioManager.GetParrern())
		self:ChangeBtnView(self.soundTog, true)
	else
		audioMgr:SetIsSoundOn(false, AudioManager.GetParrern())
		self:ChangeBtnView(self.soundTog, false)
	end
end

function C:onExitScene()
	self:MyExit()
end

--退出游戏
function C:ExitGame()
	dump("<color=white>设置面板登出游戏</color>")
	DOTweenManager.KillAllStopTween()
	DOTweenManager.KillAllExitTween()
	DOTweenManager.CloseAllSequence()

	MainLogic.Exit()
	MainLogic.Init()
	self:MyExit()
end

--退出
function C:OnQuitClick()
    Network.SendRequest("player_quit", nil, function(ret)
		if ret and ret.result~=0 then
			HintPanel.ErrorMsg(ret.result)
		else
			self.ExitGame()
		end
	end)
end

function C:on_player_quit_response(ret)
	dump(ret, "<color=red>player_quit</color>")
	dump(ret, "<color=red>player_quit</color>")
end

--投降
function C:OnSurrenderClick()
	-- if DriveModel.data.map_data then
	-- 	HintPanel.Create({show_yes_btn = true, show_close_btn = true, msg = "确定要投降吗？", yes_callback = function()
	-- 		DriveModel.SendRequest("pvp_surrender_game", nil, function(data)
	-- 			dump(data)
	-- 		end)
	-- 	end})
	-- else
	-- 	TipsShowUpText.Create("游戏尚未开始！")
	-- end
end

function C:MyRefresh()
	self:UpdateMusicBtnView()
	self:UpdateSoundBtnView()
	self:UpdateShakeBtnView()
	self.musicSlider.value = audioMgr:GetMusicVolume(AudioManager.GetParrern())
	self.soundSlider.value = audioMgr:GetSoundVolume(AudioManager.GetParrern())
end