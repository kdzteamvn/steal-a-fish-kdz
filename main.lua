-- Roblox Tycoon Auto Check Script
-- Tự động kiểm tra thời gian base, ESP, noclip và tăng tốc độ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Biến toàn cục
local ESP_FOLDER = Instance.new("Folder")
ESP_FOLDER.Name = "ESP_FOLDER"
ESP_FOLDER.Parent = PlayerGui

local isNoclipEnabled = true
local originalSpeed = 16
local currentSpeed = 50

-- Hàm tạo ESP Text
local function createESPText(position, text, color)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_GUI"
    screenGui.Parent = ESP_FOLDER
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color or Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = screenGui
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local camera = workspace.CurrentCamera
        if camera and position then
            local screenPoint, onScreen = camera:WorldToScreenPoint(position)
            if onScreen then
                textLabel.Position = UDim2.new(0, screenPoint.X - 100, 0, screenPoint.Y - 25)
                textLabel.Visible = true
            else
                textLabel.Visible = false
            end
        else
            textLabel.Visible = false
        end
    end)
    
    -- Cleanup khi ESP bị xóa
    local cleanupConnection
    cleanupConnection = ESP_FOLDER.ChildRemoved:Connect(function(child)
        if child == screenGui then
            connection:Disconnect()
            cleanupConnection:Disconnect()
        end
    end)
    
    return screenGui
end

-- Hàm kiểm tra thời gian của một tycoon
local function checkTycoonTime(tycoonNumber)
    local tycoon = workspace.Map.Tycoons:FindFirstChild("Tycoon" .. tycoonNumber)
    if not tycoon then return nil end
    
    -- Kiểm tra username trước
    local boardPath = tycoon:FindFirstChild("Tycoon")
    if not boardPath then return nil end
    
    local board = boardPath:FindFirstChild("Board")
    if not board then return nil end
    
    local boardPart = board:FindFirstChild("Board")
    if not boardPart then return nil end
    
    local surfaceGui = boardPart:FindFirstChild("SurfaceGui")
    if not surfaceGui then return nil end
    
    local username = surfaceGui:FindFirstChild("Username")
    if not username then return nil end
    
    -- Kiểm tra xem có player trong base không
    if username.Text == "No Owner!" then
        return "NO PLAYER IN BASE"
    end
    
    -- Nếu có player, kiểm tra thời gian
    local forceFieldFolder = boardPath:FindFirstChild("ForcefieldFolder")
    if not forceFieldFolder then return nil end
    
    local screen = forceFieldFolder:FindFirstChild("Screen")
    if not screen then return nil end
    
    local screenPart = screen:FindFirstChild("Screen")
    if not screenPart then return nil end
    
    local screenSurfaceGui = screenPart:FindFirstChild("SurfaceGui")
    if not screenSurfaceGui then return nil end
    
    local timeLabel = screenSurfaceGui:FindFirstChild("Time")
    if not timeLabel then return nil end
    
    local time = timeLabel.Text
    
    if time == "0s" then
        return "BASE IS UNLOCK"
    else
        return "TIME BASE: " .. time
    end
end

-- Hàm lấy vị trí Handle của tycoon
local function getTycoonPosition(tycoonNumber)
    local tycoon = workspace.Map.Tycoons:FindFirstChild("Tycoon" .. tycoonNumber)
    if not tycoon then return nil end
    
    local handle = tycoon:FindFirstChild("Handle")
    if not handle then return nil end
    
    -- Đặt ESP cao hơn 20 studs từ Handle
    return handle.Position + Vector3.new(0, 20, 0)
end

-- Hàm cập nhật ESP cho tất cả tycoon
local function updateESP()
    -- Xóa ESP cũ
    for _, child in pairs(ESP_FOLDER:GetChildren()) do
        child:Destroy()
    end
    
    -- Tạo ESP mới cho từng tycoon
    for i = 1, 8 do
        local position = getTycoonPosition(i)
        if position then
            local status = checkTycoonTime(i)
            if status then
                local color = Color3.new(1, 1, 1) -- Màu trắng mặc định
                
                if status == "NO PLAYER IN BASE" then
                    color = Color3.new(1, 0.5, 0.5) -- Màu đỏ nhạt
                elseif status == "BASE IS UNLOCK" then
                    color = Color3.new(0.5, 1, 0.5) -- Màu xanh lá
                else
                    color = Color3.new(1, 1, 0.5) -- Màu vàng
                end
                
                createESPText(position, "TYCOON " .. i .. "\n" .. status, color)
            end
        end
    end
end

-- Hàm thiết lập Noclip
local function setupNoclip()
    if not LocalPlayer.Character then return end
    
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    
    if humanoid then
        -- Thiết lập tốc độ di chuyển
        humanoid.WalkSpeed = 50
        
        -- Thiết lập noclip
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Bật noclip cho phần mới được thêm vào
        character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                descendant.CanCollide = false
            end
        end)
    end
end

-- Hàm chính
local function main()
    print("=== ROBLOX TYCOON AUTO CHECK SCRIPT STARTED ===")
    print("- ESP sẽ hiển thị thông tin thời gian của từng base")
    print("- Noclip và tốc độ 50 đã được bật")
    print("- Script sẽ tự động cập nhật thông tin")
    
    -- Thiết lập noclip khi spawn
    if LocalPlayer.Character then
        setupNoclip()
    end
    
    -- Thiết lập noclip khi respawn
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1) -- Đợi character load hoàn toàn
        setupNoclip()
    end)
    
    -- Cập nhật ESP liên tục
    local espUpdateConnection = RunService.Heartbeat:Connect(function()
        updateESP()
    end)
    
    -- Duy trì noclip liên tục
    local noclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character and isNoclipEnabled then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    -- Cleanup khi player rời game
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            espUpdateConnection:Disconnect()
            noclipConnection:Disconnect()
        end
    end)
end

-- Khởi chương trình
spawn(function()
    main()
end)

-- Thiết lập noclip ngay lập tức nếu character đã có
if LocalPlayer.Character then
    setupNoclip()
end
