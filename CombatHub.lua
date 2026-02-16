_G.DaviHubAtivo = true

local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")

local espOn, aimOn, flyOn, noclipOn = false, false, false, false
local flySpeed = 60

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("CombatGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CombatGui"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 160, 0, 300)
main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Combat Gui V2.2"
title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
Instance.new("UICorner", title)

local function resetPhysics()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if root then
            if root:FindFirstChild("DaviVel") then root.DaviVel:Destroy() end
            if root:FindFirstChild("DaviGyr") then root.DaviGyr:Destroy() end
            root.Velocity = Vector3.new(0,0,0)
        end
    end
end

local function refreshESP()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("H_ESP")
            if h then h.Enabled = espOn end
        end
    end
end

local function createESP(p)
    local function apply(char)
        if p == player then return end
        if not char then return end
        local h = char:FindFirstChild("H_ESP") or Instance.new("Highlight")
        h.Name = "H_ESP"
        h.Parent = char
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.5
        h.Enabled = espOn
    end
    p.CharacterAdded:Connect(apply)
    if p.Character then apply(p.Character) end
end

runService.Stepped:Connect(function()
    if not _G.DaviHubAtivo then return end
    if noclipOn and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

runService.RenderStepped:Connect(function()
    if not _G.DaviHubAtivo then return end
    
    if flyOn and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChild("Humanoid")
        if root and hum then
            hum.PlatformStand = true
            local bv = root:FindFirstChild("DaviVel") or Instance.new("BodyVelocity", root)
            bv.Name = "DaviVel"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            local bg = root:FindFirstChild("DaviGyr") or Instance.new("BodyGyro", root)
            bg.Name = "DaviGyr"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = camera.CFrame
            
            local moveDir = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0,1,0) end
            
            bv.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * flySpeed) or Vector3.new(0,0.1,0)
        end
    end

    if aimOn and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = nil
        local dist = 600
        for _, v in pairs(players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local p, vis = camera:WorldToScreenPoint(v.Character.Head.Position)
                if vis then
                    local m = (Vector2.new(uis:GetMouseLocation().X, uis:GetMouseLocation().Y) - Vector2.new(p.X, p.Y)).Magnitude
                    if m < dist then dist = m target = v.Character.Head end
                end
            end
        end
        if target then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position) end
    end
end)

for _, v in pairs(players:GetPlayers()) do createESP(v) end
players.PlayerAdded:Connect(createESP)  

local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = UDim2.new(0.5, -70, 0, yPos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    Instance.new("UICorner", btn)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
        callback(state)
    end)
end

createToggle("ESP", 40, function(s) espOn = s refreshESP() end)
createToggle("AIMBOT", 80, function(s) aimOn = s end)
createToggle("FLY (Q/E)", 120, function(s) flyOn = s if not s then resetPhysics() end end)
createToggle("NOCLIP", 160, function(s) noclipOn = s end)

local resetBtn = Instance.new("TextButton", main)
resetBtn.Size = UDim2.new(0, 140, 0, 35)
resetBtn.Position = UDim2.new(0.5, -70, 0, 205)
resetBtn.Text = "RESET CHAR"
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", resetBtn)
resetBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function()
    _G.DaviHubAtivo = false
    espOn = false
    refreshESP()
    resetPhysics()
    screenGui:Destroy()
end)
