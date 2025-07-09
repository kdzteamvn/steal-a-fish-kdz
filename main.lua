local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChild("Humanoid")

-- KIỂM TRA GAME ID
if game.PlaceId ~= 72212564918217 then
    player:Kick("BRO? YOU SURE???")
    return
end

-- CẤU HÌNH
local ESP_HEIGHT = 10
local TEXT_SIZE = 40
local ANTI_FALL_Y = 6
local TP_WALK_SPEED = 50 -- Tốc độ dịch chuyển

-- Biến toàn cục
local ESPs = {}
local menuVisible = true
local noclipEnabled = true
local espEnabled = true
local tpWalkEnabled = true
local lastTpWalkTime = 0
local tpWalkInterval = 0.1 -- Giây giữa các lần dịch chuyển

-- Tạo menu
local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KDZHub"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    mainFrame.BorderColor3 = Color3.new(1, 1, 1)
    mainFrame.BorderSizePixel = 2
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Steal a Fish! - KDZ Hub"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = mainFrame
    
    -- Tạo các nút chức năng
    local buttons = {
        {name = "Speed", yPos = 40},
        {name = "Noclip", yPos = 80},
        {name = "ESP Base", yPos = 120},
        {name = "Anti-Fall", yPos = 160},
        {name = "Remove ForceFields", yPos = 200}
    }
    
    for _, btn in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = btn.name
        button.Text = btn.name
        button.Size = UDim2.new(0.9, 0, 0, 30)
        button.Position = UDim2.new(0.05, 0, 0, btn.yPos)
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18
        button.Parent = mainFrame
        
        -- Thiết lập trạng thái ban đầu
        if btn.name == "Speed" then
            button.Text = "Speed: ON"
            button.BackgroundColor3 = Color3.new(0, 0.5, 0)
        elseif btn.name == "Noclip" then
            button.Text = "Noclip: ON"
            button.BackgroundColor3 = Color3.new(0, 0.5, 0)
        elseif btn.name == "ESP Base" then
            button.Text = "ESP Base: ON"
            button.BackgroundColor3 = Color3.new(0, 0.5, 0)
        end
    end
    
    -- Xử lý sự kiện click cho các nút
    mainFrame.Speed.MouseButton1Click:Connect(function()
        tpWalkEnabled = not tpWalkEnabled
        mainFrame.Speed.Text = "Speed: " .. (tpWalkEnabled and "ON" or "OFF")
        mainFrame.Speed.BackgroundColor3 = tpWalkEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    end)
    
    mainFrame.Noclip.MouseButton1Click:Connect(function()
        noclipEnabled = not noclipEnabled
        mainFrame.Noclip.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
        mainFrame.Noclip.BackgroundColor3 = noclipEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    end)
    
    mainFrame["ESP Base"].MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        mainFrame["ESP Base"].Text = "ESP Base: " .. (espEnabled and "ON" or "OFF")
        mainFrame["ESP Base"].BackgroundColor3 = espEnabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        
        -- Ẩn/hiện ESP
        for _, esp in pairs(ESPs) do
            esp.Enabled = espEnabled
        end
    end)
    
    mainFrame["Anti-Fall"].MouseButton1Click:Connect(function()
        antiFall()
    end)
    
    mainFrame["Remove ForceFields"].MouseButton1Click:Connect(function()
        removeForcefields()
    end)
    
    -- Cho phép kéo menu
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    return mainFrame
end

-- Hàm setup character
local function setupCharacter(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- Chống ragdoll
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
end

-- Tạo ESP cho các nhà
local function createESP(tycoonName, position)
    if ESPs[tycoonName] then
        ESPs[tycoonName]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = tycoonName .. "_ESP"
    billboard.AlwaysOnTop = true
    billboard.Enabled = espEnabled
    billboard.Size = UDim2.new(0, 350, 0, 80)
    billboard.StudsOffset = Vector3.new(0, ESP_HEIGHT, 0)
    billboard.Adornee = position
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESPLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.7
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = TEXT_SIZE
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BorderSizePixel = 0
    textLabel.ZIndex = 10
    
    textLabel.Parent = billboard
    billboard.Parent = player:WaitForChild("PlayerGui")
    
    ESPs[tycoonName] = billboard
    return textLabel
end

-- Kiểm tra trạng thái các nhà
local function checkTycoons()
    if not espEnabled then return end
    
    for i = 1, 8 do
        local tycoonName = "Tycoon" .. i
        local tycoonPath = workspace.Map.Tycoons:FindFirstChild(tycoonName)
        
        if tycoonPath then
            local tycoonModel = tycoonPath:FindFirstChild("Tycoon")
            if tycoonModel then
                local forcefieldFolder = tycoonModel:FindFirstChild("ForcefieldFolder")
                local screen = forcefieldFolder and forcefieldFolder:FindFirstChild("Screen")
                local board = tycoonModel:FindFirstChild("Board")
                local boardGui = board and board:FindFirstChild("Board")
                local surfaceGui = boardGui and boardGui:FindFirstChild("SurfaceGui")
                local usernameLabel = surfaceGui and surfaceGui:FindFirstChild("Username")
                
                if screen and usernameLabel then
                    local espText
                    
                    if not ESPs[tycoonName] then
                        espText = createESP(tycoonName, screen.Screen)
                    else
                        espText = ESPs[tycoonName]:FindFirstChild("ESPLabel")
                    end
                    
                    if espText then
                        local timeGui = screen.Screen:FindFirstChild("SurfaceGui")
                        local timeLabel = timeGui and timeGui:FindFirstChild("Time")
                        
                        if usernameLabel.Text == "No Owner!" then
                            espText.Text = "NO PLAYER IN BASE"
                            espText.TextColor3 = Color3.new(1, 0.3, 0.3)
                        else
                            if timeLabel and timeLabel.Text == "0s" then
                                espText.Text = "BASE IS UNLOCKED"
                                espText.TextColor3 = Color3.new(0.3, 1, 0.3)
                            else
                                espText.Text = "TIME: " .. (timeLabel.Text or "N/A")
                                espText.TextColor3 = Color3.new(1, 1, 0.3)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Hàm xóa forcefield24H
local function removeForcefields()
    for i = 1, 8 do
        local tycoonName = "Tycoon" .. i
        local tycoonPath = workspace.Map.Tycoons:FindFirstChild(tycoonName)
        if tycoonPath then
            local tycoonModel = tycoonPath:FindFirstChild("Tycoon")
            if tycoonModel then
                local forcefieldFolder = tycoonModel:FindFirstChild("ForcefieldFolder")
                if forcefieldFolder then
                    local buttons = forcefieldFolder:FindFirstChild("Buttons")
                    if buttons then
                        local forceField24H = buttons:FindFirstChild("ForceField24H")
                        if forceField24H then
                            forceField24H:Destroy()
                        end
                    end
                end
            end
        end
    end
end

-- Teleport lên độ cao Y=6 khi đang rơi
local function antiFall()
    if character and humanoid then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            local currentPosition = rootPart.Position
            local newPosition = Vector3.new(currentPosition.X, ANTI_FALL_Y, currentPosition.Z)
            rootPart.CFrame = CFrame.new(newPosition)
            rootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- TP Walk - Dịch chuyển thay vì tăng walkspeed
local function tpWalk()
    if not tpWalkEnabled or not character or not humanoid then return end
    
    local currentTime = tick()
    if currentTime - lastTpWalkTime < tpWalkInterval then return end
    lastTpWalkTime = currentTime
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Xác định hướng di chuyển
    local moveDirection = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += rootPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= rootPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= rootPart.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += rootPart.CFrame.RightVector end
    
    moveDirection = moveDirection.Unit * TP_WALK_SPEED * tpWalkInterval
    
    -- Dịch chuyển nhân vật
    rootPart.CFrame = rootPart.CFrame + moveDirection
end

-- Noclip
local function updateNoclip()
    if not noclipEnabled or not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Xử lý khi player thay đổi nhân vật
player.CharacterAdded:Connect(setupCharacter)

-- Khởi tạo
if character then
    setupCharacter(character)
end

-- Tạo menu
local menu = createMenu()

-- Chống rơi định kỳ
spawn(function()
    while true do
        pcall(antiFall)
        wait(1) -- Chỉ chạy mỗi giây 1 lần
    end
end)

-- Vòng lặp chính
RunService.Heartbeat:Connect(function()
    pcall(tpWalk)
    pcall(updateNoclip)
    pcall(checkTycoons)
end)

-- Xóa forcefield khi khởi động
removeForcefields()

print("Steal a Fish! - KDZ Hub đã được kích hoạt!")
