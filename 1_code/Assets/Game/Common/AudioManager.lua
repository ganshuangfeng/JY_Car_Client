-- 创建时间:2018-12-25

AudioManager = {}

local M = AudioManager

local audio_pattern

function M.Init()
	M.lastAudioName = nil
	M.oldAudioName = nil
	M.SoundOnOff = true
end
-- 播放场景背景音乐
function M.PlaySceneBGM(audioName, isCoerce)
	if not M.SoundOnOff then return end
	if not M.lastAudioName then
		audioMgr:PlayBGM(audioName, audio_pattern)
		M.lastAudioName = audioName
		M.oldAudioName = audioName
	else
		M.oldAudioName = M.lastAudioName
		if isCoerce then
			audioMgr:PlayBGM(audioName, audio_pattern)
			M.lastAudioName = audioName
		else
			if M.lastAudioName ~= audioName then
				audioMgr:PlayBGM(audioName, audio_pattern)
				M.lastAudioName = audioName
			end
		end
	end
end

function M.PlayOldBGM()
	if not M.SoundOnOff then return end
	if not M.oldAudioName then
		audioMgr:PlayBGM(audio_config.game.bgm_main_hall.audio_name, audio_pattern)
		M.lastAudioName = audio_config.game.bgm_main_hall.audio_name
		M.oldAudioName = M.lastAudioName
	else
		audioMgr:PlayBGM(M.oldAudioName, audio_pattern)
		M.lastAudioName = M.oldAudioName
		M.oldAudioName = M.lastAudioName
	end
end

function M.PlayLastBGM()
	if not M.SoundOnOff then return end
	if not M.lastAudioName then
		audioMgr:PlayBGM(audio_config.game.bgm_main_hall.audio_name, audio_pattern)
		M.lastAudioName = audio_config.game.bgm_main_hall.audio_name
		M.oldAudioName = M.lastAudioName
	else
		audioMgr:PlayBGM(M.lastAudioName, audio_pattern)
		M.lastAudioName = M.lastAudioName
		M.oldAudioName = M.lastAudioName
	end
end

-- 暂停场景背景音乐
function M.PauseSceneBGM()
	audioMgr:PauseBG()
	M.lastAudioName = nil
end

-- 播放音效
function M.PlaySound(audioName, loopNum, call)
	if not M.SoundOnOff then return end
	if audioName then
		loopNum = loopNum or 1
		return audioMgr:PlaySound(audioName, loopNum, call, audio_pattern)
	end
end
-- 播放音效
function M.CloseSound(audio_key)
	if audio_key then
		audioMgr:CloseLoopSound(audio_key)
	end
	return
end

function M.GetOldAudioName()
	return M.oldAudioName
end

function M.ChangePattern(pattern)
	audio_pattern = pattern
end

function M.GetParrern()
	return audio_pattern
end