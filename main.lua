-- Roblox Tycoon Time Checker với ESP Text
-- Script tự động kiểm tra thời gian của các nhà từ Tycoon1 đến Tycoon8

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo ScreenGui cho ESP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TycoonTimeESP"
screenGui.Parent = playerGui

-- Bảng lưu trữ các ESP text labels
local espLabels = {}

-- Hàm tạo ESP text label
local function createESPLabel(tycoonNumber)
    local label = Instance.new("TextLabel")
    label.Name = "TycoonESP" .. tycoonNumber
    label.Size = UDim2.new(0, 200, 0, 50)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.SourceSansBold
    label.Text = "Loading..."
    label.Parent = screenGui
    
    return label
end

-- Hàm kiểm tra xem nhà có người chơi không
local function hasPlayer(tycoonNumber)
    local path = workspace.Map.Tycoons["Tycoon" .. tycoonNumber].Tycoon.Board.Board.SurfaceGui.Username
    if path and path.Text then
        return path.Text ~= "No Owner!"
    end
    return false
end

-- Hàm lấy thời gian từ textlabel
local function getTimeFromTycoon(tycoonNumber)
    local timePath = workspace.Map.Tycoons["Tycoon" .. tycoonNumber].Tycoon.ForcefieldFolder.Screen.Screen.SurfaceGui.Time
    if timePath and timePath.Text then
        return timePath.Text
    end
    return nil
end

-- Hàm lấy vị trí Handle để đặt ESP
local function getHandlePosition(tycoonNumber)
    local handlePath = workspace.Map.Tycoons["Tycoon" .. tycoonNumber].Tycoon.ForcefieldFolder.Screen.Handle
    if handlePath then
        return handlePath.Position
    end
    return nil
end

-- Hàm chuyển đổi vị trí 3D sang 2D
local function worldToScreen(position)
    local camera = workspace.CurrentCamera
    local screenPoint, onScreen = camera:WorldToScreenPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

-- Hàm cập nhật ESP cho một nhà
local function updateTycoonESP(tycoonNumber)
    local label = espLabels[tycoonNumber]
    if not label then return end
    
    -- Kiểm tra xem nhà có tồn tại không
    local tycoonPath = workspace.Map.Tycoons:FindFirstChild("Tycoon" .. tycoonNumber)
    if not tycoonPath then
        label.Visible = false
        return
    end
    
    -- Lấy vị trí Handle
    local handlePosition = getHandlePosition(tycoonNumber)
    if not handlePosition then
        label.Visible = false
        return
    end
    
    -- Chuyển đổi vị trí 3D sang 2D và đặt cao hơn
    local screenPos, onScreen = worldToScreen(handlePosition + Vector3.new(0, 5, 0))
    
    if onScreen then
        label.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 25)
        label.Visible = true
        
        -- Kiểm tra xem nhà có người chơi không
        if not hasPlayer(tycoonNumber) then
            label.Text = "NO PLAYER IN BASE"
            label.TextColor3 = Color3.fromRGB(255, 100, 100) -- Màu đỏ nhạt
        else
            -- Có người chơi, kiểm tra thời gian
            local timeText = getTimeFromTycoon(tycoonNumber)
            if timeText then
                if timeText == "0s" then
                    label.Text = "BASE IS UNLOCK"
                    label.TextColor3 = Color3.fromRGB(100, 255, 100) -- Màu xanh lá
                else
                    label.Text = "TIME BASE: " .. timeText
                    label.TextColor3 = Color3.fromRGB(255, 255, 100) -- Màu vàng
                end
            else
                label.Text = "ERROR: Can't read time"
                label.TextColor3 = Color3.fromRGB(255, 100, 100) -- Màu đỏ
            end
        end
    else
        label.Visible = false
    end
end

-- Tạo ESP labels cho tất cả các nhà
for i = 1, 8 do
    espLabels[i] = createESPLabel(i)
end

-- Hàm cập nhật tất cả ESP
local function updateAllESP()
    for i = 1, 8 do
        pcall(function()
            updateTycoonESP(i)
        end)
    end
end

-- Kết nối với RenderStepped để cập nhật liên tục
local connection = RunService.RenderStepped:Connect(updateAllESP)

-- Dọn dẹp khi script kết thúc
local function cleanup()
    if connection then
        connection:Disconnect()
    end
    if screenGui then
        screenGui:Destroy()
    end
end

-- Xử lý khi player rời game
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        cleanup()
    end
end)

-- Thông báo script đã khởi động
print("Tycoon Time Checker ESP Script đã khởi động!")
print("Đang theo dõi thời gian của " .. #espLabels .. " nhà...")

-- Tạo nút tắt script (tùy chọn)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleESP"
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Toggle ESP"
toggleButton.Parent = screenGui

local espEnabled = true
toggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    for i = 1, 8 do
        espLabels[i].Visible = espEnabled
    end
    toggleButton.Text = espEnabled and "Toggle ESP" or "ESP OFF"
end)
