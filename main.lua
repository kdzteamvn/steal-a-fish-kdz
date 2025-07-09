local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- CẤU HÌNH
local ESP_HEIGHT = 8 -- Độ cao ESP (stud)
local TEXT_SIZE = 35 -- Kích thước chữ ESP

-- Chống ragdoll (anti-ragdoll)
local function antiRagdoll()
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end
    
    -- Xử lý khi có bộ phận ragdoll
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("OriginalPosition") then
            part:Destroy()
        end
    end
end

-- Tạo ESP cho các nhà
local ESPs = {}
local function createESP(tycoonName, position)
    -- Xóa ESP cũ nếu tồn tại
    if ESPs[tycoonName] then
        ESPs[tycoonName]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = tycoonName .. "_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 300, 0, 70)
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
            local screen = tycoonPath.Tycoon.ForcefieldFolder:FindFirstChild("Screen")
            local board = tycoonPath.Tycoon.Board.Board.SurfaceGui:FindFirstChild("Username")
            
            if screen and board then
                local espText
                
                -- Tạo ESP nếu chưa tồn tại
                if not ESPs[tycoonName] then
                    espText = createESP(tycoonName, screen.Screen)
                else
                    espText = ESPs[tycoonName]:FindFirstChild("ESPLabel")
                end
                
                if espText then
                    local timeLabel = screen.Screen.SurfaceGui:FindFirstChild("Time")
                    
                    -- Kiểm tra chủ sở hữu
                    if board.Text == "No Owner!" then
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

-- Khởi tạo hệ thống
antiRagdoll()

-- Chạy kiểm tra liên tục
while true do
    pcall(checkTycoons) -- Sử dụng pcall để bắt lỗi
    RunService.Heartbeat:Wait()
end
