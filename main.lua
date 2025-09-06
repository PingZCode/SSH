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
    Name = "⭐SilentHub V1.6⭐",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "🔥By Pingz0🔥",
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
    Range = {16, 1000},
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
    Range = {50, 1000},
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
    Range = {1, 100},
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
local FlySpeed = 2 -- kannst du anpassen

-- Funktion zum Starten
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

-- Funktion zum Stoppen
local function stopFly()
    if not flying then return end
    flying = false
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
end

-- Bewegung updaten
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
    BodyVelocity.Velocity = moveDir * FlySpeed * 16
    BodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
end

-- Button in deinem GUI
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

-- Fly beim Herzschlag updaten
runService.Heartbeat:Connect(function()
    if flying then
        updateFly()
    end
end)

-- Charakter nach Respawn aktualisieren
player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")

    -- Fly-System automatisch neu initialisieren
    if flying then
        stopFly()
    end
    
    task.wait(0.1)
    startFly()
    stopFly() -- sofort wieder ausmachen -> Toggle funktioniert normal
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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPColor = Color3.new(1,0,0) -- Standard Rot
local RGBEnabled = false

-- Funktion: Alles ESP löschen
local function clearAllESP()
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
            elseif typeof(obj) == "Drawing" then
                obj:Remove()
            end
        end
    end
    ESPDrawings = {}
end

-- Funktion: Rainbow Farben
task.spawn(function()
    while task.wait(0.1) do
        if RGBEnabled then
            ESPColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    end
end)

-- ESP Toggle
MainTab:CreateToggle({
    Name = "ESP (Outline + NameTag)",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state

        clearAllESP()
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
                        box.Color3 = ESPColor
                        box.Transparency = 0.4
                        box.Parent = part
                        table.insert(drawings, box)

                        -- Update Farbe dynamisch
                        task.spawn(function()
                            while box.Parent and ESPEnabled do
                                box.Color3 = ESPColor
                                task.wait(0.1)
                            end
                        end)
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
                    label.TextColor3 = ESPColor
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    table.insert(drawings, tag)
-- ESP mit Dropdown + "Apply Color" Button (sauber, kein Callback-Error)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local ESPDrawings = {} -- map player -> { boxes = {...}, nametag = BillboardGui, conns = {...} }
local ESPColor = Color3.fromRGB(255, 0, 0) -- aktuelle Farbe
local pendingColor = ESPColor -- Farbe aus Dropdown, noch nicht angewendet
local RGBSelected = false
local rgbTask = nil
local globalConns = {} -- zum sichern/clearen (z.B. PlayerAdded)

-- Hilfsfunktion: wendet ESPColor sofort auf bestehende ESP-Objekte an
local function applyColorToAll()
    for player, data in pairs(ESPDrawings) do
        if data and data.boxes then
            for _, box in ipairs(data.boxes) do
                if box and box.Parent then
                    box.Color3 = ESPColor
                end
            end
        end
        if data and data.nametag and data.nametag.Parent then
            local label = data.nametag:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                label.TextColor3 = ESPColor
            end
        end
    end
end

-- Hilfsfunktion: löscht ESP für einen Spieler
local function clearPlayerESP(player)
    local data = ESPDrawings[player]
    if not data then return end

    -- disconnect stored connections
    if data.conns then
        for _, c in ipairs(data.conns) do
            if c and typeof(c) == "RBXScriptConnection" then
                pcall(function() c:Disconnect() end)
            end
        end
    end

    -- destroy boxes
    if data.boxes then
        for _, box in ipairs(data.boxes) do
            pcall(function() if box and box.Parent then box:Destroy() end end)
        end
    end

    -- destroy nametag
    if data.nametag then
        pcall(function() if data.nametag and data.nametag.Parent then data.nametag:Destroy() end end)
    end

    ESPDrawings[player] = nil
end

-- Hilfsfunktion: clear all
local function clearAllESP()
    -- disconnect global conns for player added/removed if exist
    if globalConns.playerAdded then
        pcall(function() globalConns.playerAdded:Disconnect() end)
        globalConns.playerAdded = nil
    end
    -- clear per-player
    for player, _ in pairs(ESPDrawings) do
        clearPlayerESP(player)
    end
end

-- Erstellt ESP-Objekte für einen Spieler (wenn möglich)
local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    -- Wenn schon welche existieren, erst entfernen (sicher)
    if ESPDrawings[player] then clearPlayerESP(player) end

    local data = { boxes = {}, nametag = nil, conns = {} }
    ESPDrawings[player] = data

    local function spawnForCharacter(character)
        if not character then return end
        -- small wait to ensure parts exist
        task.wait(0.1)
        -- create boxes for parts
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                local ok, box = pcall(function()
                    local b = Instance.new("BoxHandleAdornment")
                    b.Name = "ESPBox"
                    b.Adornee = part
                    b.AlwaysOnTop = true
                    b.ZIndex = 10
                    b.Size = part.Size
                    b.Color3 = ESPColor
                    b.Transparency = 0.4
                    b.Parent = part -- parent to part to keep it scoped
                    return b
                end)
                if ok and box then
                    table.insert(data.boxes, box)
                end
            end
        end

        -- nametag
        local head = character:FindFirstChild("Head")
        if head then
            pcall(function()
                local tag = Instance.new("BillboardGui", head)
                tag.Name = "ESPName"
                tag.Size = UDim2.new(0, 100, 0, 20)
                tag.StudsOffset = Vector3.new(0, 2.5, 0)
                tag.AlwaysOnTop = true

                local label = Instance.new("TextLabel", tag)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = ESPColor
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold

                data.nametag = tag
            end)
        end
    end

    -- if character currently exists, spawn
    if player.Character then
        spawnForCharacter(player.Character)
    end

    -- reconnect on respawn
    local charConn = player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        spawnForCharacter(char)
    end)
    table.insert(data.conns, charConn)

    -- cleanup when player leaves
    local leaveConn = Players.PlayerRemoving:Connect(function(p)
        if p == player then clearPlayerESP(p) end
    end)
    table.insert(data.conns, leaveConn)
end

-- Start / Stop RGB task
local function startRGBTask()
    if rgbTask then return end
    rgbTask = task.spawn(function()
        while RGBSelected do
            ESPColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            applyColorToAll()
            task.wait(0.1)
        end
        rgbTask = nil
    end)
end

local function stopRGBTask()
    RGBSelected = false
    -- rgbTask will exit on next loop automatically
end

-- Toggle für ESP im GUI
MainTab:CreateToggle({
    Name = "ESP (Outline + NameTag)",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state

        if not state then
            -- disable: clear all and stop rgb
            clearAllESP()
            stopRGBTask()
            return
        end

        -- enable: create for existing players
        for _, player in ipairs(Players:GetPlayers()) do
            createESPForPlayer(player)
        end

        -- ensure we create ESP for newly joined players
        globalConns.playerAdded = Players.PlayerAdded:Connect(function(p)
            task.wait(0.2)
            createESPForPlayer(p)
        end)
    end
})

-- Clear Button
MainTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        clearAllESP()
        stopRGBTask()
    end
})

-- Dropdown (wählt pendingColor oder RGB)
MainTab:CreateDropdown({
    Name = "ESP Color",
    Options = {"Red", "Green", "Blue", "Yellow", "White", "Cyan", "Magenta", "RGB"},
    CurrentOption = "Red",
    Callback = function(option)
        -- Reset RGBSelected flag (we only start RGB once user hits Apply)
        RGBSelected = false

        if option == "Red" then
            pendingColor = Color3.fromRGB(255,0,0)
        elseif option == "Green" then
            pendingColor = Color3.fromRGB(0,255,0)
        elseif option == "Blue" then
            pendingColor = Color3.fromRGB(0,0,255)
        elseif option == "Yellow" then
            pendingColor = Color3.fromRGB(255,255,0)
        elseif option == "White" then
            pendingColor = Color3.fromRGB(255,255,255)
        elseif option == "Cyan" then
            pendingColor = Color3.fromRGB(0,255,255)
        elseif option == "Magenta" then
            pendingColor = Color3.fromRGB(255,0,255)
        elseif option == "RGB" then
            -- mark as selected but don't start until Apply pressed
            pendingColor = nil
            RGBSelected = true
        end
    end
})

-- Apply Color Button: erzwingt Farbanpassung sofort (auch wenn ESP bereits an ist)
MainTab:CreateButton({
    Name = "Apply Color",
    Callback = function()
        if RGBSelected then
            -- start RGB loop (updates ESPColor each 0.1s)
            startRGBTask()
        else
            -- apply pendingColor immediately
            if pendingColor then
                ESPColor = pendingColor
                -- update existing ESP objects immediately
                applyColorToAll()
            end
        end
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

        -- Freefall-ZustÃ¤nde abfangen
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

----------------------------------------------------
-- Aimbot
----------------------------------------------------
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
local AimbotKey = "T" -- Default Key

-- Create Tab
local AimbotTab = Window:CreateTab("| Aimbot", 10769687353)

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

-- PC Aimbot Toggle
AimbotTab:CreateToggle({
    Name = "Enable Aimbot (PC)",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

-- PC FOV Toggle
AimbotTab:CreateToggle({
    Name = "Show FOV Circle (PC)",
    CurrentValue = false,
    Callback = function(Value)
        ShowFOV = Value
        CreateFOVCircle()
    end
})

-- Keybind Input (PC)
AimbotTab:CreateInput({
    Name = "Aimbot Key (PC)",
    PlaceholderText = "Press key (Default: T)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and #Text > 0 then
            AimbotKey = Text:upper()
        end
    end
})

-- Keybind Toggle Handling
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode.Name == AimbotKey then
            AimbotEnabled = not AimbotEnabled
            ShowFOV = AimbotEnabled
            CreateFOVCircle()
        end
    end
end)

----------------------------------------------------
-- ðŸ“± Handy-GUI System
----------------------------------------------------
local PhoneGui -- referenz auf das GUI
local PhoneToggleButton -- referenz auf den On/Off-Button
local PhoneAimbotState = false -- Zustand im GUI

-- Funktion zum Erstellen des GUIs
local function CreatePhoneGui()
    PhoneGui = Instance.new("ScreenGui")
    PhoneGui.Name = "PhoneAimbotGui"
    PhoneGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.25, 0, 0.12, 0) -- klein
    Frame.Position = UDim2.new(0.7, 0, 0.45, 0) -- rechts Mitte
    Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = PhoneGui

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0,15)

    -- On/Off Button
    PhoneToggleButton = Instance.new("TextButton")
    PhoneToggleButton.Size = UDim2.new(0.8, 0, 0.6, 0)
    PhoneToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    PhoneToggleButton.Text = "OFF"
    PhoneToggleButton.TextScaled = true
    PhoneToggleButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
    PhoneToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
    PhoneToggleButton.Parent = Frame
    Instance.new("UICorner", PhoneToggleButton).CornerRadius = UDim.new(0,10)

    -- Button Logik
    PhoneToggleButton.MouseButton1Click:Connect(function()
        PhoneAimbotState = not PhoneAimbotState
        if PhoneAimbotState then
            PhoneToggleButton.Text = "ON"
            PhoneToggleButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
            AimbotEnabled = true
            ShowFOV = true
            CreateFOVCircle()
        else
            PhoneToggleButton.Text = "OFF"
            PhoneToggleButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
            AimbotEnabled = false
            ShowFOV = false
            CreateFOVCircle()
        end
    end)
end

-- Funktion zum Entfernen des GUIs
local function RemovePhoneGui()
    if PhoneGui then
        PhoneGui:Destroy()
        PhoneGui = nil
        PhoneAimbotState = false
    end
end

-- ðŸ“± Toggle im Rayfield-MenÃ¼
AimbotTab:CreateToggle({
    Name = "Phone Aimbot GUI",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            if not PhoneGui then
                CreatePhoneGui()
            end
        else
            RemovePhoneGui()
        end
    end
})

-- TELEPORT TAB
local TeleportTab = Window:CreateTab("| Teleport",138281706845765)

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
            Content = "Kein Spieler ausgewÃ¤hlt.",
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

-- Spieler beim Start hinzufÃ¼gen
UpdateDropdown()

-- Neue Spieler dynamisch hinzufÃ¼gen
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
