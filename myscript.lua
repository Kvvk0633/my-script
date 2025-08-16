-- Fly & NoClip UI (Maru Style, ไม่มี Sidebar, ปุ่มไม่ล้น, Info ใหญ่, ไม่มีเส้นเงาฟ้า, Drag ได้, มือถือ/PC/Delta)

local defaultSpeed, minSpeed, maxSpeed = 80, 10, 200
local flySpeed, flying, noclipping = defaultSpeed, false, false

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- MainFrame (โปร่งใส, เงา, มุมมน, Drag ได้)
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "FlyNoClipSimpleUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 370, 0, 138)
mainFrame.Position = UDim2.new(0.5, -185, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 30, 44)
mainFrame.BackgroundTransparency = 0.18
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- สำคัญสำหรับ Drag
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

-- ปุ่ม Modern เรียงแนวนอน
local function makeButton(name, pos, size, text, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = size
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
    return b
end

local yBase = 70
local flyBtn = makeButton("FlyBtn", UDim2.new(0, 18, 0, yBase), UDim2.new(0, 88, 0, 38), "บิน", Color3.fromRGB(44,144,255))
flyBtn.Parent = mainFrame
local noclipBtn = makeButton("NoClipBtn", UDim2.new(0, 112, 0, yBase), UDim2.new(0, 88, 0, 38), "NoClip", Color3.fromRGB(60, 200, 110))
noclipBtn.Parent = mainFrame
local speedUpBtn = makeButton("SpeedUpBtn", UDim2.new(0, 206, 0, yBase), UDim2.new(0, 60, 0, 38), "+", Color3.fromRGB(110, 160, 250))
speedUpBtn.Parent = mainFrame
local speedDownBtn = makeButton("SpeedDownBtn", UDim2.new(0, 272, 0, yBase), UDim2.new(0, 60, 0, 38), "-", Color3.fromRGB(110, 160, 250))
speedDownBtn.Parent = mainFrame

-- InfoLabel ใหญ่ขึ้น ไม่มี Stroke/เงาสีฟ้า
local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 18, 0, 18)
infoLabel.Size = UDim2.new(1, -36, 0, 42)
infoLabel.BackgroundTransparency = 0.12
infoLabel.BackgroundColor3 = Color3.fromRGB(42, 56, 72)
infoLabel.TextColor3 = Color3.fromRGB(220,235,255)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextScaled = true
infoLabel.TextWrapped = false
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.TextYAlignment = Enum.TextYAlignment.Center
infoLabel.Text = "Fly: OFF   |   NoClip: OFF   |   Speed: 80"
local infoCorner = Instance.new("UICorner", infoLabel)
infoCorner.CornerRadius = UDim.new(0, 13)

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

-- Fly & NoClip Logic
local bv, bg, flyConn, noclipConn

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").."   |   NoClip: "..(noclipping and "ON" or "OFF").."   |   Speed: "..flySpeed
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

print("Fly & NoClip UI (Maru Style, No Sidebar, Info ใหญ่, Drag ได้, ไม่มี Stroke ฟ้า) loaded!")
