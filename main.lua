local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Cài đặt tốc độ di chuyển
character:WaitForChild("Humanoid").WalkSpeed = 50

-- Kích hoạt chế độ Noclip
local function noclip()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

RunService.Stepped:Connect(noclip)

-- Tạo ESP cho các nhà
local function createESP(tycoonName, position)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = tycoonName .. "_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0) -- Hiển thị cao hơn vị trí gốc
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    
    textLabel.Parent = billboard
    billboard.Parent = player.PlayerGui
    billboard.Adornee = position
    
    return textLabel
end

-- Kiểm tra trạng thái các nhà
local function checkTycoons()
    for i = 1, 8 do
        local tycoonName = "Tycoon" .. i
        local tycoonPath = workspace.Map.Tycoons[tycoonName]
        
        if tycoonPath then
            local screen = tycoonPath.Tycoon.ForcefieldFolder:FindFirstChild("Screen")
            local board = tycoonPath.Tycoon.Board.Board.SurfaceGui:FindFirstChild("Username")
            
            if screen and board then
                -- Tạo ESP nếu chưa tồn tại
                if not player.PlayerGui:FindFirstChild(tycoonName .. "_ESP") then
                    local espText = createESP(tycoonName, screen.Screen)
                    espText.Name = tycoonName .. "_ESPLabel"
                end
                
                local espText = player.PlayerGui[tycoonName .. "_ESP"][tycoonName .. "_ESPLabel"]
                local timeLabel = screen.Screen.SurfaceGui:FindFirstChild("Time")
                
                -- Kiểm tra chủ sở hữu
                if board.Text == "No Owner!" then
                    espText.Text = "NO PLAYER IN BASE"
                    espText.TextColor3 = Color3.new(1, 0.4, 0.4) -- Màu đỏ nhạt
                else
                    -- Kiểm tra thời gian
                    if timeLabel and timeLabel.Text == "0s" then
                        espText.Text = "BASE IS UNLOCK"
                        espText.TextColor3 = Color3.new(0.4, 1, 0.4) -- Màu xanh lá
                    else
                        espText.Text = "TIME BASE: " .. (timeLabel.Text or "N/A")
                        espText.TextColor3 = Color3.new(1, 1, 0.4) -- Màu vàng
                    end
                end
            end
        end
    end
end

-- Chạy kiểm tra liên tục
while true do
    checkTycoons()
    wait(1) -- Cập nhật mỗi giây
end
