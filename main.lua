local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local keySourceURL = "https://raw.githubusercontent.com/Pingz0/SilentScriptHub/main/3910.txt"
local validKeys = {}
pcall(function()
    local rawKeys = game:HttpGet(keySourceURL)
    for key in string.gmatch(rawKeys, "[^\r\n]+") do
        table.insert(validKeys, key)
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "🔥SilentHub V1.4🔥",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "🔥By Pingz0🔥",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
    KeySettings = {
        Title = "Silent Access",
        Subtitle = "Enter your Key code",
        Note = "Join our Discord: discord.gg/eaf8h8cg4p",
        FileName = "SilentKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = validKeys
    }
})

local MainTab = Window:CreateTab("| Main", 8772194322)

-- Speed Slider
MainTab:CreateSlider({
    Name = "Speed Hack",
    Range = {16, 500},
    Increment = 1,
    Suffix = " WalkSpeed",
    CurrentValue = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

-- Jump Power Slider
MainTab:CreateSlider({
    Name = "Jump Hack",
    Range = {50, 500},
    Increment = 5,
    Suffix = " JumpPower",
    CurrentValue = 50,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

local FlySpeed = 2

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "x",
    CurrentValue = FlySpeed,
    Callback = function(value)
        FlySpeed = value
    end,
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local cam = workspace.CurrentCamera

local flying = false
local BodyVelocity
local BodyGyro

local function startFly()
    if flying then return end
    flying = true
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    BodyVelocity.Velocity = Vector3.new(0,0,0)
    BodyVelocity.Parent = rootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    BodyGyro.CFrame = rootPart.CFrame
    BodyGyro.Parent = rootPart
end

local function stopFly()
    if not flying then return end
    flying = false
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
end

local function updateFly()
    if not flying then return end
    local moveDir = Vector3.new()
    if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
    if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
    if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
    if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
    if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
    if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
    BodyVelocity.Velocity = moveDir * FlySpeed * 16 -- Multiply by 16 studs/sec roughly for normal walking speed ~32
    BodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
end

MainTab:CreateButton({
    Name = "Toggle Fly",
    Callback = function()
        if flying then
            stopFly()
        else
            startFly()
        end
    end,
})

runService.Heartbeat:Connect(function()
    if flying then
        updateFly()
    end
end)

-- NoClip
MainTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(enabled)
        local RunService = game:GetService("RunService")
        local player = game.Players.LocalPlayer

        RunService.Stepped:Connect(function()
            if enabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
})

local ESPDrawings = {}
local ESPConnections = {}
local ESPEnabled = false
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

MainTab:CreateToggle({
    Name = "ESP (Red Outline + NameTag)",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state

        -- Remove previous ESP
        for _, conn in pairs(ESPConnections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        ESPConnections = {}

        for _, drawings in pairs(ESPDrawings) do
            for _, obj in pairs(drawings) do
                if typeof(obj) == "Instance" then
                    obj:Destroy()
                elseif typeof(obj) == "table" and typeof(obj.Remove) == "function" then
                    obj:Remove()
                end
            end
        end
        ESPDrawings = {}

        if not state then return end

        local function createESP(player)
            if player == LocalPlayer then return end
            local drawings = {}
            ESPDrawings[player] = drawings

            local function update()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end

                -- Body Outline
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("ESPBox") then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "ESPBox"
                        box.Adornee = part
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Size = part.Size
                        box.Color3 = Color3.new(1, 0, 0)
                        box.Transparency = 0.4
                        box.Parent = part
                        table.insert(drawings, box)
                    end
                end

                -- Name Tag
                local head = character:FindFirstChild("Head")
                if head and not head:FindFirstChild("ESPName") then
                    local tag = Instance.new("BillboardGui", head)
                    tag.Name = "ESPName"
                    tag.Size = UDim2.new(0, 100, 0, 20)
                    tag.StudsOffset = Vector3.new(0, 2.5, 0)
                    tag.AlwaysOnTop = true

                    local label = Instance.new("TextLabel", tag)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.new(1, 0, 0)
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    table.insert(drawings, tag)
                end
            end

            update()

            -- Update ESP on respawn
            local conn = player.CharacterAdded:Connect(function()
                task.wait(1)
                update()
            end)
            table.insert(ESPConnections, conn)
        end

        -- Add ESP for current players
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end

        -- Handle new players
        table.insert(ESPConnections, Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                createESP(player)
            end)
        end))
    end
})


local NoFallEnabled = false
local NoFallConnections = {}

MainTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Callback = function(state)
        NoFallEnabled = state

        -- Alles bereinigen bei Deaktivierung
        for _, conn in pairs(NoFallConnections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        table.clear(NoFallConnections)

        if not state then return end

        -- Fallgeschwindigkeit begrenzen
        table.insert(NoFallConnections, game:GetService("RunService").Stepped:Connect(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp.Velocity.Y < -50 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -50, hrp.Velocity.Z)
                end
            end
        end))

        -- Freefall-Zustände abfangen
        local function protectHumanoid(humanoid)
            table.insert(NoFallConnections, humanoid.StateChanged:Connect(function(_, new)
                if NoFallEnabled and (new == Enum.HumanoidStateType.Freefall or new == Enum.HumanoidStateType.FallingDown) then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
        end

        local function setupCharacter(char)
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                protectHumanoid(humanoid)
            end
        end

        local plr = game.Players.LocalPlayer
        if plr.Character then setupCharacter(plr.Character) end

        table.insert(NoFallConnections, plr.CharacterAdded:Connect(function(char)
            setupCharacter(char)
        end))

        -- Soft-Fall durch Sitzen
        table.insert(NoFallConnections, game:GetService("RunService").Heartbeat:Connect(function()
            local char = plr.Character
            if NoFallEnabled and char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum.Sit = true
                end
            end
        end))
    end
})

local InfiniteJumpEnabled = false
local JumpConnection

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(state)
        InfiniteJumpEnabled = state

        if InfiniteJumpEnabled then
            JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end
        end
    end
})

local AntiAFKEnabled = false
local JumpConnection

MainTab:CreateToggle({
    Name = "Anti-AFK (Auto Jump)",
    CurrentValue = false,
    Callback = function(state)
        AntiAFKEnabled = state

        if AntiAFKEnabled then
            JumpConnection = task.spawn(function()
                while AntiAFKEnabled do
                    local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    task.wait(5)
                end
            end)
        else
            if JumpConnection then
                task.cancel(JumpConnection)
                JumpConnection = nil
            end
        end
    end,
})

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Settings
local AimbotEnabled = false
local ShowFOV = false
local FOVRadius = 100
local FOVCircle

-- Create Tab
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

-- Draw FOV Circle
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    if ShowFOV then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        FOVCircle.Filled = false
        FOVCircle.Visible = true
    end
end

-- Update FOV Circle Position & Color
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

-- Find Closest Target
local function GetClosestPlayer()
    local closestPlayer
    local shortestDistance = FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head)
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(LocalPlayer.Character.PrimaryPart.Position, head))
        end
    end
end)

-- Aimbot Toggle
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

-- FOV Toggle
AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(Value)
        ShowFOV = Value
        CreateFOVCircle()
    end
})

-- TELEPORT TAB
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local selectedPlayerName = nil

-- Dropdown erstellen
local PlayerDropdown = TeleportTab:CreateDropdown({
   Name = "TP to Player",
   Options = {},
   CurrentOption = nil,
   Callback = function(option)
      if typeof(option) == "string" then
         selectedPlayerName = option
      elseif typeof(option) == "table" and typeof(option[1]) == "string" then
         selectedPlayerName = option[1]
      end
   end,
})

-- Button zum Teleportieren
TeleportTab:CreateButton({
   Name = "Teleport",
   Callback = function()
      if not selectedPlayerName then
         Rayfield:Notify({
            Title = "Fehler",
            Content = "Kein Spieler ausgewählt.",
            Duration = 3
         })
         return
      end

      local target = Players:FindFirstChild(selectedPlayerName)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
      else
         Rayfield:Notify({
            Title = "Teleport Error",
            Content = "Player not found or missing HumanoidRootPart.",
            Duration = 4
         })
      end
   end
})

-- Funktion zum Aktualisieren der Spieler im Dropdown
local function UpdateDropdown()
   local names = {}
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(names, player.Name)
      end
   end
   PlayerDropdown:Refresh(names, true)
end

-- Spieler beim Start hinzufügen
UpdateDropdown()

-- Neue Spieler dynamisch hinzufügen
Players.PlayerAdded:Connect(function()
   task.wait(0.2)
   UpdateDropdown()
end)

Players.PlayerRemoving:Connect(function()
   task.wait(0.2)
   UpdateDropdown()
end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local customSpawnPosition = nil

local function setSpawnPoint()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        customSpawnPosition = player.Character.HumanoidRootPart.Position
        Rayfield:Notify({
            Title = "TPpoint Set",
            Content = "Position: " .. tostring(customSpawnPosition),
            Duration = 5,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Please Report in Our Dc if this is shown",
            Content = "HumanoidRootPart not found!",
            Duration = 5,
            Image = 4483362458
        })
    end
end

player.CharacterAdded:Connect(function(character)
    if customSpawnPosition then
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(customSpawnPosition + Vector3.new(0, 5, 0))
    end
end)

TeleportTab:CreateButton({
    Name = "Set TPpoint",
    Callback = setSpawnPoint
})

TeleportTab:CreateButton({
    Name = "Teleport to TPpoint",
    Callback = function()
        if customSpawnPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(customSpawnPosition + Vector3.new(0, 5, 0))
            Rayfield:Notify({
                Title = "Teleported!",
                Content = "You have been moved to your saved TPpoint.",
                Duration = 4,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "Make sure you set a TPpointfirst.",
                Duration = 4,
                Image = 4483362458
            })
        end
    end
})
