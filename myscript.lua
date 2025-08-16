-- Superman Fly Script (บินอิสระตามทิศกล้อง/จอยสติ๊ก) มือถือและ PC
-- กด 'บิน' เพื่อเปิด/ปิด, ใช้จอยสติ๊กหรือ WASD เพื่อพุ่งทิศทางที่ต้องการ
-- +/– ปรับสปีด

local defaultSpeed = 80
local minSpeed = 10
local maxSpeed = 200

local flySpeed = defaultSpeed
local flying = false

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI สำหรับมือถือ
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
scrnGui.Name = "SupermanFlyGUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = game.CoreGui or player.PlayerGui

local flyBtn = makeButton("FlyBtn", Vector2.new(30, 200), Vector2.new(100, 50), "บิน", scrnGui)
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

local bv, bg, flyConn

local function updateInfo()
    infoLabel.Text = "Fly: "..(flying and "ON" or "OFF").." | Speed: "..flySpeed
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

    flyConn = RunService.Heartbeat:Connect(function()
        if not flying or not bv or not bg or not bv.Parent or not bg.Parent then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        if humanoid then moveDir = humanoid.MoveDirection end

        -- ถ้าไม่มีการกดเดิน ให้ลอยอยู่กับที่
        if moveDir.Magnitude > 0 then
            -- ทิศทางกล้อง (Superman)
            local camDir = Vector3.new(cam.CFrame.LookVector.X, cam.CFrame.LookVector.Y, cam.CFrame.LookVector.Z)
            -- ทิศของ moveDir จะสัมพันธ์กับกล้อง (มือถือใช้จอยสติ๊ก)
            local flyVec = (cam.CFrame:VectorToWorldSpace(moveDir)).Unit * flySpeed
            bv.Velocity = flyVec
            -- หมุนตัวตามกล้อง
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + flyVec)
        else
            bv.Velocity = Vector3.new(0,0,0)
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
    if flyConn then flyConn:Disconnect() end
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

-- คีย์บอร์ด (PC)
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
