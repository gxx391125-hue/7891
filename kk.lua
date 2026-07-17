-- ====== 修复版：确保手机端触摸生效 + 滑块功能完整 ======
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI 创建（简化版，适配手机）
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "碰撞箱调节器"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 20)
sliderBg.Position = UDim2.new(0, 10, 0, 50)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- 默认 50%
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderButton = Instance.new("ImageLabel") -- 用 ImageLabel 适配手机
sliderButton.Size = UDim2.new(0, 24, 0, 24)
sliderButton.BackgroundTransparency = 1
sliderButton.Image = "rbxassetid://707172680" -- 滑块图标（可替换）
sliderButton.Position = UDim2.new(0.5, -12, 0, -12)
sliderButton.Parent = sliderBg

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 20)
valueLabel.Position = UDim2.new(0, 0, 0, 80)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "大小：5"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.Font = Enum.Font.SourceSans
valueLabel.TextSize = 14
valueLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 120)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleBtn.Text = "显示碰撞箱"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Parent = mainFrame

-- ====== 全局变量 ======
local MIN_SIZE = 1
local MAX_SIZE = 10
local currentSize = 5
local showHitbox = true
local dragging = false
local hitboxPart = nil

-- ====== 创建或更新碰撞箱 ======
local function createOrUpdateHitbox(size)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not hitboxPart then
        hitboxPart = Instance.new("Part")
        hitboxPart.Name = "HitboxVisual"
        hitboxPart.Size = UDim2.new(0, size * 2, 0, size * 2, 0)
        hitboxPart.Shape = Enum.PartType.Block
        hitboxPart.Transparency = 0.5
        hitboxPart.CanCollide = false
        hitboxPart.Massless = true
        hitboxPart.Color = Color3.fromRGB(97, 169, 255)
        hitboxPart.Material = Enum.Material.ForceField
        hitboxPart.Anchored = false
        hitboxPart.Parent = char
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = hitboxPart
        weld.Parent = hitboxPart
    end
    hitboxPart.Size = UDim2.new(0, size * 2, 0, size * 2, 0)
    hitboxPart.Visible = showHitbox
end

-- ====== 修复：手机端触摸事件绑定 ======
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

-- ====== 修复：滑块拖动逻辑（手机端兼容） ======
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local mousePos = UserInputService:GetMouseLocation()
    local absPos = sliderBg.AbsolutePosition
    local absSize = sliderBg.AbsoluteSize
    local ratio = (mousePos.X - absPos.X) / absSize.X
    ratio = math.clamp(ratio, 0, 1)

    local newSize = MIN_SIZE + ratio * (MAX_SIZE - MIN_SIZE)
    currentSize = math.round(newSize * 10) / 10

    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderButton.Position = UDim2.new(ratio, -12, 0, -12)
    valueLabel.Text = "大小：" .. tostring(currentSize)
    createOrUpdateHitbox(currentSize) -- ✅ 确保这里被调用
end)

-- ====== 切换按钮 ======
toggleBtn.MouseButton1Click:Connect(function()
    showHitbox = not showHitbox
    toggleBtn.Text = showHitbox and "显示碰撞箱" or "隐藏碰撞箱"
    if hitboxPart then hitboxPart.Visible = showHitbox end
end)

-- ====== 角色重生时重置 ======
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.15)
    createOrUpdateHitbox(currentSize)
end)

-- ====== 初始化 ======
task.wait(0.5)
createOrUpdateHitbox(currentSize)

print("✅ 碰撞箱调节器已加载（修复版）")

