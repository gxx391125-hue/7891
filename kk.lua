local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- 创建一个简单的开关按钮
local gui = Instance.new("ScreenGui")
gui.Name = "TSB_Extender"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 150, 0, 40)
btn.Position = UDim2.new(0, 20, 0.7, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "开启范围扩展"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
btn.Parent = gui

local enabled = false

btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    btn.Text = enabled and "关闭范围扩展" or "开启范围扩展"
end)

-- 每帧检测并放大敌人
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(10, 10, 10)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end)

print("TSB 范围扩展已加载")
