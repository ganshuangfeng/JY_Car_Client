-- 创建时间:2021-05-10
-- 技能动画效果类：小型导弹
local basefunc = require "Game/Common/basefunc"

SkillSmallRocket = basefunc.class(SkillBase)

local C = SkillSmallRocket

function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillSmallRocket.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if (v.obj_car_modify_property and (v.obj_car_modify_property.modify_key_name == "hp" or v.obj_car_modify_property.modify_key_name == "hd")) then
            return true
        end
    end
end

function C:OnTriggerBefore()
    self.skill_node = DriveMapManager.GetMapPrefabByRoadID(self.skill_data.pos,true).transform:Find("skill_node")
    DriveAnimManager.PlayNewAttributeChangeFx("normal_art_font_fx","com_img_xxdd_map3","",true,self.launcher_car:GetCenterPosition(),function()
        if self.skill_node and self.skill_node.transform:Find("RoadAwardNormal") then
            self.skill_node.transform:Find("RoadAwardNormal").gameObject:SetActive(false)
        end
        self:OnTriggerMain()
    end,true)
end

function C:CreateSmallRocketMove(cbk)
    local skill_small_rocket_fx = newObject("skill_small_rocket_fx",GameObject.Find("3DNode").transform)
    skill_small_rocket_fx.transform.position = self.skill_node.position
    local curr_pos = skill_small_rocket_fx.transform.position
    local seq = DoTweenSequence.Create()
    local target_pos = self.effecter_car.transform.position
    local max_height = curr_pos.y > target_pos.y and curr_pos.y or target_pos.y
    local top_pos = Vector3.New(curr_pos.x,max_height + 4,curr_pos.z)
    dump(target_pos,"<color=red>目标位置</color>")
    local dis = tls.pGetDistance(top_pos,target_pos) + tls.pGetDistance(top_pos,curr_pos)
    local t = dis / 6
    local dir_vec = tls.pSub(target_pos,top_pos)
    local rotation = tls.pToAngleSelf(tls.pSub(dir_vec,Vector3.New(0,1,0))) * (180 / math.pi)
    dump(rotation,"<color=red>角度++++</color>")
    seq:AppendCallback(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_xiaoxingdaodan.audio_name)
    end)
    seq:Append(
        skill_small_rocket_fx.transform:DOLocalMove(top_pos,t*3/5):SetEase(Enum.Ease.InExpo )
    )
    seq:AppendCallback(
        function()
            skill_small_rocket_fx.transform.localRotation = Quaternion:SetEuler(0,0,rotation-90)
        end
    )
    seq:Append(
        skill_small_rocket_fx.transform:DOLocalMove(target_pos,t*2/5):SetEase(Enum.Ease.InExpo )
    )
    seq:Insert(
        0,skill_small_rocket_fx.transform:DOLocalMoveZ(-5.5 * t * 0.6,3/4 * t):SetEase(Enum.Ease.InExpo )
    )
    seq:Insert(
        3/4 * t,skill_small_rocket_fx.transform:DOLocalMoveZ(0,t/4):SetEase(Enum.Ease.InExpo )
    )

    seq:OnForceKill(function()
        AudioManager.PlaySound(audio_config.drive.com_main_map_xiaoxingdaodan1.audio_name)
        destroy(skill_small_rocket_fx.gameObject)
        if cbk then cbk() end
    end)
end


-- --创建导弹并移动
-- function C:CreateSmallRocketMove(start_circle_length,cbk)
--     local skill_small_rocket_fx = newObject("skill_small_rocket_fx",GameObject.Find("3DNode").transform)
--     skill_small_rocket_fx.transform.position = self.skill_node.position
--     local seq = DoTweenSequence.Create()
--     local target_pos = self.effecter_car.transform.position
--     local half_move_time = 0.5
--     local start_angle = -90
--     --旋转圆的圆心位置(两点的连线上靠近effecter_car)
--     local center_x = (self.launcher_car.transform.position.x + self.effecter_car.transform.position.x)/2
--     local center_y = (self.launcher_car.transform.position.y + self.effecter_car.transform.position.y)/2
--     local normal_vec = tls.pNormalize(tls.pSub(self.effecter_car.transform.position,self.launcher_car.transform.position))
--     local mul = 1
--     local center_vec = tls.pSub(self.effecter_car.transform.position,tls.pMul(normal_vec,1))
--     --圆心随机值
--     local circle_center_pos = Vector3.New(center_vec.x,center_vec.y,0)
--     local end_radius = tls.pGetLength(tls.pSub(self.effecter_car.transform.position,circle_center_pos))
--     local end_angle = tls.pToAngleSelf(tls.pSub(self.effecter_car.transform.position,circle_center_pos)) * (180 / math.pi)

--     --起飞
--     --起飞点的圆心
--     local x = skill_small_rocket_fx.transform.position.x
--     local y = skill_small_rocket_fx.transform.position.y
--     local start_circle_point = GameObject.New("start_circle_point")
--     start_circle_point.transform:SetParent(GameObject.Find("3DNode").transform)
--     --起飞点的圆心在左侧
--     start_circle_point.transform.position = Vector3.New(skill_small_rocket_fx.transform.position.x + start_circle_length,skill_small_rocket_fx.transform.position.y,0)
--     --旋转的角度为起飞点的圆心和原点圆心的连线的夹角
--     start_angle = tls.pToAngleSelf(tls.pSub(start_circle_point.transform.position,circle_center_pos)) * (180 / math.pi)
--     if start_angle < 0 then
--         start_angle = start_angle + 360
--     end
--     --微调位置 进入圆的轨道
--     seq:AppendCallback(function()
--         skill_small_rocket_fx.transform:SetParent(start_circle_point.transform)
--     end)
--     seq:Append(start_circle_point.transform:DORotate(Vector3.New(0,0,start_angle),start_angle/(720 + end_angle - start_angle),Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear))
--     --原点圆心
--     local circle_point = GameObject.New("circle_point")
--     circle_point.transform:SetParent(GameObject.Find("3DNode").transform)
--     circle_point.transform.position = circle_center_pos
--     local start_radius = tls.pGetLength(tls.pSub(skill_small_rocket_fx.transform.position,circle_center_pos))
--     local lerp_vec = tls.pNormalize(tls.pSub(skill_small_rocket_fx.transform.position,circle_center_pos))
--     seq:AppendCallback(function()
--         skill_small_rocket_fx.transform:SetParent(circle_point.transform)
--         start_radius = tls.pGetLength(tls.pSub(skill_small_rocket_fx.transform.position,circle_center_pos))
--         start_angle = 90 - tls.pToAngleSelf(tls.pSub(skill_small_rocket_fx.transform.position,circle_point.transform.position)) * (180 / math.pi)
--         lerp_vec = tls.pNormalize(skill_small_rocket_fx.transform.localPosition)
--     end)
--     local get_target_vec = function(radius)
--         local ret = tls.pMul(lerp_vec,radius)
--         return Vector3.New(ret.x,ret.y,0)
--     end
--     --转动圆心，同时减小或者增加半径
--     seq:Append(circle_point.transform:DORotate(Vector3.New(0,0,end_angle - start_angle + 720),2,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear))
--     seq:Join(skill_small_rocket_fx.transform:DOLocalMove(get_target_vec(end_radius),2):SetEase(Enum.Ease.InQuad))
--     --结束
--     seq:OnForceKill(function()
--         -- destroy(circle_point.gameObject)
--         destroy(skill_small_rocket_fx.gameObject)
--         if cbk then cbk() end
--     end)

-- end

function C:OnTriggerMain()
    local seq = DoTweenSequence.Create()
    local obj_datas = self:GetObjs()
    for i,v in ipairs(obj_datas) do
        local obj_data = v[v.key]
        local modify_value = obj_data.modify_value or 0
        if obj_data.modify_key_name == "hp" or obj_data.modify_key_name =="hd" then
            seq:AppendCallback(function()
                local fx_pre
                fx_pre = newObject("daodanqidong_zhongjiang",self.skill_node.transform)
                self:CreateSmallRocketMove(function()
                    self:PlayDamageFx(obj_data)
                    self.effecter_car:PlayOnAttack(modify_value)
                    self:PlayObjData(v)
                    local boom_pre = newObject("daodanjizhong",GameObject.Find("3DNode").transform)
                    boom_pre.transform.position = Vector3.New(self.effecter_car.transform.position.x,self.effecter_car.transform.position.y,self.effecter_car.transform.position.z - 1)
                    DriveAnimManager.PlayShakeScreen(DriveModel.camera3dParent,0.5)
                    local _seq = DoTweenSequence.Create()
                    _seq:AppendInterval(0.5)
                    _seq:AppendCallback(function()
                        if i == #obj_datas then
                            if self.skill_node and self.skill_node.transform:Find("RoadAwardNormal") then
                                self.skill_node.transform:Find("RoadAwardNormal").gameObject:SetActive(true)
                            end
                            self:OnActEnd()
                        end
                    end)
                    _seq:AppendInterval(2)
                    _seq:OnForceKill(function()
                        destroy(boom_pre)
                        destroy(fx_pre)
                    end)
                end)
            end)
            seq:AppendInterval(0.5)
        end
    end
end