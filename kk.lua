local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ====== 1. 创建 UI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 150)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "碰撞箱调节器"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 20)
sliderBg.Position = UDim2.new(0, 10, 0, 40)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 24, 0, 24)
sliderButton.Position = UDim2.new(0.5, -12, 0, -2)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderBg

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 20)
valueLabel.Position = UDim2.new(0, 0, 0, 70)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "大小：5"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.Font = Enum.Font.SourceSans
valueLabel.TextSize = 14
valueLabel.Parent = mainFrame

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -20, 0, 30)
resetBtn.Position = UDim2.new(0, 10, 0, 105)
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetBtn.Text = "重置碰撞箱 (恢复默认)"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 14
resetBtn.Parent = mainFrame

-- ====== 2. 核心逻辑：直接修改 HumanoidRootPart ======
local DEFAULT_SIZE = Vector3.new(2, 2, 1) -- Roblox 默认 HumanoidRootPart 大小
local currentSize = 5
local dragging = false

local function setHitboxSize(scale)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- 按比例缩放：1 对应默认大小，10 对应 5 倍大小
    local multiplier = 1 + (scale - 1) * 0.5
    hrp.Size = DEFAULT_SIZE * multiplier
    hrp.Transparency = 0.5 -- 让它半透明，方便看到变化
end

-- 重置到默认大小
local function resetHitbox()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.Size = DEFAULT_SIZE
    hrp.Transparency = 0
    currentSize = 5
    sliderFill.Size = UDim2.new(0.444, 0, 1, 0) -- 5/9 ≈ 0.444
    sliderButton.Position = UDim2.new(0.424, 0, 0, -2)
    valueLabel.Text = "大小：5"
end

-- ====== 3. 滑块控制 ======
sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

sliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local mousePos = UserInputService:GetMouseLocation()
    local absPos = sliderBg.AbsolutePosition
    local absSize = sliderBg.AbsoluteSize
    local ratio = (mousePos.X - absPos.X) / absSize.X
    ratio = math.clamp(ratio, 0, 1)

    currentSize = math.round((1 + ratio * 9) * 10) / 10
    valueLabel.Text = "大小：" .. tostring(currentSize)
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderButton.Position = UDim2.new(ratio, -12, 0, -2)
    
    setHitboxSize(currentSize)
end)

-- ====== 4. 重置按钮 ======
resetBtn.MouseButton1Click:Connect(resetHitbox)

-- ====== 5. 角色重生时重置 ======
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.15)
    setHitboxSize(currentSize)
end)

-- ====== 6. 初始化 ======
task.wait(0.5)
setHitboxSize(currentSize)

print("✅ 终极版已加载！拖动滑块直接改变 HumanoidRootPart 大小，角色会明显变大/变小！")
