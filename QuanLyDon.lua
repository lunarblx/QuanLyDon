if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game:GetService("Players").LocalPlayer 
local playerGui = player:WaitForChild("PlayerGui")

-- ===== FIX GUI SERVER MANAGER BỊ ĐÈ =====
do
    local pg = playerGui
    local g = pg:FindFirstChild("FrierenServerManager")
    if g then
        g:Destroy()
    end
end
-- ======================================

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
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Save File
local SAVE_FILE = "ServerManager.json"

-- Frieren Version
local FRIEREN_BLUE = Color3.fromRGB(65, 185, 225)
local LOCK_COLOR = Color3.fromRGB(255, 100, 100)
local BG_COLOR = Color3.fromRGB(10, 15, 20)

--// UI Helper
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

--// ScreenGui
local CoreGui = game:GetService("CoreGui")

local gui = create("ScreenGui", {
    Name = "FrierenServerManager",
    Parent = CoreGui, -- 👈 ĐÈ LÊN MỌI OBJECT
    ResetOnSpawn = false,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
})

--// Main Frame
local main = create("Frame", {
    Parent = gui,
    Size = UDim2.new(0, 240, 0, 95),
    Position = UDim2.new(1, -10, 0, 10), 
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = BG_COLOR,
    BackgroundTransparency = 0.1,
    Active = true,
    Draggable = true
})
create("UICorner", {Parent = main, CornerRadius = UDim.new(0, 8)})
create("UIStroke", {Parent = main, Color = FRIEREN_BLUE, Thickness = 2, Transparency = 0.2})

--// Top Bar
local topBar = create("Frame", {
    Parent = main,
    Size = UDim2.new(1, -16, 0, 25),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1
})

local refreshBtn = create("TextButton", {
    Parent = topBar,
    Size = UDim2.new(0, 22, 0, 22),
    BackgroundColor3 = FRIEREN_BLUE,
    Text = "♻",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 14
})
create("UICorner", {Parent = refreshBtn, CornerRadius = UDim.new(0,4)})

local lockBtn = create("TextButton", {
    Parent = topBar,
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -22, 0, 0),
    BackgroundColor3 = FRIEREN_BLUE,
    Text = "🔓",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 14
})
create("UICorner", {Parent = lockBtn, CornerRadius = UDim.new(0,4)})

local idDisplay = create("TextLabel", {
    Parent = topBar,
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 30, 0, 0),
    BackgroundTransparency = 1,
    Text = "PlaceID: "..game.PlaceId,
    TextColor3 = FRIEREN_BLUE,
    Font = Enum.Font.GothamMedium,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left
})
create("UITextSizeConstraint", {Parent = idDisplay, MaxTextSize = 13})

--// Middle Row
local midRow = create("Frame", {
    Parent = main,
    Size = UDim2.new(1, -16, 0, 28),
    Position = UDim2.new(0, 8, 0, 38),
    BackgroundTransparency = 1
})

local jobInput = create("TextBox", {
    Parent = midRow,
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(25,30,40),
    PlaceholderText = "Enter Job ID...",
    Text = "",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.Gotham,
    TextScaled = true,
    ClearTextOnFocus = false
})
create("UICorner", {Parent = jobInput, CornerRadius = UDim.new(0,4)})
create("UITextSizeConstraint", {Parent = jobInput, MaxTextSize = 12})

local copyBtn = create("TextButton", {
    Parent = midRow,
    Size = UDim2.new(0.25, 0, 1, 0),
    Position = UDim2.new(0.75, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40,120,160),
    Text = "📋",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 14
})
create("UICorner", {Parent = copyBtn, CornerRadius = UDim.new(0,4)})

--// Bottom Button
local hopBtn = create("TextButton", {
    Parent = main,
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.new(0, 8, 1, -28),
    BackgroundColor3 = FRIEREN_BLUE,
    Text = "Join Server",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextScaled = true
})
create("UICorner", {Parent = hopBtn, CornerRadius = UDim.new(0,4)})
create("UITextSizeConstraint", {Parent = hopBtn, MaxTextSize = 11})

--// ===== LOGIC =====
local isLocked = false

-- SAVE (CẤU TRÚC CŨ)
local function SaveServerManager()
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode({
            Position = {
                main.Position.X.Scale,
                main.Position.X.Offset,
                main.Position.Y.Scale,
                main.Position.Y.Offset
            },
            Locked = isLocked
        }))
    end
end

-- SET LOCK
local function setLockState(state)
    isLocked = state
    main.Draggable = not state
    lockBtn.Text = state and "🔒" or "🔓"
    lockBtn.BackgroundColor3 = state and LOCK_COLOR or FRIEREN_BLUE
end

-- LOAD (CẤU TRÚC CŨ)
if isfile and isfile(SAVE_FILE) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(SAVE_FILE))
        if data.Position then
            main.Position = UDim2.new(
                data.Position[1],
                data.Position[2],
                data.Position[3],
                data.Position[4]
            )
        end
        if data.Locked ~= nil then
            setLockState(data.Locked)
        end
    end)
end

-- Auto Save Position
local lastSave = 0
main:GetPropertyChangedSignal("Position"):Connect(function()
    if tick() - lastSave > 0.3 then
        lastSave = tick()
        SaveServerManager()
    end
end)

-- Lock Button
lockBtn.MouseButton1Click:Connect(function()
    setLockState(not isLocked)
    SaveServerManager()
end)

-- Rejoin
refreshBtn.MouseButton1Click:Connect(function()
    hopBtn.Text = "Rejoining..."
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- Join JobId
hopBtn.MouseButton1Click:Connect(function()
    local id = jobInput.Text:gsub("%s+", "")
    if #id > 5 then
        hopBtn.Text = "Teleporting..."
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, player)
    else
        hopBtn.Text = "ID REQUIRED!"
        task.wait(1)
        hopBtn.Text = "Join Server"
    end
end)

-- Copy JobId
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(game.JobId)
        copyBtn.Text = "✔"
        task.wait(1)
        copyBtn.Text = "📋"
    end
end)

-- HOTKEY: NUMPAD 3 TOGGLE
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.KeypadThree then
        main.Visible = not main.Visible
    end
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

-- Tự động tính toán lại vị trí khi thay đổi kích thước cửa sổ
-- (Áp dụng cho Frieren Server Manager)

local camera = workspace.CurrentCamera

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    -- Nếu GUI KHÔNG bị khóa thì mới tự căn lại về góc phải trên
    if not isLocked then
        main.Position = UDim2.new(1, -10, 0, 10)
        SaveServerManager()
    end
end)

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
