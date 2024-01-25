## VFX System
- Là một hệ thống quản lý, tạo, lưu trữ hiệu ứng VFX hoặc thành phần hiệu ứng không tham gia vào logic game.

## Sử dụng
- Tạo các VFX Class(nên kế thừa IVFX và lấy mẫu từ Proto) và đặt trong VFXs Folder
- VFX trong Folder VFXs tự động được đăng ký
```lua
-- client
VFXSystem:Make({
    ClassName = "VFX ClassName",
    Position = Vector3.new(), -- chỉ định cụ thể hoặc mặc định Camera Position
    --... -- dữ liệu kèm theo của VFX
})
```
```lua
-- server
VFXSystem:Make({
    ClassName = "VFX ClassName",
    Position = Vector3.new(), -- bắt buộc chỉ định cụ thể
    --... -- dữ liệu kèm theo của VFX
})
```
## Cài đặt - Settings
```lua
export type VFXSettings = {
    RenderDistance:number, -- khoảng cách mô phỏng VFX
    ServerRender:boolean, -- xác định server mô phỏng vfx thay thế cho fire dữ liệu
}
```