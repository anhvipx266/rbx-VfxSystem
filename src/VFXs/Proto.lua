--[[
    -- mô tả về VFX
]]
-- định nghĩa dữ liệu VFX
export type VFXData = {
   
 }
local Proto = {}
Proto.__index = Proto
Proto.ClassName = 'Proto'
--/constructors
function Proto.new()
    return setmetatable({}, Proto)
end
--overwrite
function Proto:Make(vfxData)
    -- TODO: cấu hình tạo VFX ở đây
end

return Proto