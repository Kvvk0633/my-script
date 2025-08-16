-- ASTD X Macro Recorder: จับเวลาจริงและตำแหน่งจริงการ spawn ยูนิตในแมพ (จับยูนิตที่ spawn บนสนาม)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local macroSteps = {}
local recording = false
local macroStartTime = nil
local selectedSlot = nil
local unitFolderName = "Units" -- เปลี่ยนชื่อถ้า ASTD X ใช้ชื่ออื่น

-- UI Modern Minimal
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "ASTDX_MacroUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 370, 0, 138)
mainFrame.Position = UDim2.new(0.5, -185, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 30, 44)
mainFrame.BackgroundTransparency = 0.18
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = scrnGui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 16)
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.ZIndex = 0
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "ASTD X Macro Recorder"
title.TextColor3 = Color3.fromRGB(210, 225, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center

local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 12, 0, 48)
infoLabel.Size = UDim2.new(1, -24, 0, 32)
infoLabel.BackgroundTransparency = 0.12
infoLabel.BackgroundColor3 = Color3.fromRGB(42, 56, 72)
infoLabel.TextColor3 = Color3.fromRGB(220,235,255)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextScaled = true
infoLabel.TextWrapped = false
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Text = "Macro: 0 steps | Not recording"
local infoCorner = Instance.new("UICorner", infoLabel)
infoCorner.CornerRadius = UDim.new(0, 9)

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
    corner.CornerRadius = UDim.new(0, 10)
    return b
end

local recBtn = makeButton("RecBtn", UDim2.new(0, 12, 0, 90), UDim2.new(0, 100, 0, 38), "● Record", Color3.fromRGB(230, 60, 60))
recBtn.Parent = mainFrame
local resetBtn = makeButton("ResetBtn", UDim2.new(0, 128, 0, 90), UDim2.new(0, 80, 0, 38), "Reset", Color3.fromRGB(90, 100, 140))
resetBtn.Parent = mainFrame
local exportBtn = makeButton("ExportBtn", UDim2.new(0, 222, 0, 90), UDim2.new(0, 120, 0, 38), "Copy Macro", Color3.fromRGB(44,144,255))
exportBtn.Parent = mainFrame

local function updateInfo()
    infoLabel.Text = (recording and "● Recording" or "Macro: "..#macroSteps.." steps | Not recording")
    if #macroSteps > 0 then
        local last = macroSteps[#macroSteps]
        infoLabel.Text = infoLabel.Text..(" | [#%d] U%s @%.2fs (%d,%d,%d)")
            :format(last.index, last.unitSlot or "?", last.time, math.floor(last.pos.X), math.floor(last.pos.Y), math.floor(last.pos.Z))
    end
end

local function resetMacro()
    macroSteps = {}
    macroStartTime = nil
    selectedSlot = nil
    updateInfo()
end

-- Drag UI
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        local scrSize = scrnGui.AbsoluteSize
        local frmSize = mainFrame.AbsoluteSize
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, scrSize.X - frmSize.X)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, scrSize.Y - frmSize.Y)
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

-- Step 1: จำ slot ที่เลือก (1-6)
UIS.InputBegan:Connect(function(input, gpe)
    if not recording or gpe then return end
    local slot = nil
    if input.KeyCode == Enum.KeyCode.One then slot = 1
    elseif input.KeyCode == Enum.KeyCode.Two then slot = 2
    elseif input.KeyCode == Enum.KeyCode.Three then slot = 3
    elseif input.KeyCode == Enum.KeyCode.Four then slot = 4
    elseif input.KeyCode == Enum.KeyCode.Five then slot = 5
    elseif input.KeyCode == Enum.KeyCode.Six then slot = 6 end
    if slot then
        selectedSlot = slot
    end
end)

-- Step 2: ฟัง event spawn ยูนิตใน Workspace.Units (หรือ path ที่ตรงกับเกมจริง)
local function isMyUnit(unit)
    -- ASTD X มักจะมี property หรือชื่อ/owner ตรงกับ local player
    -- ตัวอย่าง: unit.Owner == player หรือ unit.Name:find(player.Name) หรือ Parent เป็นของ userId
    if unit:FindFirstChild("Owner") and tostring(unit.Owner.Value) == player.Name then
        return true
    end
    if unit.Name:find(player.Name) or unit.Name:find(player.UserId) then
        return true
    end
    -- เพิ่ม logic เช็คยูนิตของเราเองได้ตาม ASTD X จริง
    return false
end

if Workspace:FindFirstChild(unitFolderName) then
    Workspace[unitFolderName].ChildAdded:Connect(function(unit)
        if not recording then return end
        -- เช็คว่าเป็นยูนิตของเราและมี position
        if isMyUnit(unit) and selectedSlot then
            local t = tick()
            if not macroStartTime then macroStartTime = t end
            local index = #macroSteps + 1
            local pos = unit.PrimaryPart and unit.PrimaryPart.Position or (unit:IsA("BasePart") and unit.Position or unit.Position or Vector3.new(0,0,0))
            table.insert(macroSteps, {
                index = index,
                time = (t - macroStartTime),
                unitSlot = selectedSlot,
                pos = pos
            })
            updateInfo()
            selectedSlot = nil -- ต้องเลือก slot ใหม่ทุกครั้ง
        end
    end)
else
    warn("หา Workspace.Units ไม่เจอ! กรุณาตรวจสอบชื่อโฟลเดอร์ยูนิตในแมพ ASTD X")
end

recBtn.MouseButton1Click:Connect(function()
    recording = not recording
    recBtn.Text = recording and "■ Stop" or "● Record"
    updateInfo()
end)
resetBtn.MouseButton1Click:Connect(function()
    resetMacro()
    recBtn.Text = "● Record"
    recording = false
end)
exportBtn.MouseButton1Click:Connect(function()
    if #macroSteps > 0 then
        -- Export เป็น Lua Table
        local result = "local macro = {\n"
        for _, step in ipairs(macroSteps) do
            result = result .. string.format(
                "  {index=%d, time=%.2f, unitSlot=%d, pos=Vector3.new(%.2f, %.2f, %.2f)},\n",
                step.index, step.time, step.unitSlot, step.pos.X, step.pos.Y, step.pos.Z)
        end
        result = result .. "}\n"
        setclipboard(result)
        exportBtn.Text = "Copied!"
        task.wait(1)
        exportBtn.Text = "Copy Macro"
    end
end)

updateInfo()

print("ASTD X Macro Recorder (จับตำแหน่งยูนิต spawn จริง) loaded! เลือก slot (1-6) แล้ววางยูนิตในเกม จะบันทึกเวลา/slot/ตำแหน่งจริง")
