local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChild("Humanoid")

-- CẤU HÌNH
local WALKSPEED = 100 -- Tăng tốc độ lên 100
local ESP_HEIGHT = 10 -- Độ cao ESP tăng lên
local TEXT_SIZE = 40 -- Chữ to hơn
local ANTI_FALL_HEIGHT = 20 -- Độ cao teleport khi rơi

-- Biến toàn cục
local ESPs = {}
local noclipConnection
local movementSetup = false

-- Hàm setup movement (walkspeed, noclip) và anti-ragdoll
local function setupCharacter(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- Chống ragdoll
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    
    -- Đặt walkspeed
    humanoid.WalkSpeed = WALKSPEED
    
    -- Kết nối noclip
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    movementSetup = true
end

-- Tạo ESP cho các nhà
local function createESP(tycoonName, position)
    -- Xóa ESP cũ nếu tồn tại
    if ESPs[tycoonName] then
        ESPs[tycoonName]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = tycoonName .. "_ESP"
    billboard.AlwaysOnTop = true
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
                    
                    -- Tạo ESP nếu chưa tồn tại
                    if not ESPs[tycoonName] then
                        espText = createESP(tycoonName, screen.Screen)
                    else
                        espText = ESPs[tycoonName]:FindFirstChild("ESPLabel")
                    end
                    
                    if espText then
                        local timeGui = screen.Screen:FindFirstChild("SurfaceGui")
                        local timeLabel = timeGui and timeGui:FindFirstChild("Time")
                        
                        -- Kiểm tra chủ sở hữu
                        if usernameLabel.Text == "No Owner!" then
                            espText.Text = "NO PLAYER IN BASE"
                            espText.TextColor3 = Color3.new(1, 0.3, 0.3) -- Màu đỏ
                        else
                            -- Kiểm tra thời gian
                            if timeLabel and timeLabel.Text == "0s" then
                                espText.Text = "BASE IS UNLOCKED"
                                espText.TextColor3 = Color3.new(0.3, 1, 0.3) -- Màu xanh lá
                            else
                                espText.Text = "TIME: " .. (timeLabel.Text or "N/A")
                                espText.TextColor3 = Color3.new(1, 1, 0.3) -- Màu vàng
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Hàm xóa forcefield trong các nhà
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
                        for _, child in ipairs(buttons:GetChildren()) do
                            if child.Name:find("ForceField") then
                                child:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Teleport lên cao khi đang rơi
local function antiFall()
    if character and humanoid then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, ANTI_FALL_HEIGHT, 0)
        end
    end
end

-- Gỡ bỏ ESP khi không cần thiết
local function cleanUp()
    for _, esp in pairs(ESPs) do
        esp:Destroy()
    end
    ESPs = {}
    if noclipConnection then
        noclipConnection:Disconnect()
    end
end

-- Xử lý khi player thay đổi nhân vật (chết và hồi sinh)
player.CharacterAdded:Connect(function(newCharacter)
    setupCharacter(newCharacter)
end)

-- Khởi tạo lần đầu
if character then
    setupCharacter(character)
end

-- Chạy kiểm tra liên tục
spawn(function()
    while true do
        pcall(checkTycoons)
        RunService.Heartbeat:Wait()
    end
end)

-- Chạy anti-fall liên tục
spawn(function()
    while true do
        pcall(antiFall)
        RunService.Heartbeat:Wait()
    end
end)

-- Chạy hàm xóa forcefield
removeForcefields()

-- Gỡ bỏ khi script bị hủy
if script:IsDescendantOf(game) then
    script.Destroying:Connect(cleanUp)
end
