-- Superman Fly + NoClip (ทะลุทุกสิ่ง, มือถือ/PC/Delta)
-- ปุ่ม "บิน" เปิด/ปิด, เดินหน้าหรือจอยสติ๊ก = พุ่งไปทางกล้อง, +/– ปรับสปีด

local defaultSpeed, minSpeed, maxSpeed = 80, 10, 200
local flySpeed, flying = defaultSpeed, false

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI ใน PlayerGui
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "SupermanFlyNoClipGUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local function makeButton(name, pos, size, text)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, size.X, 0, size.Y)
    b.Position = UDim2.new(0, pos.X, 0, pos.Y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.Font = Enum.Font.SourceSansBold
    b.TextScaled = true
    b.AutoButtonColor = true
    b.Parent = scrnGui
    return b
end

local flyBtn = makeButton("FlyBtn", Vector2.new(30, 200), Vector2.new(100, 50), "บิน")
local speedUpBtn = makeButton("SpeedUpBtn", Vector2.new(30, 140), Vector2.new(50, 50), "+")
local speedDownBtn = makeButton("SpeedDownBtn", Vector2.new(90, 140), Vector2.new(50, 50), "-")
local infoLabel = Instance.new("TextLabel", scrnGui)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 30, 0, 270)
infoLabel.Size = UDim2.new(0, 160, 0, 30)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.new(1,1,1)
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextScaled = true
infoLabel.Text = "Fly: OFF | Speed: "..flySpeed

local bv, bg, flyConn, noclipConn

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").." | Speed: "..flySpeed
end

-- NoClip: ปิด Collision ตลอดเวลาบิน
local function setNoClip(state)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide ~= not state then
            part.CanCollide = not state
        end
    end
end

function startFly()
    if flying then return end
    flying = true
    if humanoid then
        humanoid.PlatformStand = true
    end
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P = 1e4
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    -- เปิด NoClip ตลอดเวลาบิน
    setNoClip(true)
    noclipConn = RunService.Stepped:Connect(function()
        if flying then
            setNoClip(true)
        end
    end)

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
    if noclipConn then noclipConn:Disconnect() end
    if bv then pcall(function() bv:Destroy() end) end
    if bg then pcall(function() bg:Destroy() end) end
    -- คืน Collision ทุกชิ้นส่วน
    setNoClip(false)
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
    elseif i.KeyCode == Enum.KeyCode.Equals then
        flySpeed = math.min(maxSpeed, flySpeed + 10)
        updateInfo()
    elseif i.KeyCode == Enum.KeyCode.Minus then
        flySpeed = math.max(minSpeed, flySpeed - 10)
        updateInfo()
    end
end)

print("Superman Fly + NoClip loaded! กด 'บิน' แล้วเดินหน้าหรือจอยสติ๊กเพื่อพุ่งทะลุสิ่งกีดขวางไปทางกล้อง")
