-- 创建时间:2021-01-21
-- 技能动画效果类：位置交换
local basefunc = require "Game/Common/basefunc"

SkillExchangeCar = basefunc.class(SkillBase)

local C = SkillExchangeCar
function C.Create(skill_data)
    return C.New(skill_data)
end

function C:ctor(skill_data)
    SkillExchangeCar.super.ctor(self,skill_data)
end

function C:SetObjCheckFunc()
    if self.obj_check_func then return end
    self.obj_check_func = function(v)
        if v.obj_car_exchange_pos then
            return true
        end
    end
end

function C:OnTriggerBefore()
    local obj_datas = self:GetObjs()
    for k,v in ipairs(obj_datas) do 
        if v.obj_car_exchange_pos then
            self:PlayObjData(v)
            self.launcher_car = DriveCarManager.GetCarByNo(v.obj_car_exchange_pos.car_no)
            self.effecter_car = DriveCarManager.GetCarByNo(v.obj_car_exchange_pos.exchange_car_no)
        end
    end
    self:OnTriggerMain()
end

function C:OnTriggerMain()
        --交换位置动画
        set_sorting_layer(self.launcher_car.transform,"3DMiddle_front")
        set_sorting_layer(self.effecter_car.transform,"3DMiddle_front")
        self.bg_fx = newObject("df_car_exchange_bg",GameObject.Find("3DNode").transform)
        local luancher_material = self.launcher_car:GetCurrentFbxMaterial()
        self.launcher_car:SetFbxMaterial("gaoliang")
        local effeceter_material = self.launcher_car:GetCurrentFbxMaterial()
        self.effecter_car:SetFbxMaterial("gaoliang")
        local launcher_circle = DrivePlayerManager.GetShowAttribute(self.launcher_car.car_data.seat_num,self.launcher_car.car_data.car_id,"circle")
        local effecter_circle = DrivePlayerManager.GetShowAttribute(self.effecter_car.car_data.seat_num,self.effecter_car.car_data.car_id,"circle")
        local attr_pre_1
        local attr_pre_2
        self.thunder = newObject("quanshuzhuanhuanqi",GameObject.Find("3DNode").transform)
        self.thunder.gameObject:SetActive(false)
        local launcher_thunder_node = self.thunder.transform:Find("1")
        local effecter_thunder_node = self.thunder.transform:Find("2")
        launcher_thunder_node.transform:SetParent(self.launcher_car.transform)
        effecter_thunder_node.transform:SetParent(self.effecter_car.transform)
        launcher_thunder_node.transform.localPosition = Vector3.New(0,0,-0.5)
        effecter_thunder_node.transform.position = launcher_thunder_node.transform.position
        self.thunder.gameObject:SetActive(true)
        local seq = DoTweenSequence.Create()
        seq:AppendCallback(function()
            DriveEffectManager.SetLight({weather = "night"})
            AudioManager.PlaySound(audio_config.drive.com_main_map_weizhijiaohuan.audio_name)
        end)
        local skill_name_node = self.bg_fx.transform:Find("skill_name_img").transform
        local jump_time = DriveModel.GetTime(DriveModel.time.exchange_car_title_scale)
        seq:Append(effecter_thunder_node.transform:DOMove(self.effecter_car.transform.position,DriveModel.GetTime(DriveModel.time.exchange_car_thunder_move_time)))
        -- seq:Append(skill_name_node:DOScale(Vector3.New(2.5,2.5,1),jump_time/3))
        -- seq:Join(skill_name_node:GetComponent("CanvasGroup"):DOFade(1,DriveModel.GetTime(DriveModel.time.exchange_car_title_scale)/5))
        -- seq:Append(skill_name_node:DOScale(Vector3.New(2,2,1),jump_time * 2/3))
        local ex_change_pre_1 = newObject("quanshu_xiaoguo",GameObject.Find("Canvas/LayerLv4").transform)
        local ex_change_pre_2 = newObject("quanshu_xiaoguo",GameObject.Find("Canvas/LayerLv4").transform)
        ex_change_pre_1.transform.localPosition = self.launcher_car:GetUICenterPosition()
        ex_change_pre_2.transform.localPosition = self.effecter_car:GetUICenterPosition()
        local ex_change_pre_3 = newObject("chuansong",GameObject.Find("Canvas/LayerLv4").transform)
        local ex_change_pre_4 = newObject("chuansong",GameObject.Find("Canvas/LayerLv4").transform)
        ex_change_pre_3.transform.localPosition = self.launcher_car:GetUICenterPosition()
        ex_change_pre_4.transform.localPosition = self.effecter_car:GetUICenterPosition()
        ex_change_pre_1.transform:Find("shandianshoushen").gameObject:SetActive(true)
        ex_change_pre_2.transform:Find("shandianshoushen").gameObject:SetActive(true)
        ex_change_pre_1.transform:Find("baokaishandian").gameObject:SetActive(false)
        ex_change_pre_2.transform:Find("baokaishandian").gameObject:SetActive(false)
        ex_change_pre_3.gameObject:SetActive(false)
        ex_change_pre_4.gameObject:SetActive(false)
        local launcher_pos = self.launcher_car.transform.position
        local effecter_pos = self.effecter_car.transform.position
        local launcher_rotate = self.launcher_car.car.transform.rotation
        local effecter_rotate = self.effecter_car.car.transform.rotation
        local hight = 1
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            ex_change_pre_1.transform:Find("shandianshoushen").gameObject:SetActive(false)
            ex_change_pre_2.transform:Find("shandianshoushen").gameObject:SetActive(false)
        end)
        local center_y = (self.launcher_car.transform.position.y + self.effecter_car.transform.position.y)/2
        seq:AppendCallback(function()
            local _seq = DoTweenSequence.Create()
            _seq:Append(self.launcher_car.transform:DOMove(Vector3.New(0,center_y + 2,-2),1):SetEase(Enum.Ease.InQuad))
            -- _seq:Join(self.launcher_car.car.transform:DOShakePosition(1,Vector3.New(0.5,0.5,0),4,90,false,false):SetEase(Enum.Ease.Linear))
            _seq:Append(self.launcher_car.transform:DOMove(effecter_pos,1):SetEase(Enum.Ease.OutQuad))
            -- _seq:Join(self.launcher_car.car.transform:DOShakePosition(1,Vector3.New(0.5,0.5,0),4,90,false,true):SetEase(Enum.Ease.Linear))
            _seq:Insert(0,self.launcher_car.car.transform:DOLocalRotateQuaternion(effecter_rotate,2):SetEase(Enum.Ease.InOutQuad))
        end)
        -- seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            local _seq = DoTweenSequence.Create()
            _seq:Append(self.effecter_car.transform:DOMove(Vector3.New(0,center_y - 2,-2),1):SetEase(Enum.Ease.InQuad))
            -- _seq:Join(self.effecter_car.car.transform:DOShakePosition(1,Vector3.New(0.5,0.5,0),4,90,false,false):SetEase(Enum.Ease.Linear))
            _seq:Append(self.effecter_car.transform:DOMove(launcher_pos,1):SetEase(Enum.Ease.OutQuad))
            -- public static Tweener DOShakePosition(this Transform target, float duration, Vector3 strength, int vibrato = 4, float randomness = 90, bool snapping = false, bool fadeOut = true);
            -- _seq:Join(self.effecter_car.car.transform:DOShakePosition(1,Vector3.New(0.5,0.5,0),4,90,false,true):SetEase(Enum.Ease.Linear))
            _seq:Insert(0,self.effecter_car.car.transform:DOLocalRotateQuaternion(launcher_rotate,2):SetEase(Enum.Ease.InOutQuad))
        end)
        seq:AppendInterval(1.5)
        seq:AppendCallback(function ()
            attr_pre_1 = DriveAnimManager.PlayNewAttributeChangeFx("df_car_exchange_circle","com_img_quan",launcher_circle,true,Vector3.New(self.launcher_car:GetCenterPosition().x,self.launcher_car:GetUICenterPosition().y + 30,0),nil,nil,true,2)
            attr_pre_2 = DriveAnimManager.PlayNewAttributeChangeFx("df_car_exchange_circle","com_img_quan",effecter_circle,true,Vector3.New(self.effecter_car:GetCenterPosition().x,self.effecter_car:GetUICenterPosition().y + 30,0),nil,nil,true,2)
            -- ex_change_pre_1.transform:Find("shandianshoushen").gameObject:SetActive(true)
            -- ex_change_pre_2.transform:Find("shandianshoushen").gameObject:SetActive(true)
        end)
        local move_time = DriveModel.GetTime(DriveModel.time.exchange_car_move_time)
        seq:AppendCallback(function()
            local _seq = DoTweenSequence.Create()
            _seq:AppendInterval(move_time/5)
            _seq:AppendCallback(function()
                -- ex_change_pre_3.gameObject:SetActive(true)
                -- ex_change_pre_4.gameObject:SetActive(true)
            end)
        end)
        seq:AppendInterval(0.5)
        seq:AppendCallback(function() 
            ex_change_pre_1.transform:Find("baokaishandian").gameObject:SetActive(true)
            ex_change_pre_2.transform:Find("baokaishandian").gameObject:SetActive(true)
            local temp = self.launcher_car.car_data.pos
            self.launcher_car.car_data.pos = self.effecter_car.car_data.pos
            self.effecter_car.car_data.pos = temp
            self.launcher_car:RefreshTransform()
            self.effecter_car:RefreshTransform()
        end)
        seq:AppendInterval(move_time/2)
        seq:Join(self.launcher_car.transform:DOShakePosition(move_time/2,Vector3.New(0.1,0.1,0)):SetEase(Enum.Ease.Linear))
        seq:Join(self.effecter_car.transform:DOShakePosition(move_time/2,Vector3.New(0.1,0.1,0)):SetEase(Enum.Ease.Linear))
        seq:AppendCallback(function()
            destroy(self.thunder)
            destroy(ex_change_pre_1)
            destroy(ex_change_pre_2)
            destroy(ex_change_pre_3)
            destroy(ex_change_pre_4)
            destroy(attr_pre_1)
            destroy(attr_pre_2)
        end)
        seq:AppendInterval(DriveModel.GetTime(DriveModel.time.exchange_car_end_wait))
        seq:AppendCallback(function()
            DriveEffectManager.SetLight({weather = "day"})
            destroy(self.bg_fx)
            set_sorting_layer(self.launcher_car.transform,"3DMiddle_middle")
            set_sorting_layer(self.effecter_car.transform,"3DMiddle_middle")
            self.launcher_car:SetFbxMaterial(luancher_material)
            self.effecter_car:SetFbxMaterial(effeceter_material)
            self:OnTriggerEnd()
        end)
end

function C:ExchangeMoveAnim(car,target_pos,cbk)
end

function C:OnTriggerEnd()
    self:OnActEnd()
end