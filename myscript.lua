-- Superman Fly Script (ทิศทางตรงกล้อง, รองรับ Shift Lock, มือถือ+PC)
-- กด 'บิน' เพื่อเปิด/ปิด, ใช้จอยสติ๊กหรือ WASD เพื่อพุ่งทิศทางตามกล้องจริง
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

        -- ใช้ทิศทางจากกล้อง 100%
        -- WASD หรือจอยสติ๊ก = moveDir (local space) เช่น W = (0,0,-1), S = (0,0,1), A = (-1,0,0), D = (1,0,0)
        -- แปลง moveDir ให้กลายเป็นทิศทางในโลก (world space) ตามกล้อง
        if moveDir.Magnitude > 0 then
            local camCF = cam.CFrame
            -- ตัดแกน Y ออกถ้าต้องการบินแนวระนาบเท่านั้น (ถ้าจะบินขึ้น/ลงด้วย Shift+W ให้ใช้ cam.CFrame.FullVector)
            -- ใช้ LookVector/RightVector/UpVector สร้างทิศทาง world
            local forward = camCF.LookVector
            local right = camCF.RightVector
            local up = camCF.UpVector

            -- ทิศทางสุดท้าย (world) = right * x + forward * z
            local worldDir = (right * moveDir.X + forward * moveDir.Z).Unit
            -- แก้ไขกรณี moveDir.Y (ถ้าอยากให้บินขึ้น/ลงตามจอยสติ๊กมือถือ)
            if moveDir.Y ~= 0 then
                worldDir = ((right * moveDir.X) + (forward * moveDir.Z) + (up * moveDir.Y)).Unit
            end

            bv.Velocity = worldDir * flySpeed
            -- หมุนตัวละครให้หันไปทิศทางที่บิน
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + worldDir)
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
