-- ═══════════════════════════════════════════════════════════════════════
-- A_A PANEL | Copy + Commands + Spam + Control
-- ═══════════════════════════════════════════════════════════════════════
-- Credits to Remote Detector

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- Clean Old
-- ═══════════════════════════════════════════════════════════════════════

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "A_A_Panel" or gui.Name == "A_A_Spam" or gui.Name == "A_A_Skins" then
        gui:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- Colors
-- ═══════════════════════════════════════════════════════════════════════

local Colors = {
    Background = Color3.fromRGB(8, 12, 18),
    PanelBg = Color3.fromRGB(15, 20, 28),
    Accent = Color3.fromRGB(0, 220, 100),
    AccentDark = Color3.fromRGB(0, 140, 65),
    Red = Color3.fromRGB(220, 50, 50),
    Orange = Color3.fromRGB(255, 140, 0),
    Blue = Color3.fromRGB(0, 150, 255),
    Purple = Color3.fromRGB(147, 0, 211),
    Pink = Color3.fromRGB(255, 105, 180),
    Yellow = Color3.fromRGB(255, 215, 0),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(180, 180, 180)
}

-- ═══════════════════════════════════════════════════════════════════════
-- Variables
-- ═══════════════════════════════════════════════════════════════════════

local SelectedPlayer = nil
local SpamActive = false
local SpamThread = nil
local AdminPrefix = ";"
local CurrentTab = "Copy"
local CurrentSpamMode = "Normal"

-- ═══════════════════════════════════════════════════════════════════════
-- Virtual Chat - Credits to Remote Detector
-- ═══════════════════════════════════════════════════════════════════════

local function SendVirtualMessage(msg)
    pcall(function()
        local hdAdmin = ReplicatedStorage:FindFirstChild("HDAdminHDClient")
        if hdAdmin then
            local signals = hdAdmin:FindFirstChild("Signals")
            if signals then
                local activate = signals:FindFirstChild("ActivateClientCommand")
                if activate then
                    activate:FireServer(msg)
                end
            end
        end
    end)

    pcall(function()
        local dataService = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if dataService then
            local remote = dataService:FindFirstChild("DataService")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer(msg)
            end
        end
    end)

    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(msg)
            end
        end
    end)

    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local sayEvent = chatEvents:FindFirstChild("SayMessageRequest")
            if sayEvent then
                sayEvent:FireServer(msg, "All")
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- Main UI
-- ═══════════════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "A_A_Panel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.15, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Colors.Accent
MainStroke.Thickness = 2

-- ═══════════════════════════════════════════════════════════════════════
-- Title Bar
-- ═══════════════════════════════════════════════════════════════════════

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Colors.PanelBg
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "A_A + K4 + IFQ"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Colors.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.White
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ═══════════════════════════════════════════════════════════════════════
-- Tabs
-- ═══════════════════════════════════════════════════════════════════════

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 52)
TabFrame.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabFrame)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 12)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundTransparency = 1

local function CreateTab(name)
    local tabBtn = Instance.new("TextButton", TabFrame)
    tabBtn.Size = UDim2.new(0, 130, 1, 0)
    tabBtn.BackgroundColor3 = (name == CurrentTab) and Colors.AccentDark or Colors.PanelBg
    tabBtn.Text = name
    tabBtn.TextColor3 = Colors.White
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 16
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)

    local tabContent = Instance.new("Frame", ContentFrame)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = (name == CurrentTab)
    tabContent.Name = name .. "Content"

    tabBtn.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, btn in ipairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Text == name) and Colors.AccentDark or Colors.PanelBg
            end
        end
        for _, content in ipairs(ContentFrame:GetChildren()) do
            if content:IsA("Frame") then
                content.Visible = (content.Name == name .. "Content")
            end
        end
    end)

    return tabContent
end

local CopyTab = CreateTab("Copy")
local ControlTab = CreateTab("Control")

-- ═══════════════════════════════════════════════════════════════════════
-- Copy Tab - Player List
-- ═══════════════════════════════════════════════════════════════════════

local PlayerList = Instance.new("ScrollingFrame", CopyTab)
PlayerList.Size = UDim2.new(0.55, -5, 1, 0)
PlayerList.Position = UDim2.new(0, 0, 0, 0)
PlayerList.BackgroundColor3 = Colors.PanelBg
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = Colors.Accent
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 12)

local PlayerLayout = Instance.new("UIListLayout", PlayerList)
PlayerLayout.Padding = UDim.new(0, 6)
PlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ═══════════════════════════════════════════════════════════════════════
-- Copy Tab - Commands Area
-- ═══════════════════════════════════════════════════════════════════════

local CmdArea = Instance.new("Frame", CopyTab)
CmdArea.Size = UDim2.new(0.43, -5, 1, 0)
CmdArea.Position = UDim2.new(0.57, 0, 0, 0)
CmdArea.BackgroundColor3 = Colors.PanelBg
CmdArea.BorderSizePixel = 0
Instance.new("UICorner", CmdArea).CornerRadius = UDim.new(0, 12)

local CmdLayout = Instance.new("UIListLayout", CmdArea)
CmdLayout.Padding = UDim.new(0, 6)
CmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
CmdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Status
local StatusLabel = Instance.new("TextLabel", CmdArea)
StatusLabel.Size = UDim2.new(0.92, 0, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
StatusLabel.Text = "No player selected"
StatusLabel.TextColor3 = Colors.Gray
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

-- Admin Prefix Input
local AdminFrame = Instance.new("Frame", CmdArea)
AdminFrame.Size = UDim2.new(0.92, 0, 0, 38)
AdminFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
AdminFrame.BorderSizePixel = 0
Instance.new("UICorner", AdminFrame).CornerRadius = UDim.new(0, 8)

local AdminIcon = Instance.new("TextLabel", AdminFrame)
AdminIcon.Size = UDim2.new(0, 35, 1, 0)
AdminIcon.BackgroundColor3 = Colors.Blue
AdminIcon.Text = "i"
AdminIcon.TextColor3 = Colors.White
AdminIcon.Font = Enum.Font.GothamBold
AdminIcon.TextSize = 18
Instance.new("UICorner", AdminIcon).CornerRadius = UDim.new(0, 8)

local AdminInput = Instance.new("TextBox", AdminFrame)
AdminInput.Size = UDim2.new(1, -45, 1, -8)
AdminInput.Position = UDim2.new(0, 42, 0, 4)
AdminInput.BackgroundTransparency = 1
AdminInput.Text = ""
AdminInput.PlaceholderText = "Admin prefix"
AdminInput.TextColor3 = Colors.White
AdminInput.PlaceholderColor3 = Colors.Gray
AdminInput.Font = Enum.Font.GothamSemibold
AdminInput.TextSize = 13
AdminInput.ClearTextOnFocus = false

AdminInput.FocusLost:Connect(function()
    if AdminInput.Text ~= "" then
        AdminPrefix = AdminInput.Text
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- Create Button Function
-- ═══════════════════════════════════════════════════════════════════════

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.BackgroundColor3 = color or Colors.AccentDark
    btn.Text = text
    btn.TextColor3 = Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- ═══════════════════════════════════════════════════════════════════════
-- Main Copy Buttons
-- ═══════════════════════════════════════════════════════════════════════

CreateButton(CmdArea, "Full Name", Colors.Accent, function()
    if not SelectedPlayer then StatusLabel.Text = "Select a player first"; return end
    local cmd = AdminPrefix .. "name " .. SelectedPlayer.Name
    pcall(function() setclipboard(cmd) end)
    StatusLabel.Text = "Copied: " .. cmd
end)

CreateButton(CmdArea, "3 Letters", Colors.AccentDark, function()
    if not SelectedPlayer then StatusLabel.Text = "Select a player first"; return end
    local short = string.sub(SelectedPlayer.Name, 1, 3)
    local cmd = AdminPrefix .. "name " .. short
    pcall(function() setclipboard(cmd) end)
    StatusLabel.Text = "Copied: " .. cmd
end)

-- ═══════════════════════════════════════════════════════════════════════
-- Spam Mode Dropdown
-- ═══════════════════════════════════════════════════════════════════════

local SpamModeFrame = Instance.new("Frame", CmdArea)
SpamModeFrame.Size = UDim2.new(0.92, 0, 0, 38)
SpamModeFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
SpamModeFrame.BorderSizePixel = 0
Instance.new("UICorner", SpamModeFrame).CornerRadius = UDim.new(0, 8)

local SpamModeLabel = Instance.new("TextLabel", SpamModeFrame)
SpamModeLabel.Size = UDim2.new(0, 50, 1, 0)
SpamModeLabel.BackgroundTransparency = 1
SpamModeLabel.Text = "Mode:"
SpamModeLabel.TextColor3 = Colors.Gray
SpamModeLabel.Font = Enum.Font.GothamBold
SpamModeLabel.TextSize = 13

local SpamModeDisplay = Instance.new("TextLabel", SpamModeFrame)
SpamModeDisplay.Size = UDim2.new(1, -60, 1, 0)
SpamModeDisplay.Position = UDim2.new(0, 55, 0, 0)
SpamModeDisplay.BackgroundTransparency = 1
SpamModeDisplay.Text = "Normal"
SpamModeDisplay.TextColor3 = Colors.Accent
SpamModeDisplay.Font = Enum.Font.GothamBold
SpamModeDisplay.TextSize = 14

local SpamModes = {"Normal", "Ghost", "Head Admin"}
local DropdownOpen = false

local DropdownFrame = Instance.new("Frame", CmdArea)
DropdownFrame.Size = UDim2.new(0.92, 0, 0, 0)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.Visible = false
DropdownFrame.ZIndex = 10
Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

local DropdownLayout = Instance.new("UIListLayout", DropdownFrame)
DropdownLayout.Padding = UDim.new(0, 2)

for i, mode in ipairs(SpamModes) do
    local modeBtn = Instance.new("TextButton", DropdownFrame)
    modeBtn.Size = UDim2.new(1, 0, 0, 32)
    modeBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
    modeBtn.Text = mode
    modeBtn.TextColor3 = Colors.White
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 13
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 6)

    modeBtn.MouseButton1Click:Connect(function()
        CurrentSpamMode = mode
        SpamModeDisplay.Text = mode
        DropdownFrame.Visible = false
        DropdownOpen = false
    end)
end

SpamModeFrame.MouseButton1Click:Connect(function()
    DropdownOpen = not DropdownOpen
    DropdownFrame.Visible = DropdownOpen
    if DropdownOpen then
        DropdownFrame.Size = UDim2.new(0.92, 0, 0, #SpamModes * 34)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- Bottom Row (Start Spam / Stop)
-- ═══════════════════════════════════════════════════════════════════════

local BottomRow = Instance.new("Frame", CmdArea)
BottomRow.Size = UDim2.new(0.92, 0, 0, 40)
BottomRow.BackgroundTransparency = 1

local BottomLayout = Instance.new("UIListLayout", BottomRow)
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.Padding = UDim.new(0, 6)

local StartSpamBtn = Instance.new("TextButton", BottomRow)
StartSpamBtn.Size = UDim2.new(0.48, 0, 1, 0)
StartSpamBtn.BackgroundColor3 = Colors.Accent
StartSpamBtn.Text = "> Start Spam"
StartSpamBtn.TextColor3 = Colors.White
StartSpamBtn.Font = Enum.Font.GothamBold
StartSpamBtn.TextSize = 14
Instance.new("UICorner", StartSpamBtn).CornerRadius = UDim.new(0, 10)

local StopSpamBtn = Instance.new("TextButton", BottomRow)
StopSpamBtn.Size = UDim2.new(0.48, 0, 1, 0)
StopSpamBtn.BackgroundColor3 = Colors.Red
StopSpamBtn.Text = "|| Stop"
StopSpamBtn.TextColor3 = Colors.White
StopSpamBtn.Font = Enum.Font.GothamBold
StopSpamBtn.TextSize = 14
Instance.new("UICorner", StopSpamBtn).CornerRadius = UDim.new(0, 10)

-- ═══════════════════════════════════════════════════════════════════════
-- Update Player List
-- ═══════════════════════════════════════════════════════════════════════

local function UpdatePlayers()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerList)
            btn.Size = UDim2.new(0.95, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(28, 36, 46)
            btn.Text = plr.Name
            btn.TextColor3 = Colors.White
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.LayoutOrder = 1
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = plr
                StatusLabel.Text = "Selected: " .. plr.Name
                StatusLabel.TextColor3 = Colors.Accent
            end)
        end
    end

    PlayerList.CanvasSize = UDim2.new(0, 0, 0, PlayerLayout.AbsoluteContentSize.Y + 10)
end

UpdatePlayers()
Players.PlayerAdded:Connect(UpdatePlayers)
Players.PlayerRemoving:Connect(UpdatePlayers)

-- ═══════════════════════════════════════════════════════════════════════
-- Control Tab
-- ═══════════════════════════════════════════════════════════════════════

local ControlScroll = Instance.new("ScrollingFrame", ControlTab)
ControlScroll.Size = UDim2.new(1, 0, 1, 0)
ControlScroll.BackgroundTransparency = 1
ControlScroll.ScrollBarThickness = 4
ControlScroll.ScrollBarImageColor3 = Colors.Accent

local ControlLayout = Instance.new("UIListLayout", ControlScroll)
ControlLayout.Padding = UDim.new(0, 10)
ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateControlBtn(text, txtColor, callback)
    local frame = Instance.new("Frame", ControlScroll)
    frame.Size = UDim2.new(0.95, 0, 0, 48)
    frame.BackgroundColor3 = Colors.PanelBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = txtColor or Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- ═══════════════════════════════════════════════════════════════════════
-- Control Buttons
-- ═══════════════════════════════════════════════════════════════════════

CreateControlBtn("Hide Roblox Chat", Colors.Yellow, function()
    pcall(function()
        local chatFrame = LocalPlayer.PlayerGui:FindFirstChild("Chat")
        if chatFrame then
            chatFrame.Enabled = false
        end
        for _, bubble in ipairs(workspace:GetDescendants()) do
            if bubble.Name == "BubbleChat" or bubble.Name == "ChatBubble" then
                bubble.Enabled = false
            end
        end
    end)
end)

CreateControlBtn("Show Roblox Chat", Colors.Accent, function()
    pcall(function()
        local chatFrame = LocalPlayer.PlayerGui:FindFirstChild("Chat")
        if chatFrame then
            chatFrame.Enabled = true
        end
        for _, bubble in ipairs(workspace:GetDescendants()) do
            if bubble.Name == "BubbleChat" or bubble.Name == "ChatBubble" then
                bubble.Enabled = true
            end
        end
    end)
end)

CreateControlBtn("Control Player", Colors.Accent)
CreateControlBtn("Start Spin", Colors.Accent)
CreateControlBtn("Stop Spin", Colors.Red)
CreateControlBtn("Anti Logs", Colors.Blue)
CreateControlBtn("Modified Copy", Colors.Accent)
CreateControlBtn("Control AllK", Colors.Accent)

ControlScroll.CanvasSize = UDim2.new(0, 0, 0, ControlLayout.AbsoluteContentSize.Y + 20)

-- ═══════════════════════════════════════════════════════════════════════
-- Spam Commands by Mode
-- ═══════════════════════════════════════════════════════════════════════

local function GetSpamCommands(mode, playerName)
    local name = playerName
    if mode == "Normal" then
        return {
            AdminPrefix .. "cmdbar " .. name,
            AdminPrefix .. "logs " .. name,
            AdminPrefix .. "nv " .. name,
            AdminPrefix .. "tp " .. name,
            AdminPrefix .. "res " .. name,
            AdminPrefix .. "fling " .. name,
            AdminPrefix .. "jail " .. name,
            AdminPrefix .. "name " .. name,
            AdminPrefix .. "ice " .. name,
            AdminPrefix .. "Char miri " .. name,
            AdminPrefix .. "dog " .. name,
            AdminPrefix .. "ping " .. name
        }
    elseif mode == "Ghost" then
        return {
            AdminPrefix .. "explode " .. name,
            AdminPrefix .. "warp " .. name,
            AdminPrefix .. "freeze " .. name,
            AdminPrefix .. "volume " .. name,
            AdminPrefix .. "cmdbar " .. name,
            AdminPrefix .. "logs " .. name,
            AdminPrefix .. "nv " .. name,
            AdminPrefix .. "res " .. name,
            AdminPrefix .. "fling " .. name,
            AdminPrefix .. "jail " .. name,
            AdminPrefix .. "name " .. name,
            AdminPrefix .. "ice " .. name,
            AdminPrefix .. "Char miri " .. name,
            AdminPrefix .. "dog " .. name,
            AdminPrefix .. "ping " .. name
        }
    elseif mode == "Head Admin" then
        return {
            AdminPrefix .. "explode " .. name,
            AdminPrefix .. "volume " .. name,
            AdminPrefix .. "cmdbar " .. name,
            AdminPrefix .. "logs " .. name,
            AdminPrefix .. "nv " .. name,
            AdminPrefix .. "res " .. name,
            AdminPrefix .. "fling " .. name,
            AdminPrefix .. "jail " .. name,
            AdminPrefix .. "name " .. name,
            AdminPrefix .. "ice " .. name,
            AdminPrefix .. "Char miri " .. name,
            AdminPrefix .. "dog " .. name,
            AdminPrefix .. "ping " .. name
        }
    end
    return {}
end

-- ═══════════════════════════════════════════════════════════════════════
-- Spam Loop Function
-- ═══════════════════════════════════════════════════════════════════════

StartSpamBtn.MouseButton1Click:Connect(function()
    if not SelectedPlayer then
        StatusLabel.Text = "Select a player first"
        return
    end

    if SpamActive then
        StatusLabel.Text = "Spam already running!"
        return
    end

    SpamActive = true
    StartSpamBtn.Text = "Running..."
    StartSpamBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    StatusLabel.Text = "Spam " .. CurrentSpamMode .. " on: " .. SelectedPlayer.Name

    SpamThread = task.spawn(function()
        while SpamActive do
            local cmds = GetSpamCommands(CurrentSpamMode, SelectedPlayer.Name)
            for _, cmd in ipairs(cmds) do
                if not SpamActive then break end
                SendVirtualMessage(cmd)
                task.wait(0.15)
            end
            task.wait(0.5)
        end
    end)
end)

StopSpamBtn.MouseButton1Click:Connect(function()
    SpamActive = false
    StartSpamBtn.Text = "> Start Spam"
    StartSpamBtn.BackgroundColor3 = Colors.Accent
    StatusLabel.Text = "Spam stopped"
end)

-- ═══════════════════════════════════════════════════════════════════════
-- Float Button
-- ═══════════════════════════════════════════════════════════════════════

local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0.02, 0, 0.45, -27)
FloatBtn.BackgroundColor3 = Colors.AccentDark
FloatBtn.Text = "A_A"
FloatBtn.TextColor3 = Colors.White
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 18
FloatBtn.Draggable = true
FloatBtn.ZIndex = 5
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatBtn).Color = Colors.Accent
Instance.new("UIStroke", FloatBtn).Thickness = 2

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ═══════════════════════════════════════════════════════════════════════
-- Done
-- ═══════════════════════════════════════════════════════════════════════

print("A_A Panel Ready! | Loop Spam + HD Admin Active")
print("Credits to Remote Detector")
