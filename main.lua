local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local espObjects = {}

-- Hàm tạo ESP Text
local function createESPText(position, text, color)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0) -- Đặt cao lên như yêu cầu
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = workspace.CurrentCamera

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.Parent = billboardGui

    -- Tạo attachment để gắn BillboardGui
    local attachment = Instance.new("Attachment")
    attachment.Parent = workspace.Terrain
    attachment.WorldPosition = position
    billboardGui.Adornee = attachment

    return {
        billboard = billboardGui,
        attachment = attachment,
        textLabel = textLabel
    }
end

-- Hàm cập nhật ESP cho một tycoon
local function updateESP(tycoonNumber)
    local tycoonName = "Tycoon" .. tycoonNumber
    
    -- Xóa ESP cũ nếu có
    if espObjects[tycoonNumber] then
        if espObjects[tycoonNumber].billboard then
            espObjects[tycoonNumber].billboard:Destroy()
        end
        if espObjects[tycoonNumber].attachment then
            espObjects[tycoonNumber].attachment:Destroy()
        end
        espObjects[tycoonNumber] = nil
    end

    -- Path để check username
    local usernamePath = workspace.Map.Tycoons[tycoonName].Tycoon.Board.Board.SurfaceGui.Username
    -- Path để check thời gian
    local timePath = workspace.Map.Tycoons[tycoonName].Tycoon.ForcefieldFolder.Screen.Screen.SurfaceGui.Time
    -- Path để lấy vị trí Handle
    local handlePath = workspace.Map.Tycoons[tycoonName].Tycoon.ForcefieldFolder.Screen

    -- Kiểm tra xem các path có tồn tại không
    if not usernamePath or not timePath or not handlePath then
        return
    end

    -- Kiểm tra có người ở trong base không
    if usernamePath.Text == "No Owner!" then
        -- Tạo ESP hiển thị "NO PLAYER IN BASE"
        local espObject = createESPText(
            handlePath.Position + Vector3.new(0, 5, 0),
            "NO PLAYER IN BASE",
            Color3.new(1, 0.5, 0) -- Màu cam
        )
        espObjects[tycoonNumber] = espObject
        return
    end

    -- Kiểm tra thời gian
    local timeText = timePath.Text
    local espText = ""
    local color = Color3.new(0, 1, 0) -- Mặc định màu xanh lá

    if timeText == "0s" then
        espText = "BASE IS UNLOCK"
        color = Color3.new(0, 1, 0) -- Màu xanh lá
    else
        espText = "TIME BASE: " .. timeText
        color = Color3.new(1, 0, 0) -- Màu đỏ
    end

    -- Tạo ESP mới
    local espObject = createESPText(
        handlePath.Position + Vector3.new(0, 5, 0),
        espText,
        color
    )
    espObjects[tycoonNumber] = espObject
end

-- Hàm chính để cập nhật tất cả ESP
local function updateAllESP()
    for i = 1, 8 do
        pcall(function()
            updateESP(i)
        end)
    end
end

-- Hàm thiết lập Noclip
local function enableNoclip()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end

-- Hàm thiết lập WalkSpeed
local function setWalkSpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 10
        end
    end
end

-- Hàm xử lý khi player spawn
local function onCharacterAdded(character)
    wait(1) -- Chờ character load xong
    
    -- Thiết lập WalkSpeed
    setWalkSpeed()
    
    -- Thiết lập Noclip liên tục
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if character.Parent then
            enableNoclip()
        else
            connection:Disconnect()
        end
    end)
end

-- Kết nối sự kiện
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Bắt đầu chạy ESP update loop
spawn(function()
    while true do
        updateAllESP()
        wait(1) -- Cập nhật mỗi giây
    end
end)

-- Thông báo script đã load
print("Auto Check Time & ESP Script loaded successfully!")
print("Features:")
print("- Auto check time for all tycoons (1-8)")
print("- ESP text display for each base")
print("- Noclip enabled")
print("- Walkspeed set to 10")
