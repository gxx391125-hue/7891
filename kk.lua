local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ====== 创建 UI ======
local gui = Instance.new("ScreenGui")
gui.Name = "TSB_Hitbox_Controller"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-- 悬浮球（折叠状态显示）
local floatingBtn = Instance.new("TextButton")
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
floatingBtn.Position = UDim2.new(0, 20, 0.8, 0)
floatingBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Text = "⚡"
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.Active = true
floatingBtn.Draggable = true
floatingBtn.Visible = false  -- 初始隐藏，等主面板创建后再决定显示哪个
floatingBtn.Parent = gui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatingBtn

-- 主面板
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 178)
frame.Position = UDim2.new(0.5, -130, 0.65, -89)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- 标题栏（可拖动）
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- 标题文字
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "打击范围控制器"
title.TextColor3 = Color3.fromRGB(215, 222, 242)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- 折叠按钮（减号）
local foldBtn = Instance.new("TextButton")
foldBtn.Size = UDim2.new(0, 28, 0, 28)
foldBtn.Position = UDim2.new(1, -34, 0, 3.5)
foldBtn.BackgroundTransparency = 1
foldBtn.Text = "━"
foldBtn.TextColor3 = Color3.fromRGB(180, 188, 210)
foldBtn.Font = Enum.Font.GothamBold
foldBtn.TextSize = 18
foldBtn.Parent = titleBar

-- 开关按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 42)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "✅ 已开启"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- 大小数值显示
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -30, 0, 20)
valueLabel.Position = UDim2.new(0, 15, 0, 80)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "打击范围：8"
valueLabel.TextColor3 = Color3.fromRGB(176, 186, 211)
valueLabel.Font = Enum.Font.GothamMedium
valueLabel.TextSize = 14
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.Parent = frame

-- 滑块背景
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.855, 0, 0, 6)
sliderBg.Position = UDim2.new(0.072, 0, 0, 108)
sliderBg.BackgroundColor3 = Color3.fromRGB(46, 51, 65)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBg

-- 滑块填充
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.478, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(82, 152, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

-- 滑块按钮
local sliderButton = Instance.new("ImageButton")
sliderButton.Size = UDim2.new(0, 24, 0, 30)
sliderButton.Position = UDim2.new(0.456, 0, 0, -12)
sliderButton.BackgroundColor3 = Color3.fromRGB(104, 157, 246)
sliderButton.Image = ""
sliderButton.AutoButtonColor = false
sliderButton.Parent = sliderBg

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = sliderButton

-- 最小/最大标签
local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(0, 20, 0, 16)
minLabel.Position = UDim2.new(0.022, 0, 0, 119)
minLabel.BackgroundTransparency = 1
minLabel.Text = "1"
minLabel.TextColor3 = Color3.fromRGB(118, 124, 147)
minLabel.Font = Enum.Font.GothamMedium
minLabel.TextSize = 11
minLabel.Parent = frame

local maxLabel = Instance.new("TextLabel")
maxLabel.Size = UDim2.new(0, 20, 0, 16)
maxLabel.Position = UDim2.new(0.898, 0, 0, 117)
maxLabel.BackgroundTransparency = 1
maxLabel.Text = "15"
local MIN_SIZE = 1
    frame.Visible = false
    floatingBtn.Visible = true
    statusLabel.Visible = true
    updateStatusText()
end)

floatingBtn.MouseButton1Click:Connect(function()
    isFolded = false
    frame.Visible = true
    floatingBtn.Visible = false
    statusLabel.Visible = false
end)

-- 开关按钮
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "✅ 已开启" or "⛔ 已关闭"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
    updateStatusText()
end)

-- 滑块交互
sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

sliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local mousePos = UserInputService:GetMouseLocation()
    local absPos = sliderBg.AbsolutePosition
    local absSize = sliderBg.AbsoluteSize
    local ratio = (mousePos.X - absPos.X) / absSize.X
    ratio = math.clamp(ratio, 0, 1)

    hitboxSize = math.round((MIN_SIZE + ratio * (MAX_SIZE - MIN_SIZE)) * 10) / 10
    
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderButton.Position = UDim2.new(ratio, -12, 0, -12)
    valueLabel.Text = "打击范围：" .. tostring(hitboxSize)
    updateStatusText()
end)

-- 角色重生时保持效果
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if enabled and player ~= lp then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end)
end)

print("✅ TSB 打击范围控制器已加载！范围：" .. tostring(hitboxSize))
