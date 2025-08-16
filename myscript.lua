-- Fly Script (เดิน/จอยสติ๊กควบคุมทิศทาง) รองรับมือถือและ PC
-- ปุ่ม: บิน/หยุดบิน, ขึ้น⬆️, ลง⬇️, +Speed, -Speed

local defaultSpeed = 50
local minSpeed = 10
local maxSpeed = 200

local flySpeed = defaultSpeed
local flying = false
local up = false
local down = false

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- สร้าง GUI มือถือ
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

-- ตัวแปร BodyMover
local bv, bg

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").." | Speed: "..flySpeed
end

function fly()
    if flying then return end
    flying = true

    if humanoid then
        humanoid.PlatformStand = true -- ป้องกันไม่ให้ร่างกายถูกฟิสิกส์ปกติรบกวน
    end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.P = 1e4
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    -- ควบคุมการบินด้วยการเดิน (MoveDirection)
    RunService.RenderStepped:Connect(function()
        if flying and bv and bg and bv.Parent and bg.Parent then
            local cam = workspace.CurrentCamera
            local move = humanoid and humanoid.MoveDirection or Vector3.new()
            local moveVec = Vector3.new()
            if move.Magnitude > 0 then
                -- บินตามทิศทางเดิน
                moveVec = move.Unit * flySpeed
            end
            -- เพิ่มขึ้น/ลง (Y) ตามปุ่ม
            if up then moveVec = moveVec + Vector3.new(0, flySpeed, 0) end
            if down then moveVec = moveVec + Vector3.new(0, -flySpeed, 0) end

            bv.Velocity = moveVec
            bg.CFrame = cam.CFrame
        end
    end)
    updateInfo()
end

function stopFly()
    flying = false
    if humanoid then
        humanoid.PlatformStand = false
    end
    if bv then pcall(function() bv:Destroy() end) end
    if bg then pcall(function() bg:Destroy() end) end
    updateInfo()
end

-- ปุ่มมือถือ
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyBtn.Text = "บิน"
    else
        fly()
        flyBtn.Text = "หยุดบิน"
    end
end)
upBtn.MouseButton1Down:Connect(function() up = true end)
upBtn.MouseButton1Up:Connect(function() up = false end)
downBtn.MouseButton1Down:Connect(function() down = true end)
downBtn.MouseButton1Up:Connect(function() down = false end)
speedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = math.min(maxSpeed, flySpeed + 10)
    updateInfo()
end)
speedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(minSpeed, flySpeed - 10)
    updateInfo()
end)

-- ปุ่มคีย์บอร์ด (PC)
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
    elseif i.KeyCode == Enum.KeyCode.Space then up = true
    elseif i.KeyCode == Enum.KeyCode.LeftControl then down = true
    elseif i.KeyCode == Enum.KeyCode.Equals then
        flySpeed = math.min(maxSpeed, flySpeed + 10)
        updateInfo()
    elseif i.KeyCode == Enum.KeyCode.Minus then
        flySpeed = math.max(minSpeed, flySpeed - 10)
        updateInfo()
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then up = false
    elseif i.KeyCode == Enum.KeyCode.LeftControl then down = false
    end
end)
