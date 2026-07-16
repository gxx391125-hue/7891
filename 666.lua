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
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(95, 167, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderButton = Instance.new("ImageLabel")
sliderButton.Size = UDim2.new(0, 22, 0, 22)
sliderButton.Position = UDim2.new(0.5, -11, 0, -1)
sliderButton.BackgroundTransparency = 1
sliderButton.Image = "rbxassetid://707172680" -- 滑块图标（可替换）
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
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 110)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleBtn.Text = "显示碰撞箱"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSans
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- 逻辑部分
local MIN_SIZE = 1
local MAX_SIZE = 15
local currentSize = 5
local showHitbox = true
local hitboxPart = nil
local dragging = false

local function createOrUpdateHitbox(size)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if hitboxPart and hitboxPart.Parent == char then
        hitboxPart.Size = Vector3.new(size, size, size)
        hitboxPart.CFrame = hrp.CFrame
    else
        if hitboxPart then hitboxPart:Destroy() end
        hitboxPart = Instance.new("Part")
        hitboxPart.Name = "TrainingHitbox"
        hitboxPart.Size = Vector3.new(size, size, size)
        hitboxPart.CFrame = hrp.CFrame
        hitboxPart.Transparency = 0.485
        hitboxPart.CanCollide = false
        hitboxPart.Massless = true
        hitboxPart.Color = Color3.fromRGB(95, 167, 255)
        hitboxPart.Material = Enum.Material.ForceField
        hitboxPart.Anchored = false
        hitboxPart.Parent = char
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = hitboxPart
        weld.Parent = hitboxPart
    end
    hitboxPart.Visible = showHitbox
end

RunService.RenderStepped:Connect(function()
    if hitboxPart and hitboxPart.Parent then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            hitboxPart.CFrame = char.HumanoidRootPart.CFrame
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.15)
    createOrUpdateHitbox(currentSize)
end)

task.wait(0.5)
createOrUpdateHitbox(currentSize)

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

    local newSize = MIN_SIZE + ratio * (MAX_SIZE - MIN_SIZE)
    currentSize = math.round(newSize * 10) / 10

    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderButton.Position = UDim2.new(ratio, -12, 0, -12)
    valueLabel.Text = "大小：" .. tostring(currentSize)
    createOrUpdateHitbox(currentSize)
end)

toggleBtn.MouseButton1Click:Connect(function()
    showHitbox = not showHitbox
    toggleBtn.Text = showHitbox and "显示碰撞箱" or "隐藏碰撞箱"
    if hitboxPart then hitboxPart.Visible = showHitbox end
end)

print("碰撞箱调节器已加载")
