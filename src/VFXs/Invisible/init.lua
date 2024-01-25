--[[
    -- làm vô hình Model trong một đơn vị thời gian, có thể hủy giữa chừng
    -- hỗ trợ cho Transparency
]]
-- định nghĩa dữ liệu VFX
export type VFXData = {
   Model:Model,
   Invisible:boolean, -- xác định có vô hình hay không
   Time:number, -- thời gian vô hình nếu có
   Fade:boolean,
   FadeTime:number,
   FadeStyle:string
}

export type Status = {
    Last:number,
    OriginTransparency:{[BasePart]:number},
    InAnimate:{[BasePart]:Tween}, -- hoạt ảnh vô hình
    OutAnimate:{[BasePart]:Tween}, -- hoạt ảnh trở lại bình thường
    Invisible:boolean,
    InClear:boolean
}
local tw = game:GetService'TweenService'

local fade = script:GetAttribute("Fade")
local info = TweenInfo.new(script:GetAttribute("FadeTime"), Enum.EasingStyle[script:GetAttribute("FadeStyle")])

local CLEAR_TIME = 5 * 60

local Invisible = {}
Invisible.__index = Invisible
Invisible.ClassName = 'Invisible'
Invisible.Status = {}::{[Model]:Status}
function checkProp(object:Instance, propName)
    object[propName] = object[propName]
end

function hasProp(object, propName)
    local success, _ = pcall(checkProp, object, propName)
    return success
end
--/constructors
function Invisible.new()
    return setmetatable({}, Invisible)
end
-- làm vô hình Model
function Invisible:Make(vfxData:VFXData)
    vfxData.Time = vfxData.Time or 3
    vfxData.Invisible = if vfxData.Invisible ~= nil then vfxData.Invisible else true
    local status = self.Status[vfxData.Model]
    if status then
        -- kéo dài thêm thời gian
        if vfxData.Invisible then
            if status.Invisible then
                status.Last = tick() - vfxData.Time
            else
                -- tạo mới Status
                self:Create(vfxData)
            end
        else
            -- phục hồi và xóa bỏ
            if status.Invisible then
                self:Clear(vfxData)
            end
        end
    else
        -- tạo mới Status
        self:Create(vfxData)
    end
end
-- tạo mới Trạng thái vô hình
function Invisible:Create(vfxData:VFXData)
    local status:Status = {
        Invisible = true,
        OriginTransparency = {},
        OutAnimate = {},
        InAnimate = {},
        Last = tick()
    }
    self.Status[vfxData.Model] = status
    -- ghi đè thông tin Fade
    fade = if vfxData.Fade ~= nil then vfxData.Fade else fade
    if vfxData.Fade then
        info = TweenInfo.new(vfxData.FadeTime, Enum.EasingStyle[vfxData.FadeStyle or 'Quad'])
    end
    -- quét qua tất cả part và làm mờ
    for _, part:BasePart in pairs(vfxData.Model:GetDescendants()) do
        if not hasProp(part, 'Transparency') then continue end
        status.OriginTransparency[part] = part.Transparency
        -- vô hình
        if fade then
            -- animate
            local animate = status.InAnimate[part]
            if not animate then
                animate = tw:Create(part, info, {
                    Transparency = 1
                })
                status.InAnimate[part] = animate
            end
            if status.OutAnimate[part] then status.OutAnimate[part]:Pause() end
            animate:Play()
        else
            part.Transparency = 1
        end
    end
    -- loại bỏ sau thời gian
    self:Remove(vfxData)
end
-- luồng loại bỏ trạng thái nếu không phải INF
function Invisible:Remove(vfxData:VFXData)
    local status = self.Status[vfxData.Model]
    if vfxData.Time == 'INF' then return end
    -- loại bỏ trạng thái
    if tick() - status.Last > vfxData.Time then
        self:Clear(vfxData)
        return
    end
    -- tiếp tục loại bỏ sau tg
    task.delay(vfxData.Time - (tick() - status.Last), self.Remove, self, vfxData)
end
-- phục hồi và làm sạch trạng thái vô hình
function Invisible:Clear(vfxData:VFXData)
    local status = self.Status[vfxData.Model]
    status.Invisible = false
    -- ghi đè thông tin Fade
    fade = if vfxData.Fade ~= nil then vfxData.Fade else fade
    if vfxData.Fade then
        info = TweenInfo.new(vfxData.FadeTime, Enum.EasingStyle[vfxData.FadeStyle or 'Quad'])
    end
    for part:BasePart, trans in pairs(status.OriginTransparency) do
        if fade then
            -- animate
            local animate = status.OutAnimate[part]
            if not animate then
                animate = tw:Create(part, info, {
                    Transparency = trans
                })
                status.OutAnimate[part] = animate
            end
            if status.InAnimate[part] then status.InAnimate[part]:Pause() end
            animate:Play()
        else
            part.Transparency = trans
        end
    end
    -- làm sạch sau 5 phút
    self:_Clear(vfxData)
end
-- làm sạch sau 5 phút khi không dùng tới
function Invisible:_Clear(vfxData)
    local status = self.Status[vfxData.Model]
    if status.InClear then return end
    status.InClear = true
    -- làm sạch Trạng thái
    if tick() - status.Last > CLEAR_TIME then
        self.Status[vfxData.Model] = nil
        return
    end
    -- tiếp tục làm sạch sau tg
    task.delay(CLEAR_TIME - (tick() - status.Last), self._Clear, self, vfxData)
end

return Invisible