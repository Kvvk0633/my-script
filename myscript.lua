-- Fly & NoClip UI แยก (Modern/Neumorphism Style UI) มือถือ/PC/Delta

local defaultSpeed, minSpeed, maxSpeed = 80, 10, 200
local flySpeed, flying, noclipping = defaultSpeed, false, false

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- สร้าง MainFrame
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "FlyNoClipUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 210)
mainFrame.Position = UDim2.new(0, 30, 1, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = scrnGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 22)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(85, 170, 255)
mainStroke.Transparency = 0.2

local shadow = Instance.new("ImageLabel", mainFrame)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.new(1, 32, 1, 32)
shadow.Position = UDim2.new(0, -16, 0, -16)
shadow.ZIndex = 0
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7

local function makeButton(name, pos, text, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 105, 0, 48)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color or Color3.fromRGB(40, 120, 250)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundTransparency = 0
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.AutoButtonColor = true
    b.ZIndex = 2

    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 18)

    local stroke = Instance.new("UIStroke", b)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.7

    local grad = Instance.new("UIGradient", b)
    grad.Rotation = 90
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, b.BackgroundColor3)
    }
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 0.0),
    }
    return b
end

local flyBtn = makeButton("FlyBtn", UDim2.new(0, 18, 0, 18), "บิน", Color3.fromRGB(40, 130, 255))
flyBtn.Parent = mainFrame
local noclipBtn = makeButton("NoClipBtn", UDim2.new(0, 177, 0, 18), "NoClip", Color3.fromRGB(60, 200, 110))
noclipBtn.Parent = mainFrame

local speedUpBtn = makeButton("SpeedUpBtn", UDim2.new(0, 18, 0, 78), "+", Color3.fromRGB(110, 160, 250))
speedUpBtn.Size = UDim2.new(0, 55, 0, 40)
speedUpBtn.Parent = mainFrame
local speedDownBtn = makeButton("SpeedDownBtn", UDim2.new(0, 78, 0, 78), "-", Color3.fromRGB(110, 160, 250))
speedDownBtn.Size = UDim2.new(0, 55, 0, 40)
speedDownBtn.Parent = mainFrame

local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 18, 0, 130)
infoLabel.Size = UDim2.new(0, 264, 0, 58)
infoLabel.BackgroundTransparency = 0.15
infoLabel.BackgroundColor3 = Color3.fromRGB(60, 75, 100)
infoLabel.TextColor3 = Color3.fromRGB(255,255,255)
infoLabel.Font = Enum.Font.GothamSemibold
infoLabel.TextScaled = true
infoLabel.Text = "Fly: OFF | NoClip: OFF | Speed: "..flySpeed
infoLabel.ZIndex = 2
local infoCorner = Instance.new("UICorner", infoLabel)
infoCorner.CornerRadius = UDim.new(0, 16)
local infoStroke = Instance.new("UIStroke", infoLabel)
infoStroke.Thickness = 1
infoStroke.Color = Color3.fromRGB(180,220,255)
infoStroke.Transparency = 0.5

local bv, bg, flyConn, noclipConn

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").."   |   NoClip: "..(noclipping and "ON" or "OFF").."   |   Speed: "..flySpeed
end

-- NoClip แบบแรงสุด
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

-- รีเซ็ต NoClip/Fly เมื่อ respawn
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:FindFirstChildOfClass("Humanoid")
    stopFly()
    stopNoClip()
    flyBtn.Text = "บิน"
    noclipBtn.Text = "NoClip"
end)

print("Fly & NoClip UI (Modern Style) loaded! เปิด/ปิดแยกได้ กด F = Fly, N = NoClip, + - = Speed")
