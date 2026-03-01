_G.DaviHubAtivo = true

local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")

local espOn, aimOn, flyOn, noclipOn = false, false, false, false
local flySpeed = 50
local fovRadius = 150 

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 60
fovCircle.Radius = fovRadius
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.5

local R15_Bones = {
    {"UpperTorso", "LowerTorso"}, {"UpperTorso", "Head"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local R6_Bones = {
    {"Torso", "Head"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local espData = {}

local function clearESP(p)
    if espData[p] then
        for _, obj in pairs(espData[p].Drawing) do obj:Remove() end
        espData[p] = nil
    end
end
w
local function createDrawings(p)
    clearESP(p)
    local data = {Drawing = {}, Player = p}
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 0, 0)
    table.insert(data.Drawing, tracer)
    data.Tracer = tracer
    data.Skeleton = {}
    for i = 1, 15 do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color = Color3.fromRGB(255, 255, 255)
        table.insert(data.Drawing, l)
        table.insert(data.Skeleton, l)
    end
    espData[p] = data
end

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("CombatGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CombatGui"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 160, 0, 250)
main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Draggable = true
main.Active = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Davi Hub V2.5"
title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
Instance.new("UICorner", title)

local function updateESP()
    for p, data in pairs(espData) do
        local char = p.Character
        local visible = false
        if espOn and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen then
                visible = true
                data.Tracer.Visible = true
                data.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                local bones = (char.Humanoid.RigType == Enum.HumanoidRigType.R15) and R15_Bones or R6_Bones
                for i, bonePair in pairs(bones) do
                    local part1 = char:FindFirstChild(bonePair[1])
                    local part2 = char:FindFirstChild(bonePair[2])
                    local line = data.Skeleton[i]
                    if part1 and part2 then
                        local p1, vis1 = camera:WorldToViewportPoint(part1.Position)
                        local p2, vis2 = camera:WorldToViewportPoint(part2.Position)
                        if vis1 and vis2 then
                            line.Visible = true
                            line.From = Vector2.new(p1.X, p1.Y)
                            line.To = Vector2.new(p2.X, p2.Y)
                        else line.Visible = false end
                    else line.Visible = false end
                end
                for i = #bones + 1, 15 do data.Skeleton[i].Visible = false end
            end
        end
        if not visible then
            data.Tracer.Visible = false
            for _, l in pairs(data.Skeleton) do l.Visible = false end
        end
    end
end

runService.RenderStepped:Connect(function()
    if not _G.DaviHubAtivo then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    updateESP()
    fovCircle.Visible = aimOn
    fovCircle.Position = uis:GetMouseLocation()

    if flyOn and root and hum then
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
        bv.Velocity = moveDir * flySpeed
    elseif not flyOn and root then
        if root:FindFirstChild("DaviVel") then root.DaviVel:Destroy() end
        if root:FindFirstChild("DaviGyr") then root.DaviGyr:Destroy() end
        if hum then hum.PlatformStand = false end
    end

    if noclipOn and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if aimOn and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target, closest = nil, fovRadius
        for _, v in pairs(players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local p, vis = camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local d = (uis:GetMouseLocation() - Vector2.new(p.X, p.Y)).Magnitude
                    if d < closest then closest = d target = v.Character.Head end
                end
            end
        end
        if target then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position) end
    end
end)

for _, v in pairs(players:GetPlayers()) do createDrawings(v) end
players.PlayerAdded:Connect(createDrawings)
players.PlayerRemoving:Connect(clearESP)

local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = UDim2.new(0.5, -70, 0, yPos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    Instance.new("UICorner", btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
        callback(state)
    end)
end

createToggle("ESP SKEL/LINE", 40, function(s) espOn = s end)
createToggle("AIMBOT", 80, function(s) aimOn = s end)
createToggle("FLY (Q/E)", 120, function(s) flyOn = s end)
createToggle("NOCLIP", 160, function(s) noclipOn = s end)

local resetBtn = Instance.new("TextButton", main)
resetBtn.Size = UDim2.new(0, 140, 0, 35)
resetBtn.Position = UDim2.new(0.5, -70, 0, 205)
resetBtn.Text = "RESET CHAR"
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", resetBtn)
resetBtn.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.Health = 0 end end)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function()
    _G.DaviHubAtivo = false
    fovCircle:Remove()
    for _, data in pairs(espData) do for _, obj in pairs(data.Drawing) do obj:Remove() end end
    screenGui:Destroy()
end)
