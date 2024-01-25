local IVFX = {}
IVFX.__index = IVFX
IVFX.ClassName = 'IVFX'
--/constructors
function IVFX.new()
    return setmetatable({}, IVFX)
end
--overwrite
function IVFX:Make(vfxData)
    error("Overwrite method Make of IVFX!")
end

return IVFX