export type VFXClient = {
    ClassName:string,
    VFXs:{},
    Remotes:{},

    _rms:{RemoteEvent},
    _frm:Folder,
    _mainRm:RemoteEvent
}

export type RemoteTable = {
    Remote:RemoteEvent,
    VFXs:{},

    _cn:RBXScriptSignal
}

export type VFXData = {
    ClassName:string,
    Position:Vector3,
    --...
}

local rs = game:GetService'RunService'
local d = game:GetService'Debris'
local ts = game:GetService'TweenService'
local p = game:GetService'Players'

local plr = p.LocalPlayer
local cam = workspace.CurrentCamera
local Settings = require(script.Parent.Settings)

local VFXClient:VFXClient = {}
VFXClient.__index = VFXClient
VFXClient.ClassName = "VFXClient"
VFXClient.VFXs = {}
VFXClient.Remotes = {}
VFXClient._rms = {}::{RemoteEvent}
VFXClient._frm = script.Parent:WaitForChild("Remotes")::Folder
-- kết nối đến Remote Signal chính
VFXClient._rms[1] = VFXClient._frm:WaitForChild("_mainRm")
VFXClient._mainRm = VFXClient._rms[1]
--/constructors
function VFXClient.new()
    local self = {}
    -- đăng ký kết nối
    self = setmetatable(self, VFXClient)
    self:RegisterRemotes()
    return self
end
--/methods
-- tạo mô phỏng vfx
function VFXClient:Render(vfxData:VFXData)
    local vfx = self.VFXs[vfxData.ClassName]
    assert(vfx ~= nil, "VFX's not found or unregister!")
    vfx:Make(vfxData)
    return vfx
end
-- tạo vfx và gửi đi dữ liệu
function VFXClient:Make(vfxData:VFXData)
    -- tự động hóa Position theo plr cam
    vfxData.Position = vfxData.Position or cam.CFrame.Position
    local vfx = self.VFXs[vfxData.ClassName]
    assert(vfx ~= nil, "VFX's not found or unregister!")
    -- gửi dữ liệu đi
    for _, rme:RemoteEvent in pairs(vfx._remotes or {}) do
        rme:FireServer(vfxData)
    end
    self:Render(vfxData)
end
-- đăng ký kết nối Remote để render VFX ở client
function VFXClient:RegisterRemote(rme:RemoteEvent)
    local rtb:RemoteTable = {
        Remote = rme,
        VFXs = {}
    }
    self.Remotes[rme] = rtb
    return rtb
end
function VFXClient:RegisterRemotes()
    for _, rme:RemoteEvent in pairs(self._frm:GetChildren()) do
        self:RegisterRemote(rme)
    end
end
-- gắn VFX vào kết nối Remote
function VFXClient:BindTo(vfx, rme:RemoteEvent)
    local rtb:RemoteTable = self.Remotes[rme]
    if not rtb then rtb = self:RegisterRemote(rme) end
    -- ghi nhớ một kết nối đến VFX
    if not vfx._remotes then vfx._remotes = {} end
    if not table.find(vfx._remotes, rme) then table.insert(vfx._remotes, rme) end
    if rtb._cn and rtb._cn.Connected then return end
    rtb._cn = rtb.Remote.OnClientEvent:Connect(function(vfxData:VFXData)
        -- bỏ qua nếu khoảng cách vượt ngưỡng render
        local distance = (cam.CFrame.Position - vfxData.Position).Magnitude
        if distance > Settings.RenderDistance then return end
        self:Render(vfxData)
    end)
end
-- đăng ký - tải trước VFX
function VFXClient:RegisterModule(mod:ModuleScript)
    local vfx = require(mod)
    self.VFXs[mod.Name] = vfx
    self:BindTo(vfx, self._mainRm)
    return vfx
end

return VFXClient