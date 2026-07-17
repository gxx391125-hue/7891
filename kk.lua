local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ====== 1. 创建简化 UI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 160)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "碰撞箱调节器 (可拖动)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

-- 滑块背景
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 20)
sliderBg.Position = UDim2.new(0, 10, 0, 40)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = mainFrame

-- 滑块填充
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

-- 滑块按钮
local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 24, 0, 24)
sliderButton.Position = UDim2.new(0.5, -12, 0, -2)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderBg

-- 数值显示
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 20)
valueLabel.Position = UDim2.new(0, 0, 0, 70)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "大小：5"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.Font = Enum.Font.SourceSans
valueLabel.TextSize = 14
valueLabel.Parent = mainFrame

-- 开关按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Text = "显示碰撞箱"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- ====== 2. 新增：UI 拖动功能 ======
local dragging = false
local dragInput
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = input.Position
        dragInput = input
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragInput = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - startPos
        local newX = math.clamp(mainFrame.Position.X.Offset + delta.X, -200, 200) -- 限制拖动范围
        local newY = math.clamp(mainFrame.Position.Y.Offset + delta.Y, -200, 200)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
        startPos = input.Position
    end
end)

-- ====== 3. 核心逻辑（放大碰撞箱方便观察） ======
local hitboxPart = nil
local showHitbox = true
local currentSize = 5

local function createOrUpdateHitbox(size)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 为了让你看清，我把基础大小调大了 (size * 4)
    local boxSize = size * 4 

    if not hitboxPart then
        hitboxPart = Instance.new("Part")
        hitboxPart.Name = "HitboxVisual"
        hitboxPart.Size = UDim2.new(0, boxSize, 0, boxSize, 0)
        hitboxPart.Shape = Enum.PartType.Block
        hitboxPart.Transparency = 0.4 -- 透明度调低一点
        hitboxPart.CanCollide = false
        hitboxPart.Massless = true
        hitboxPart.Color = Color3.fromRGB(0, 170, 255) -- 亮蓝色
        hitboxPart.Material = Enum.Material.ForceField
        hitboxPart.Anchored = false
        hitboxPart.Parent = char
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = hitboxPart
        weld.Parent = hitboxPart
    else
        hitboxPart.Size = UDim2.new(0, boxSize, 0, boxSize, 0)
    end
    
    hitboxPart.Visible = showHitbox
end

-- 滑块控制
local draggingSlider = false
sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

sliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingSlider then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local mousePos = UserInputService:GetMouseLocation()
    local absPos = sliderBg.AbsolutePosition
    local absSize = sliderBg.AbsoluteSize
    local ratio = (mousePos.X - absPos.X) / absSize.X
    ratio = math.clamp(ratio, 0, 1)

    currentSize = math.round((1 + ratio * 9) * 10) / 10 -- 范围 1-10
    valueLabel.Text = "大小：" .. tostring(currentSize)
    
    -- 增大视觉反馈
    local boxSize = currentSize * 4
    if hitboxPart then
        hitboxPart.Size = UDim2.new(0, boxSize, 0, boxSize, 0)
    end
end)

-- 开关按钮
toggleBtn.MouseButton1Click:Connect(function()
    showHitbox = not showHitbox
    toggleBtn.Text = showHitbox and "隐藏碰撞箱" or "显示碰撞箱"
    if hitboxPart then hitboxPart.Visible = showHitbox end
end)

-- 初始化
task.wait(0.5)
createOrUpdateHitbox(currentSize)

print("✅ 极简版已加载！拖动标题可移动窗口，滑块调大小，注意看角色周围的蓝色方块！")


