export type VFXServer = {
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

local Settings = require(script.Parent.Settings)

local VFXServer:VFXServer = {}
VFXServer.__index = VFXServer
VFXServer.ClassName = "VFXServer"
VFXServer.VFXs = {}
VFXServer.Remotes = {}
VFXServer._rms = {}::{RemoteEvent}
VFXServer._frm = Instance.new('Folder', script.Parent)
VFXServer._frm.Name = "Remotes"
-- tạo remote signal chính
VFXServer._rms[1] = Instance.new("RemoteEvent", VFXServer._frm)
VFXServer._rms[1].Name = "_mainRm"
VFXServer._mainRm = VFXServer._rms[1]
--/constructors
function VFXServer.new()
    local self = {}
    self = setmetatable(self, VFXServer)
    -- đăng ký xử lý kết nối vfx đến
    self:RegisterRemotes()
    return self
end
--/methods
-- tạo mô phỏng vfx
function VFXServer:Render(vfxData:VFXData)
    local vfx = self.VFXs[vfxData.ClassName]
    vfx:Make(vfxData)
    return vfx
end
-- tạo vfx và gửi đi dữ liệu
function VFXServer:Make(vfxData:VFXData)
    local vfx = self.VFXs[vfxData.ClassName]
    assert(vfx ~= nil, "VFX's not found or unregister!")
    if Settings.ServerRender then
        self:Render(vfxData)
    else
        assert(vfxData.Position ~= nil, "VFX data require Position!")
        -- gửi dữ liệu đi
        for _, rme:RemoteEvent in pairs(vfx._remotes or {}) do
            rme:FireAllClients(nil, vfxData)
        end
    end
end
-- gắn VFX vào kết nối Remote
function VFXServer:BindTo(vfx, rme:RemoteEvent)
    local rtb:RemoteTable = self.Remotes[rme]
    if not rtb then rtb = self:RegisterRemote(rme) end
    -- ghi nhớ một kết nối đến VFX
    if not vfx._remotes then vfx._remotes = {} end
    if not table.find(vfx._remotes, rme) then table.insert(vfx._remotes, rme) end
end
-- đăng ký kết nối Remote để tới để xử lý và gửi đến người chơi khác
function VFXServer:RegisterRemote(rme:RemoteEvent)
    local rtb:RemoteTable = {
        Remote = rme,
        VFXs = {}
    }
    self.Remotes[rme] = rtb
    -- đăng ký kết nối
    rtb._cn = rme.OnServerEvent:Connect(function(plr, vfxData)
        for _, _plr in pairs(p:GetPlayers()) do
             -- bỏ qua tải lại vfx của plr đầu
            if _plr == plr then continue end
            rme:FireClient(_plr, vfxData)
        end
    end)
    return rtb
end
function VFXServer:RegisterRemotes()
    for _, rme:RemoteEvent in pairs(self._frm:GetChildren()) do
        self:RegisterRemote(rme)
    end
end
-- đăng ký - tải trước VFX
function VFXServer:RegisterModule(mod:ModuleScript)
    local vfx = require(mod)
    self.VFXs[mod.Name] = vfx
    self:BindTo(vfx, self._mainRm)
    return vfx
end
return VFXServer