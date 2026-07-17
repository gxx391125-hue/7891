local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local ENABLED = true
local HITBOX_SIZE = Vector3.new(8, 8, 8) -- TSB 常用范围，可自行改大改小
local TRANSPARENCY = 1 -- 1=完全隐形，0.5=半透可见

-- 创建开关按钮 UI
local sg = Instance.new("ScreenGui")
sg.Name = "TSB_Hitbox_Toggle"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 140, 0, 36)
btn.Position = UDim2.new(0, 20, 0.65, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "Hitbox: ON"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 16
btn.Draggable = true
btn.Parent = sg

local corner = Instance.new("UICorner")
corner.Corner[](@mark_underline=5)[](@mark_underline=6)Radius = UDim.new(0, 8)
corner.Parent = btn

btn.MouseButton1Click:Connect(function()
	ENABLED = not ENABLED
	btn.Text = ENABLED and "Hitbox: ON" or "Hitbox: OFF"
	btn.BackgroundColor3 = ENABLED and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(70, 30, 30)
end)

-- 核心：放大敌方 HumanoidRootPart
RunService.RenderStepped:Connect(function()
	if not ENABLED then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			pcall(function()
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Size = HITBOX_SIZE
					hrp.Transparency = TRANSPARENCY
					hrp.CanCollide = false
				end
			end)
		end
	end
end)

-- 角色重生也保持生效
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(1)
		if ENABLED and plr ~= LocalPlayer then
			pcall(function()
				local hrp = char:WaitForChild("HumanoidRootPart", 5)
				if hrp then
					hrp.Size = HITBOX_SIZE
					hrp.Transparency = TRANSPARENCY
					hrp.CanCollide = false
				end
			end)
		end
	end)
end)

print("✅ TSB Hitbox Extender 已加载（点击屏幕按钮 ON/OFF）")
