--/settings
export type VFXSettings = {
    RenderDistance:number, -- khoảng cách mô phỏng VFX
    ServerRender:boolean, -- xác định server mô phỏng vfx thay thế cho fire dữ liệu
}
--/main
export type VFXClient = {
    ClassName:string,
    VFXs:{},
    Remotes:{},

    _rms:{RemoteEvent},
    _frm:Folder,
    _mainRm:RemoteEvent
}

export type VFXServer = VFXClient
export type VFXSystem = VFXClient
--/untils
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


return true