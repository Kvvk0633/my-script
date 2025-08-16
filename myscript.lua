local speed = 5
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local flying = false
local bv, bg

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
    while flying do
        task.wait()
        local move = Vector3.new()
        if plr:GetMouse().W then move = move + cam.CFrame.LookVector end
        if plr:GetMouse().S then move = move - cam.CFrame.LookVector end
        if plr:GetMouse().A then move = move - cam.CFrame.RightVector end
        if plr:GetMouse().D then move = move + cam.CFrame.RightVector end
        bv.Velocity = move.Magnitude > 0 and move.Unit * speed or Vector3.new(0,0,0)
        bg.CFrame = cam.CFrame
    end
end

function unfly()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then unfly() else fly() end
    elseif input.KeyCode == Enum.KeyCode.Equals then
        speed = speed + 2
        print("Speed:", speed)
    elseif input.KeyCode == Enum.KeyCode.Minus then
        speed = math.max(2, speed - 2)
        print("Speed:", speed)
    end
end)

print("Fly script loaded! กด F เพื่อบิน, = เพิ่มสปีด, - ลดสปีด")

