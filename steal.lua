-- Roblox Steal Script với UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Biến kiểm soát cooldown
local isOnCooldown = false

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealGui"
screenGui.Parent = playerGui

-- Tạo Frame chính (nền đen)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 60)
mainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Bo tròn góc cho frame chính
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Tạo nút bấm (màu xanh)
local stealButton = Instance.new("TextButton")
stealButton.Size = UDim2.new(1, -10, 1, -10)
stealButton.Position = UDim2.new(0, 5, 0, 5)
stealButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
stealButton.Text = "Steal | KDZ Hub"
stealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stealButton.TextScaled = true
stealButton.Font = Enum.Font.SourceSansBold
stealButton.BorderSizePixel = 0
stealButton.Parent = mainFrame

-- Bo tròn góc cho nút bấm
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = stealButton

-- Hàm teleport người chơi
local function teleportPlayer(x, y, z)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- Hàm tìm base của người chơi
local function findPlayerBase()
    local workspace = game.Workspace
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    local tycoonsFolder = mapFolder:FindFirstChild("Tycoons")
    if not tycoonsFolder then return nil end
    
    -- Lặp qua từng tycoon từ 1 đến 8
    for i = 1, 8 do
        local tycoonName = "Tycoon" .. i
        local tycoon = tycoonsFolder:FindFirstChild(tycoonName)
        
        if tycoon then
            local tycoonInner = tycoon:FindFirstChild("Tycoon")
            if tycoonInner then
                local board = tycoonInner:FindFirstChild("Board")
                if board then
                    local boardPart = board:FindFirstChild("Board")
                    if boardPart then
                        local surfaceGui = boardPart:FindFirstChild("SurfaceGui")
                        if surfaceGui then
                            local username = surfaceGui:FindFirstChild("Username")
                            if username and username.Text == "@" .. player.Name then
                                -- Tìm thấy base của người chơi
                                local basePosition = boardPart.Position
                                -- Hạ xuống một chút
                                return Vector3.new(basePosition.X, basePosition.Y - 5, basePosition.Z)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Hàm đếm ngược
local function startCountdown()
    local countdown = 5
    
    -- Cập nhật text mỗi giây
    local function updateCountdown()
        stealButton.Text = tostring(countdown) .. " | KDZ Hub"
        countdown = countdown - 1
        
        if countdown < 0 then
            -- Teleport về base
            local playerBase = findPlayerBase()
            if playerBase then
                teleportPlayer(playerBase.X, playerBase.Y, playerBase.Z)
            end
            
            -- Reset UI
            stealButton.Text = "Steal | KDZ Hub"
            isOnCooldown = false
            return
        end
        
        wait(1)
        updateCountdown()
    end
    
    updateCountdown()
end

-- Xử lý khi nhấn nút
stealButton.MouseButton1Click:Connect(function()
    if isOnCooldown then return end
    
    isOnCooldown = true
    
    -- Teleport đến vị trí chỉ định
    teleportPlayer(51.59375, 100, 140.355255)
    
    -- Bắt đầu đếm ngược
    spawn(function()
        startCountdown()
    end)
end)

-- Hiệu ứng hover cho nút bấm
stealButton.MouseEnter:Connect(function()
    if not isOnCooldown then
        local tween = TweenService:Create(stealButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 220)})
        tween:Play()
    end
end)

stealButton.MouseLeave:Connect(function()
    if not isOnCooldown then
        local tween = TweenService:Create(stealButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 162, 255)})
        tween:Play()
    end
end)

print("Steal Script loaded successfully!")
