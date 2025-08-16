-- Tower Defense Macro Recorder (UI Modern, Drag ได้, อัด Macro ช่อง 1-6, เวลา, ตำแหน่ง, Info index)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- UI Modern
local scrnGui = Instance.new("ScreenGui")
scrnGui.Name = "TD_MacroUI"
scrnGui.ResetOnSpawn = false
scrnGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 370, 0, 200)
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

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Tower Defense Macro Recorder"
title.TextColor3 = Color3.fromRGB(210, 225, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center

-- Macro Info
local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Name = "InfoLabel"
infoLabel.Position = UDim2.new(0, 12, 0, 48)
infoLabel.Size = UDim2.new(1, -24, 0, 30)
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

-- Buttons
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

-- Macro Logic
local macroSteps = {}
local recording = false
local macroStartTime = nil

local function updateInfo()
    infoLabel.Text = (recording and "● Recording" or "Macro: "..#macroSteps.." steps | Not recording")
    if #macroSteps > 0 then
        local last = macroSteps[#macroSteps]
        infoLabel.Text = infoLabel.Text..(" | Last: [#%d] U%s at %.2fs (%d,%d,%d)")
            :format(last.index, last.unitSlot, last.time, math.floor(last.pos.X), math.floor(last.pos.Y), math.floor(last.pos.Z))
    end
end

local function resetMacro()
    macroSteps = {}
    macroStartTime = nil
    updateInfo()
end

-- Drag Logic (Touch/Mouse)
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

-- บันทึก Macro เมื่อวาง Unit (Slot 1-6)
-- หมายเหตุ: คุณต้องแก้ไข event นี้ให้ตรงกับระบบเกม Tower Defense ของคุณ
-- ตัวอย่างนี้จะฟังการกดปุ่ม 1-6 (KeyCode One~Six) แล้วบันทึกตำแหน่งเมาส์ (หรือจอย) เป็นจุดวาง unit
-- คุณควรเปลี่ยนเป็น event จริงของเกม (หรือเช็ค Tool/Unit placement system จริง)
UIS.InputBegan:Connect(function(input, gpe)
    if not recording then return end
    if gpe then return end
    local slot = nil
    if input.KeyCode == Enum.KeyCode.One then slot = 1
    elseif input.KeyCode == Enum.KeyCode.Two then slot = 2
    elseif input.KeyCode == Enum.KeyCode.Three then slot = 3
    elseif input.KeyCode == Enum.KeyCode.Four then slot = 4
    elseif input.KeyCode == Enum.KeyCode.Five then slot = 5
    elseif input.KeyCode == Enum.KeyCode.Six then slot = 6 end
    if slot then
        -- หาตำแหน่ง world ตรงเมาส์ (หรือจอย)
        local cam = Workspace.CurrentCamera
        local mouse = player:GetMouse()
        local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
        local pos = ray.Origin + ray.Direction * 100 -- ปรับความลึกหากเกมใช้พื้นสูง/ต่ำ
        local t = tick()
        if not macroStartTime then macroStartTime = t end
        local index = #macroSteps + 1
        table.insert(macroSteps, {
            index = index,
            time = (t - macroStartTime),
            unitSlot = slot,
            pos = pos
        })
        updateInfo()
    end
end)

-- ปุ่ม UI
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
        wait(1)
        exportBtn.Text = "Copy Macro"
    end
end)

-- Auto update info
updateInfo()

print("Tower Defense Macro Recorder UI loaded! ปุ่ม 1-6 = อัด Macro (เวลา/slot/pos)")
