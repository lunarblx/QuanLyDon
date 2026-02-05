if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game:GetService("Players").LocalPlayer 
local playerGui = player:WaitForChild("PlayerGui")

local player = game:GetService("Players").LocalPlayer 
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- Lưu Trữ Thời Gian
if not _G.ScriptStartTime then
    _G.ScriptStartTime = tick()
end
local startTime = _G.ScriptStartTime

-- Biến kiểm soát thông báo (Không hiện khi mới chạy script)
local isInitialLoad = true

-- File lưu vị trí
local FILE_NAME = "ServerManagerPos.txt"

-- Ẩn 1 Phần Tên
local function hideName(name)
    local visibleLength = math.max(3, math.floor(#name * 0.5))
    return string.sub(name, 1, visibleLength) .. string.rep("*", #name - visibleLength)
end

-- Định Dạng Thời Gian (HH:MM:SS)
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- GUI Chính
if playerGui:FindFirstChild("NameHub") then playerGui.NameHub:Destroy() end

local nameHub = Instance.new("ScreenGui")
nameHub.Name = "NameHub"
nameHub.Parent = playerGui
nameHub.ResetOnSpawn = false
nameHub.DisplayOrder = 100
nameHub.ZIndexBehavior = Enum.ZIndexBehavior.Global

local mainFrame = Instance.new("Frame")
mainFrame.Parent = nameHub
mainFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
local finalPos = UDim2.new(0.5, 0, 0.1, 0)
mainFrame.Position = UDim2.new(0.5, 0, -0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true

local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = mainFrame
uiStroke.Color = Color3.fromRGB(250, 222, 255)
uiStroke.Thickness = 2.5

-- Gradient Stroke: Trắng > Tím > Hồng
local strokeHue = 1

RunService.RenderStepped:Connect(function(dt)
    strokeHue = (strokeHue + dt * 0.12) % 1

    -- Map hue vào dải Trắng -> Tím -> Hồng
    local color
    if strokeHue < 0.33 then
        -- Trắng -> Tím
        local t = strokeHue / 0.33
        color = Color3.new(
            1,
            1 - 0.4 * t,
            1
        )
    elseif strokeHue < 0.66 then
        -- Tím -> Hồng
        local t = (strokeHue - 0.33) / 0.33
        color = Color3.new(
            1,
            0.6 - 0.3 * t,
            1
        )
    else
        -- Hồng -> Trắng
        local t = (strokeHue - 0.66) / 0.34
        color = Color3.new(
            1,
            0.3 + 0.7 * t,
            1
        )
    end

    uiStroke.Color = color
end)


TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = finalPos}):Play()

mainFrame.Active = true
mainFrame.Draggable = false

-- Hàm Thông Báo Cập Nhật
local function triggerNotify()
    if isInitialLoad then return end
    if mainFrame:FindFirstChild("NotifyLabel") then mainFrame.NotifyLabel:Destroy() end

    local notify = Instance.new("TextLabel")
    notify.Name = "NotifyLabel"
    notify.Parent = mainFrame
    notify.Position = UDim2.new(0.5, 0, -0.7, 0)
    notify.AnchorPoint = Vector2.new(0.5, 0.5)
    notify.Size = UDim2.new(1, 0, 0, 20)
    notify.BackgroundTransparency = 1
    notify.Text = "✨ Đơn Hàng Đã Tự Động Cập Nhật! ✨"
    notify.TextColor3 = Color3.fromRGB(255, 255, 255)
    notify.Font = Enum.Font.GothamBold
    notify.TextSize = 17
    notify.TextTransparency = 1

    local nStroke = Instance.new("UIStroke")
    nStroke.Parent = notify
    nStroke.Thickness = 1
    nStroke.Color = Color3.fromRGB(92, 231, 247)
    nStroke.Transparency = 1

    local glow = Instance.new("UIStroke")
    glow.Name = "GlowEffect"
    glow.Parent = notify
    glow.Thickness = 2 -- Dày hơn để tạo độ tỏa
    glow.Color = Color3.fromRGB(92, 231, 247)
    glow.Transparency = 1

    TweenService:Create(notify, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(nStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {Transparency = 0.6}):Play()

    task.delay(2, function()
        if notify and notify.Parent then
            local fade = TweenService:Create(notify, TweenInfo.new(0.5), {TextTransparency = 1})
            TweenService:Create(nStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
            TweenService:Create(glow, TweenInfo.new(0.5), {Transparency = 1}):Play()
            fade:Play()
            fade.Completed:Connect(function() notify:Destroy() end)
        end
    end)
end

-- Lấy Alias Từ RAM (Roblox Account Manager)
local function fetchAlias(targetBox, isManual)
    task.spawn(function()
        local success, RAMAccountModule = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua"))()
        end)

        if success and RAMAccountModule then
            local MyAccount = RAMAccountModule.new(player.Name)
            if MyAccount then
                local alias = MyAccount:GetAlias()
                targetBox.Text = (alias and alias ~= "") and alias or "N/A"
                
                -- Gọi thông báo khi cập nhật thành công
                triggerNotify()
                
                if isManual then
                    -- triggerNotify() -- Đã gọi ở trên nên không cần dòng này nữa
                end
            end
        end
    end)
end

local function updatePositions()
    local pos = mainFrame.AbsolutePosition
    local size = mainFrame.AbsoluteSize
    closeButton.Position = UDim2.new(0, pos.X + size.X + 2, 0, pos.Y + 2)
    settingButton.Position = UDim2.new(0, pos.X + size.X + 2, 0, pos.Y + 26)
    updateBtn.Position = UDim2.new(0, pos.X + size.X + 2, 0, pos.Y + 50)
end
mainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePositions)

-- Server Manager GUI
local serverGui = Instance.new("Frame", nameHub)
serverGui.Name = "ServerManagerFrame"
serverGui.Size = UDim2.new(0, 190, 0, 215) 
serverGui.AnchorPoint = Vector2.new(1, 1) 
serverGui.Position = UDim2.new(1, -10, 1, -10) 
serverGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
serverGui.BackgroundTransparency = 0.1
serverGui.Visible = true 
serverGui.Active = true
serverGui.Draggable = true
Instance.new("UICorner", serverGui).CornerRadius = UDim.new(0, 6)

local sStroke = Instance.new("UIStroke", serverGui)
sStroke.Color = Color3.fromRGB(255, 120, 0)
sStroke.Thickness = 2

local sLayout = Instance.new("UIListLayout", serverGui)
sLayout.Padding = UDim.new(0, 5)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.SortOrder = Enum.SortOrder.LayoutOrder

serverGui.Active = true
serverGui.Draggable = false

-- Tiêu đề
local sTitle = Instance.new("TextLabel", serverGui)
sTitle.Size = UDim2.new(1, 0, 0, 30)
sTitle.BackgroundTransparency = 1
sTitle.Text = "Server Manager"
sTitle.TextColor3 = Color3.fromRGB(255, 120, 0)
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 13
sTitle.LayoutOrder = 1

-- Ô Nhập Jobid
local jobInput = Instance.new("TextBox", serverGui)
jobInput.Size = UDim2.new(0.85, 0, 0, 30)
jobInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
jobInput.PlaceholderText = "Type Here"
jobInput.Text = ""
jobInput.TextColor3 = Color3.new(1, 1, 1)
jobInput.Font = Enum.Font.Gotham
jobInput.TextScaled = true 
jobInput.LayoutOrder = 2
Instance.new("UICorner", jobInput)

-- Show PlaceID
local pIdLabel = Instance.new("TextLabel", serverGui)
pIdLabel.Size = UDim2.new(0.9, 0, 0, 15)
pIdLabel.BackgroundTransparency = 1
pIdLabel.Text = "ID: " .. game.PlaceId
pIdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
pIdLabel.Font = Enum.Font.Gotham
pIdLabel.TextSize = 12
pIdLabel.LayoutOrder = 3

local spacer = Instance.new("Frame", serverGui)
spacer.Size = UDim2.new(1, 0, 0, 8)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 4

-- Join Server
local joinBtn = Instance.new("TextButton", serverGui)
joinBtn.Size = UDim2.new(0.85, 0, 0, 30)
joinBtn.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
joinBtn.Text = "Join Server ID"
joinBtn.TextColor3 = Color3.new(1, 1, 1)
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 11
joinBtn.LayoutOrder = 5
Instance.new("UICorner", joinBtn)

joinBtn.MouseButton1Click:Connect(function()
    local id = jobInput.Text:gsub("%s+", "")
    if #id > 10 then 
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, player)
    else
        joinBtn.Text = "ID Sai!"; task.wait(1); joinBtn.Text = "Join Server ID"
    end
end)

-- Copy JobID
local copyBtn = Instance.new("TextButton", serverGui)
copyBtn.Size = UDim2.new(0.85, 0, 0, 30)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) 
copyBtn.Text = "Copy JobID"
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 10
copyBtn.LayoutOrder = 6
Instance.new("UICorner", copyBtn)

copyBtn.MouseButton1Click:Connect(function()
    setclipboard(game.JobId)
    copyBtn.Text = "Copied!"; task.wait(1); copyBtn.Text = "Copy JobID"
end)

-- Rejoin Server
local rejoinBtn = Instance.new("TextButton", serverGui)
rejoinBtn.Size = UDim2.new(0.85, 0, 0, 30)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
rejoinBtn.Text = "Rejoin Server"
rejoinBtn.TextColor3 = Color3.new(1, 1, 1)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.TextSize = 11
rejoinBtn.LayoutOrder = 7
Instance.new("UICorner", rejoinBtn)

rejoinBtn.MouseButton1Click:Connect(function()
    rejoinBtn.Text = "Rejoining..."
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- Cập Nhật 3 Nút Dưới Main Frame
local bottomControlFrame = Instance.new("Frame", mainFrame)
bottomControlFrame.Size = UDim2.new(1, 0, 0, 22)
bottomControlFrame.Position = UDim2.new(0.5, 0, 1, 5)
bottomControlFrame.AnchorPoint = Vector2.new(0.5, 0)
bottomControlFrame.BackgroundTransparency = 1

local bottomLayout = Instance.new("UIListLayout", bottomControlFrame)
bottomLayout.FillDirection = Enum.FillDirection.Horizontal
bottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bottomLayout.Padding = UDim.new(0, 4)

-- Hiển Thị Đơn Hàng
local jobFrame = Instance.new("Frame", mainFrame)
jobFrame.Size = UDim2.new(0.85, 0, 0.5, 0);
jobFrame.Position = UDim2.new(0.075, 0, 0, 0);
jobFrame.BackgroundTransparency = 1

local jobTitle = Instance.new("TextLabel", jobFrame)
jobTitle.Size = UDim2.new(0.25, 0, 1, 0);
jobTitle.BackgroundTransparency = 1;
jobTitle.TextColor3 = Color3.new(1, 1, 1);
jobTitle.Text = "Đơn:"; jobTitle.TextScaled = true;
jobTitle.Font = Enum.Font.GothamBold

local jobBox = Instance.new("TextBox", jobFrame)
jobBox.Size = UDim2.new(0.7, 0, 1, 0);
jobBox.Position = UDim2.new(0.28, 0, 0, 0);
jobBox.BackgroundTransparency = 1;
jobBox.TextColor3 = Color3.new(1, 1, 1);
jobBox.TextScaled = true;
jobBox.Font = Enum.Font.GothamBold;
jobBox.Text = "Loading..."

-- Hiển Thị Tên Khách
local nameLabel = Instance.new("TextLabel", mainFrame)
nameLabel.Size = UDim2.new(0.7, 0, 0.5, 0);
nameLabel.Position = UDim2.new(0.135, 0, 0.5, 0);
nameLabel.BackgroundTransparency = 1;
nameLabel.TextColor3 = Color3.fromRGB(222, 185, 18);
nameLabel.TextScaled = true;
nameLabel.Text = "Tên: " .. hideName(player.Name);
nameLabel.Font = Enum.Font.GothamBold

fetchAlias(jobBox)

-- Setting GUI
local smallGui = Instance.new("Frame")
smallGui.Parent = nameHub;
smallGui.Size = UDim2.new(0.25, 0, 0.28, 0);
smallGui.Position = UDim2.new(0.5, 0, 0.25, 0);
smallGui.AnchorPoint = Vector2.new(0.5, 0);
smallGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
smallGui.BackgroundTransparency = 0.1;
smallGui.BorderSizePixel = 0;
smallGui.Visible = false;
smallGui.ClipsDescendants = true

local stroke = Instance.new("UIStroke")
stroke.Parent = smallGui;
stroke.Color = Color3.fromRGB(255, 220, 0);
stroke.Thickness = 2

local UIList = Instance.new("UIListLayout")
UIList.Parent = smallGui; UIList.Padding = UDim.new(0, 8)

-- On/Off HUD (FPS/PLAYER/PING/TIME)
local showInfo = true
local infoButton = Instance.new("TextButton")
infoButton.Parent = smallGui;
infoButton.Size = UDim2.new(1, -10, 0, 30);
infoButton.Position = UDim2.new(0, 5, 0, 45);
infoButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0);
infoButton.BorderSizePixel = 0;
infoButton.TextColor3 = Color3.fromRGB(255, 255, 255);
infoButton.TextScaled = true; infoButton.Font = Enum.Font.GothamBold;
infoButton.Text = "Show FPS | Player | Ping | Time: ON"

infoButton.MouseButton1Click:Connect(function()
    showInfo = not showInfo
    infoButton.BackgroundColor3 = showInfo and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    infoButton.Text = "Show FPS | Player | Ping | Time: " .. (showInfo and "ON" or "OFF")
end)

-- Show Set FPS Cap
local fpsCapFrame = Instance.new("Frame", smallGui)
fpsCapFrame.Size = UDim2.new(1, -24, 0, 26);
fpsCapFrame.BackgroundTransparency = 1
local fpsCapTitle = Instance.new("TextLabel", fpsCapFrame)
fpsCapTitle.Position = UDim2.new(0, 6, 0, 0);
fpsCapTitle.Size = UDim2.new(0.65, 0, 1, 0);
fpsCapTitle.BackgroundTransparency = 1;
fpsCapTitle.Text = "FPS Cap:";
fpsCapTitle.TextScaled = true;
fpsCapTitle.Font = Enum.Font.GothamBold;
fpsCapTitle.TextColor3 = Color3.new(1, 1, 1);
fpsCapTitle.TextXAlignment = Enum.TextXAlignment.Left

local fpsCapBox = Instance.new("TextBox", fpsCapFrame)
fpsCapBox.Size = UDim2.new(0.18, 0, 1, 0);
fpsCapBox.Position = UDim2.new(0.82, 0, 0, 0);
fpsCapBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
fpsCapBox.TextScaled = true;
fpsCapBox.Font = Enum.Font.GothamBold;
fpsCapBox.TextColor3 = Color3.new(1, 1, 1);
fpsCapBox.Text = "0"

local loadPosBtn = Instance.new("TextButton", saveLoadFrame)
loadPosBtn.Size = UDim2.new(0.48, 0, 1, 0)
loadPosBtn.Position = UDim2.new(0.52, 0, 0, 0)
loadPosBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
loadPosBtn.Text = "Load Server Pos"
loadPosBtn.TextColor3 = Color3.new(1,1,1)
loadPosBtn.Font = Enum.Font.GothamBold
loadPosBtn.TextScaled = true
Instance.new("UICorner", loadPosBtn)

-- Auto Load Positon
task.spawn(function()
    if isfile and isfile(FILE_NAME) then
        local data = readfile(FILE_NAME)
        local parts = string.split(data, ",")
        if #parts == 4 then
            serverGui.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
        end
    end
end)

-- Set FPS Cap
local function applyFpsCap()
    local cap = tonumber(fpsCapBox.Text)
    if not cap then fpsCapBox.Text = "0"; return end
    cap = math.max(0, math.floor(cap))
    if setfpscap then setfpscap(cap == 0 and 9999 or cap) end
    fpsCapBox.Text = tostring(cap)
end
fpsCapBox.FocusLost:Connect(function(enter) if enter then applyFpsCap() end end)

-- HUD FPS/Player/Ping/Time
local hud = Instance.new("Frame")
hud.Name = "HUD_Display"
hud.Parent = nameHub
hud.Size = UDim2.new(0, 200, 0, 90)
hud.Position = UDim2.new(0, 5, 0, 5)
hud.BackgroundTransparency = 1

local function createHudLabel(name, order)
    local l = Instance.new("TextLabel")
    l.Name = name
    l.Parent = hud
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Position = UDim2.new(0, 0, 0, (order - 1) * 20)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 18
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = ""
    local stroke = Instance.new("UIStroke", l)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Transparency = 0.2
    return l
end

local fpsLabel = createHudLabel("FPSLabel", 1)
local playerLabel = createHudLabel("PlayerLabel", 2)
local pingLabel = createHudLabel("PingLabel", 3)
local timeLabel = createHudLabel("TimeLabel", 4)

local frames, lastT, hue = 0, tick(), 0
RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastT >= 1 then
        if showInfo then
            fpsLabel.Text = "FPS: " .. frames
            playerLabel.Text = "Players: " .. #game.Players:GetPlayers()
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            pingLabel.Text = "Ping: " .. math.floor(ping) .. " ms"
            timeLabel.Text = "Time: " .. formatTime(now - startTime)
        else
            fpsLabel.Text = ""; playerLabel.Text = ""; pingLabel.Text = ""; timeLabel.Text = ""
        end
        frames = 0
        lastT = now
    end
    if showInfo then
        hue = (hue + 0.002) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
        fpsLabel.TextColor3 = rainbowColor
        playerLabel.TextColor3 = rainbowColor
        pingLabel.TextColor3 = rainbowColor
        timeLabel.TextColor3 = rainbowColor
    end
end)

local isOpen = false

-- Auto Reload Alias
local autoReloadInterval = 120 -- Thời Gian Reload Alias
local lastAutoReload = tick()

task.spawn(function()
    while true do
        task.wait(1)
        if tick() - lastAutoReload >= autoReloadInterval then
            lastAutoReload = tick()
            if fetchAlias and jobBox then
                fetchAlias(jobBox)
                if updateBtn then
                    local rotateTween = TweenService:Create(updateBtn, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = updateBtn.Rotation + 360})
                    rotateTween:Play()
                end
            end
        end
    end
end)

-- Hotkeys
local UserInputService = game:GetService("UserInputService")

-- Hàm xử lý Ẩn/Hiện GUI Chính (Hotkey 1)
local function toggleMainGuiLogic()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    closeButton.Visible = guiVisible
    settingButton.Visible = guiVisible
    updateBtn.Visible = guiVisible
    
    -- Xử lý riêng cho Server Manager
    if not guiVisible then 
        serverWasOpen = serverGui.Visible
        serverGui.Visible = false 
    else 
        serverGui.Visible = serverWasOpen 
    end
    
    -- Cập nhật giao diện nút điều khiển
    toggleGuiBtn.Text = guiVisible and "Ẩn GUI" or "Hiện GUI"
    toggleGuiBtn.BackgroundColor3 = guiVisible and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(0, 150, 0)
end

-- Hàm xử lý Ẩn/Hiện Settings (Hotkey 2)
local function toggleSettingsLogic()
    isOpen = not isOpen
    smallGui.Visible = isOpen
end

-- Hàm xử lý Ẩn/Hiện Server Manager (Hotkey 3)
local function toggleServerManagerLogic()
    serverGui.Visible = not serverGui.Visible
    serverWasOpen = serverGui.Visible -- Cập nhật trạng thái lưu trữ
end

-- Kết nối sự kiện bàn phím
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Nếu đang gõ tin nhắn hoặc trong khung nhập liệu thì bỏ qua
    if gameProcessed then return end

    local key = input.KeyCode
    
    if key == Enum.KeyCode.KeypadOne then
        -- [NUMPAD 1] Ẩn/Hiện Toàn Bộ GUI
        toggleMainGuiLogic()
        
    elseif key == Enum.KeyCode.KeypadTwo then
        -- [NUMPAD 2] Ẩn/Hiện Menu Cài Đặt (Settings)
        toggleSettingsLogic()
        
    elseif key == Enum.KeyCode.KeypadThree then
        -- [NUMPAD 3] Ẩn/Hiện Server Manager
        toggleServerManagerLogic()
        
    elseif key == Enum.KeyCode.KeypadFour then
        -- [NUMPAD 4] Làm mới Alias (Cập nhật đơn hàng)
        if fetchAlias and jobBox then
            fetchAlias(jobBox, true)
            TweenService:Create(updateBtn, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Rotation = updateBtn.Rotation + 360}):Play()
        end
    end
end)


-- Sau khi script chạy xong hoàn toàn lần đầu, bật thông báo cho các lần reload sau
task.wait(5)
isInitialLoad = false

-- Tự động tính toán lại vị trí khi thay đổi kích thước cửa sổ (Dành cho Server Manager)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    serverGui.Position = UDim2.new(1, -10, 1, -10)
end)

local Players = game:GetService("Players")

-- Hàm xử lý chuỗi: Giữ lại 3 ký tự đầu, còn lại thay bằng *
local function maskString(str)
    if #str <= 3 then return "***" end
    local visible = string.sub(str, 1, 3)
    return visible .. string.rep("*", #str - 3)
end

local function applyMask()
    -- Truy cập vào UI Leaderboard mặc định của Roblox
    local playerList = game:GetService("CoreGui"):FindFirstChild("PlayerList")
    if playerList then
        for _, v in pairs(playerList:GetDescendants()) do
            -- Tìm các TextLabel hiển thị tên người chơi
            if v:IsA("TextLabel") then
                for _, player in pairs(Players:GetPlayers()) do
                    -- Nếu Text khớp với tên hoặc tên hiển thị của người chơi
                    if v.Text == player.Name or v.Text == player.DisplayName then
                        v.Text = maskString(v.Text)
                    end
                end
            end
        end
    end
end

-- Chạy liên tục để cập nhật khi có người mới vào hoặc đổi bảng
task.spawn(function()
    while task.wait(0.5) do
        pcall(applyMask)
    end
end)

local Players = game:GetService("Players")

-- Hàm xử lý chuỗi: Giữ lại 3 ký tự đầu, còn lại thay bằng *
local function maskString(str)
    if #str <= 3 then return "***" end
    local visible = string.sub(str, 1, 3)
    return visible .. string.rep("*", #str - 3)
end

local function applyMask()
    -- Truy cập vào UI Leaderboard mặc định của Roblox
    local playerList = game:GetService("CoreGui"):FindFirstChild("PlayerList")
    if playerList then
        for _, v in pairs(playerList:GetDescendants()) do
            -- Tìm các TextLabel hiển thị tên người chơi
            if v:IsA("TextLabel") then
                for _, player in pairs(Players:GetPlayers()) do
                    -- Nếu Text khớp với tên hoặc tên hiển thị của người chơi
                    if v.Text == player.Name or v.Text == player.DisplayName then
                        v.Text = maskString(v.Text)
                    end
                end
            end
        end
    end
end

-- Chạy liên tục để cập nhật khi có người mới vào hoặc đổi bảng
task.spawn(function()
    while task.wait(0.5) do
        pcall(applyMask)
    end
end)

print("✅ Hệ thống Hotkey đã sẵn sàng:")
print(" - Numpad 1: Ẩn/Hiện HUD")
print(" - Numpad 2: Cài đặt")
print(" - Numpad 3: Server Manager")
print(" - Numpad 4: Reload Đơn hàng")
