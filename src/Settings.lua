export type VFXSettings = {
    RenderDistance:number, -- khoảng cách mô phỏng VFX
    ServerRender:boolean, -- xác định server mô phỏng vfx thay thế cho fire dữ liệu
}

local Settings:VFXSettings = {
    RenderDistance = 512,
    ServerRender = true
}

return Settings