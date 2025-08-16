-- Fly Script Roblox (Mobile Touch UI + Keyboard) ใช้ได้กับมือถือและ PC
-- ปุ่ม: Fly/Stop, Up, Down, +Speed, -Speed
-- สำหรับแมพส่วนใหญ่ (แต่บางแมพที่ล็อคฟิสิกส์/anti-cheat อาจใช้ไม่ได้)

-- CONFIG
local defaultSpeed = 50
local minSpeed = 10
local maxSpeed = 200

-- STATE
local flySpeed = defaultSpeed
local flying = false
local controls = {f = false, b = false, l = false, r = false, u = false, d = false}
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")

-- GUI
local function makeButton(name, pos, size, text, parent)
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
    b.Parent = parent
    return b
end

local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "MobileFlyGUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = game.CoreGui or player.PlayerGui

local flyBtn = makeButton("FlyBtn", Vector2.new(30, 200), Vector2.new(100, 50), "บิน", scrnGui)
local upBtn = makeButton("UpBtn", Vector2.new(140, 140), Vector2.new(50, 50), "⬆️", scrnGui)
local downBtn = makeButton("DownBtn", Vector2.new(140, 200), Vector2.new(50, 50), "⬇️", scrnGui)
local speedUpBtn = makeButton("SpeedUpBtn", Vector2.new(30, 140), Vector2.new(50, 50), "+", scrnGui)
local speedDownBtn = makeButton("SpeedDownBtn", Vector2.new(90, 140), Vector2.new(50, 50), "-", scrnGui)
local infoLabel = Instance.new("TextLabel", scrnGui)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 30, 0, 270)
infoLabel.Size = UDim2.new(0, 160, 0, 30)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.new(1,1,1)
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextScaled = true
infoLabel.Text = "Fly: OFF | Speed: "..flySpeed

-- FLY FUNCTION
local bv, bg

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").." | Speed: "..flySpeed
end

function fly()
    if flying then return end
    flying = true
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.P = 1e4
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    local cam = workspace.CurrentCamera

    task.spawn(function()
        while flying and bv and bg and bv.Parent and bg.Parent do
            task.wait()
            local move = Vector3.new()
            if controls.f then move = move + cam.CFrame.LookVector end
            if controls.b then move = move - cam.CFrame.LookVector end
            if controls.l then move = move - cam.CFrame.RightVector end
            if controls.r then move = move + cam.CFrame.RightVector end
            if controls.u then move = move + Vector3.new(0,1,0) end
            if controls.d then move = move - Vector3.new(0,1,0) end

            if move.Magnitude > 0 then
                bv.Velocity = move.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0,0,0)
            end
            bg.CFrame = cam.CFrame
        end
    end)
    updateInfo()
end

function stopFly()
    flying = false
    if bv then pcall(function() bv:Destroy() end) end
    if bg then pcall(function() bg:Destroy() end) end
    updateInfo()
end

-- BUTTON EVENTS
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyBtn.Text = "บิน"
    else
        fly()
        flyBtn.Text = "หยุดบิน"
    end
end)

upBtn.MouseButton1Down:Connect(function() controls.u = true end)
upBtn.MouseButton1Up:Connect(function() controls.u = false end)
downBtn.MouseButton1Down:Connect(function() controls.d = true end)
downBtn.MouseButton1Up:Connect(function() controls.d = false end)
speedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = math.min(maxSpeed, flySpeed + 10)
    updateInfo()
end)
speedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(minSpeed, flySpeed - 10)
    updateInfo()
end)

-- KEYBOARD SUPPORT (PC)
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFly()
            flyBtn.Text = "บิน"
        else
            fly()
            flyBtn.Text = "หยุดบิน"
        end
    elseif i.KeyCode == Enum.KeyCode.W then controls.f = true
    elseif i.KeyCode == Enum.KeyCode.S then controls.b = true
    elseif i.KeyCode == Enum.KeyCode.A then controls.l = true
    elseif i.KeyCode == Enum.KeyCode.D then controls.r = true
    elseif i.KeyCode == Enum.KeyCode.Space then controls.u = true
    elseif i.KeyCode == Enum.KeyCode.LeftControl then controls.d = true
    elseif i.KeyCode == Enum.KeyCode.Equals then
        flySpeed = math.min(maxSpeed, flySpeed + 10)
        updateInfo()
    elseif i.KeyCode == Enum.KeyCode.Minus then
        flySpeed = math.max(minSpeed, flySpeed - 10)
        updateInfo()
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then controls.f = false
    elseif i.KeyCode == Enum.KeyCode.S then controls.b = false
    elseif i.KeyCode == Enum.KeyCode.A then controls.l = false
    elseif i.KeyCode == Enum.KeyCode.D then controls.r = false
    elseif i.KeyCode == Enum.KeyCode.Space then controls.u = false
    elseif i.KeyCode == Enum.KeyCode.LeftControl then controls.d = false
    end
end)
