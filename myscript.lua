-- Maru Hub Style Fly & NoClip UI (โปร่งใส, เงา, มุมมน, Drag ได้, Sidebar, Modern)
-- สามารถนำไปต่อยอดใส่ฟีเจอร์เพิ่มได้

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI MainFrame
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "FlyNoClipMaruUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 410, 0, 340)
mainFrame.Position = UDim2.new(0.5, -205, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 30, 44)
mainFrame.BackgroundTransparency = 0.18
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = scrnGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 18)

local shadow = Instance.new("ImageLabel", mainFrame)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.ZIndex = 0
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.75

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 70, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(27, 39, 59)
sidebar.BackgroundTransparency = 0.18
sidebar.BorderSizePixel = 0
local sidebarCorner = Instance.new("UICorner", sidebar)
sidebarCorner.CornerRadius = UDim.new(0, 16)

-- (Optional) Logo
local logo = Instance.new("ImageLabel", sidebar)
logo.Name = "Logo"
logo.Size = UDim2.new(0, 54, 0, 54)
logo.Position = UDim2.new(0, 8, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://7733960981" -- ตัวอย่างโลโก้/เปลี่ยนได้

-- Sidebar buttons (icon only for demo)
local sidebarBtns = {
    {name="Main", icon="rbxassetid://6031094670"},
    {name="Items", icon="rbxassetid://6031265976"},
    {name="Shop", icon="rbxassetid://6031075938"},
    {name="Visual", icon="rbxassetid://6031071050"},
    {name="Settings", icon="rbxassetid://6031280882"},
}
for i, data in ipairs(sidebarBtns) do
    local btn = Instance.new("ImageButton", sidebar)
    btn.Name = data.name.."Btn"
    btn.Size = UDim2.new(0, 34, 0, 34)
    btn.Position = UDim2.new(0, 18, 0, 70 + (i-1)*38)
    btn.BackgroundTransparency = 1
    btn.Image = data.icon
    btn.ImageColor3 = Color3.fromRGB(160, 185, 255)
    btn.AutoButtonColor = true
end

-- Content Frame
local content = Instance.new("Frame", mainFrame)
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.new(0, 76, 0, 0)
content.Size = UDim2.new(1, -76, 1, 0)

-- Title
local title = Instance.new("TextLabel", content)
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Main"
title.TextColor3 = Color3.fromRGB(210, 225, 255)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left

-- Subtitle
local subtitle = Instance.new("TextLabel", content)
subtitle.Size = UDim2.new(1, -20, 0, 22)
subtitle.Position = UDim2.new(0, 10, 0, 50)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Settings"
subtitle.TextColor3 = Color3.fromRGB(150, 180, 255)
subtitle.Font = Enum.Font.GothamSemibold
subtitle.TextScaled = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม Fly/NoClip/Speed
local function makeModernBtn(name, pos, text, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 120, 0, 36)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color or Color3.fromRGB(44, 144, 255)
    b.TextColor3 = Color3.fromRGB(240,255,255)
    b.BackgroundTransparency = 0.09
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.AutoButtonColor = true
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", b)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(200,220,255)
    stroke.Transparency = 0.45
    return b
end

local flyBtn = makeModernBtn("FlyBtn", UDim2.new(0, 12, 0, 85), "บิน", Color3.fromRGB(44,144,255))
flyBtn.Parent = content
local noclipBtn = makeModernBtn("NoClipBtn", UDim2.new(0, 142, 0, 85), "NoClip", Color3.fromRGB(60, 200, 110))
noclipBtn.Parent = content
local speedUpBtn = makeModernBtn("SpeedUpBtn", UDim2.new(0, 272, 0, 85), "+", Color3.fromRGB(110, 160, 250))
speedUpBtn.Size = UDim2.new(0, 56, 0, 36)
speedUpBtn.Parent = content
local speedDownBtn = makeModernBtn("SpeedDownBtn", UDim2.new(0, 334, 0, 85), "-", Color3.fromRGB(110, 160, 250))
speedDownBtn.Size = UDim2.new(0, 32, 0, 36)
speedDownBtn.Parent = content

-- InfoLabel (บรรทัดเดียว)
local infoLabel = Instance.new("TextLabel", content)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 14, 0, 135)
infoLabel.Size = UDim2.new(1, -24, 0, 28)
infoLabel.BackgroundTransparency = 0.16
infoLabel.BackgroundColor3 = Color3.fromRGB(60, 75, 100)
infoLabel.TextColor3 = Color3.fromRGB(205,230,255)
infoLabel.Font = Enum.Font.GothamSemibold
infoLabel.TextScaled = true
infoLabel.TextWrapped = false
infoLabel.ClipsDescendants = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Text = "Fly: OFF | NoClip: OFF | Speed: 80"
local infoCorner = Instance.new("UICorner", infoLabel)
infoCorner.CornerRadius = UDim.new(0, 10)
local infoStroke = Instance.new("UIStroke", infoLabel)
infoStroke.Thickness = 1
infoStroke.Color = Color3.fromRGB(180,220,255)
infoStroke.Transparency = 0.5

-- Drag (Touch+Mouse)
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, scrnGui.AbsoluteSize.X - mainFrame.AbsoluteSize.X)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, scrnGui.AbsoluteSize.Y - mainFrame.AbsoluteSize.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Fly & NoClip Logic (เหมือนเวอร์ชันล่าสุด)
local defaultSpeed, minSpeed, maxSpeed = 80, 10, 200
local flySpeed, flying, noclipping = defaultSpeed, false, false
local bv, bg, flyConn, noclipConn

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").." | NoClip: "..(noclipping and "ON" or "OFF").." | Speed: "..flySpeed
end

local function strongNoClip()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            if part:IsA("MeshPart") then part.CanTouch = false end
        end
    end
end

local function resetCollide()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            if part:IsA("MeshPart") then part.CanTouch = true end
        end
    end
end

function startFly()
    if flying then return end
    flying = true
    if humanoid then humanoid.PlatformStand = true end
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P = 1e4
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    flyConn = RunService.Heartbeat:Connect(function()
        if not flying or not bv or not bg or not bv.Parent or not bg.Parent then return end
        local cam = workspace.CurrentCamera
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.new()
        if moveDir.Magnitude > 0 then
            local look = cam.CFrame.LookVector
            bv.Velocity = look.Unit * flySpeed
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
        else
            bv.Velocity = Vector3.new(0,0,0)
            bg.CFrame = cam.CFrame
        end
    end)
    updateInfo()
end

function stopFly()
    flying = false
    if humanoid then humanoid.PlatformStand = false end
    if flyConn then flyConn:Disconnect() end
    if bv then pcall(function() bv:Destroy() end) end
    if bg then pcall(function() bg:Destroy() end) end
    updateInfo()
end

function startNoClip()
    if noclipping then return end
    noclipping = true
    strongNoClip()
    noclipConn = RunService.Stepped:Connect(strongNoClip)
    updateInfo()
end

function stopNoClip()
    noclipping = false
    if noclipConn then noclipConn:Disconnect() end
    resetCollide()
    updateInfo()
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyBtn.Text = "บิน"
    else
        startFly()
        flyBtn.Text = "หยุดบิน"
    end
end)
noclipBtn.MouseButton1Click:Connect(function()
    if noclipping then
        stopNoClip()
        noclipBtn.Text = "NoClip"
    else
        startNoClip()
        noclipBtn.Text = "หยุด NoClip"
    end
end)
speedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = math.min(maxSpeed, flySpeed + 10)
    updateInfo()
end)
speedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(minSpeed, flySpeed - 10)
    updateInfo()
end)

UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFly()
            flyBtn.Text = "บิน"
        else
            startFly()
            flyBtn.Text = "หยุดบิน"
        end
    elseif i.KeyCode == Enum.KeyCode.N then
        if noclipping then
            stopNoClip()
            noclipBtn.Text = "NoClip"
        else
            startNoClip()
            noclipBtn.Text = "หยุด NoClip"
        end
    elseif i.KeyCode == Enum.KeyCode.Equals then
        flySpeed = math.min(maxSpeed, flySpeed + 10)
        updateInfo()
    elseif i.KeyCode == Enum.KeyCode.Minus then
        flySpeed = math.max(minSpeed, flySpeed - 10)
        updateInfo()
    end
end)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:FindFirstChildOfClass("Humanoid")
    stopFly()
    stopNoClip()
    flyBtn.Text = "บิน"
    noclipBtn.Text = "NoClip"
end)

print("Maru Hub Style UI loaded! Drag ได้, Fly/NoClip มี Info ชัดเจน, สวยงามแบบในภาพ")
