local rs = game:GetService("RunService")
local VFXSystem = {}
local Settings = require(script.Settings)

if rs:IsServer() then
	VFXSystem = require(script.VFXServer)
else
	VFXSystem = require(script.VFXClient)
end

VFXSystem = VFXSystem.new()
-- tải các VFX đặc đăng ký
for _, ins in pairs(script.VFXs:GetDescendants()) do
    if ins:IsA"ModuleScript" then
        task.spawn(VFXSystem.RegisterModule, VFXSystem, ins)
    end
end
return VFXSystem
