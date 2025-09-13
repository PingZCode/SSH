-- Definition der Themes
local Themes = {
    ["Default"] = "Default",
    ["Amber Glow"] = "AmberGlow",
    ["Amethyst"] = "Amethyst",
    ["Bloom"] = "Bloom",
    ["Dark Blue"] = "DarkBlue",
    ["Green"] = "Green",
    ["Light"] = "Light",
    ["Ocean"] = "Ocean",
    ["Serenity"] = "Serenity"
}

local SelectedTheme = "Default"

-- Funktion zum Erstellen des Fensters
local function CreateWindow(theme)
    -- Laden der Rayfield-Bibliothek
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    if Rayfield == nil then
        warn("Rayfield konnte nicht geladen werden!")
        return nil
    end

    local Window = Rayfield:CreateWindow({
        Name = "Silent Scripts V1.8",
        Icon = 0,
        LoadingTitle = "Loading...",
        LoadingSubtitle = "by Pingz0",
        ShowText = "Silent Script",
        Theme = theme or "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
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

    -- Funktion zum Starten
    local function startFly()
        if flying then return end
        flying = true
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = rootPart

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
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
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local noclipEnabled = false
local noclipConnection = nil

local function setCollision(state)
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = state
            end
        end
        if not state then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid.Sit then
                    humanoid.Sit = false
                end
                humanoid.Jump = true
            end
        end
    end
end

local function setNoclip(state)
    noclipEnabled = state
    if state then
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        setCollision(false)
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled and player.Character then
                setCollision(false)
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        setCollision(true)
    end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    task.wait(0.1)
    if noclipEnabled then
        setCollision(false)
    else
        setCollision(true)
    end
end)

if player.Character then
    task.wait(0.1)
    setCollision(true)
end

local NoclipToggle = MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        setNoclip(Value)
    end,
})

    local ESPDrawings = {}
    local ESPConnections = {}
    local ESPEnabled = false
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local ESPColor = Color3.new(1, 0, 0) -- Rot (default)

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

    -- ESP Toggle
    MainTab:CreateToggle({
        Name = "ESP (Red Outline + NameTag)",
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

    -- Extra Button: Clear ESP
    MainTab:CreateButton({
        Name = "Clear All ESP",
        Callback = function()
            clearAllESP()
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

----------------------------------------------------
-- Services
----------------------------------------------------
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

----------------------------------------------------
-- Aimbot Settings
----------------------------------------------------
local AimbotEnabled = false
local ShowFOV = false
local FOVRadius = 100
local DynamicFOVRadius = FOVRadius -- Dynamic FOV for tracking
local FOVCircle
local AimbotKey = "T"
local Smoothness = 0.2 -- Default smoothness (0.05 to 0.5)
local CurrentTarget = nil -- Track current target for stickiness
local MaxFOVIncrease = 1.5 -- Max FOV increase factor (e.g., 1.5x)

----------------------------------------------------
-- Aimbot Tab
----------------------------------------------------
local AimbotTab = Window:CreateTab("| Aimbot", 10769687353)

-- Smooth RGB Color Cycle
local function GetRGBColor()
    local time = tick() * 0.5 -- Slower color change
    local r = (math.sin(time) + 1) / 2
    local g = (math.sin(time + 2 * math.pi / 3) + 1) / 2
    local b = (math.sin(time + 4 * math.pi / 3) + 1) / 2
    return Color3.new(r, g, b)
end

-- Draw FOV Circle
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    if ShowFOV then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = DynamicFOVRadius
        FOVCircle.Thickness = 2
        FOVCircle.Color = GetRGBColor()
        FOVCircle.Filled = false
        FOVCircle.Visible = true
    end
end

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    if FOVCircle and ShowFOV then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = DynamicFOVRadius
        FOVCircle.Color = GetRGBColor()
    elseif not ShowFOV and FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
end)

-- Find Closest Target with Enhanced Stickiness
local function GetClosestPlayer()
    local closestPlayer = CurrentTarget
    local shortestDistance = DynamicFOVRadius * 1.5 -- Larger radius for current target
    local cameraCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Check if current target is still valid
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local head = closestPlayer.Character.Head
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local distance = (Vector2.new(headPos.X, headPos.Y) - cameraCenter).Magnitude
            if distance > shortestDistance then
                closestPlayer = nil -- Lose target if it moves too far
            end
        else
            closestPlayer = nil -- Lose target if not on screen
        end
    else
        closestPlayer = nil
    end

    -- Find new target if no valid current target
    if not closestPlayer then
        shortestDistance = DynamicFOVRadius
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(headPos.X, headPos.Y) - cameraCenter).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    CurrentTarget = closestPlayer
    return closestPlayer
end

-- Aimbot Loop with Predictive Tracking and Dynamic FOV
RunService.RenderStepped:Connect(function(deltaTime)
    if AimbotEnabled then
        local target = GetClosestPlayer()
        DynamicFOVRadius = FOVRadius -- Reset dynamic FOV
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local headPos = head.Position
            -- Basic predictive tracking using velocity
            local velocity = head.Velocity
            local prediction = headPos + velocity * 0.1 -- Predict 0.1 seconds ahead
            local targetCFrame = CFrame.new(Camera.CFrame.Position, prediction)

            -- Dynamic smoothness based on distance and speed
            local headScreenPos, _ = Camera:WorldToViewportPoint(headPos)
            local distance = (Vector2.new(headScreenPos.X, headScreenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            local speed = velocity.Magnitude
            local dynamicSmoothness = math.clamp(Smoothness * (1 + distance / FOVRadius + speed / 50), 0.05, 0.5)

            -- Dynamic FOV increase if target is near edge
            if distance > FOVRadius * 0.8 then
                DynamicFOVRadius = math.min(FOVRadius * MaxFOVIncrease, FOVRadius + distance)
            end

            -- Smoothly interpolate camera rotation
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, dynamicSmoothness)
        end
    end
end)

----------------------------------------------------
-- Rayfield Controls
----------------------------------------------------
AimbotTab:CreateToggle({
    Name = "Enable Aimbot (PC)",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(Value)
        ShowFOV = Value
        CreateFOVCircle()
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Changer",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Callback = function(Value)
        FOVRadius = Value
        DynamicFOVRadius = Value
        CreateFOVCircle()
    end
})

AimbotTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "factor",
    CurrentValue = 0.2,
    Callback = function(Value)
        Smoothness = Value
    end
})

AimbotTab:CreateInput({
    Name = "Aimbot Key (PC)",
    PlaceholderText = "Default: T",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and #Text > 0 then
            AimbotKey = Text:upper()
        end
    end
})

-- Keybind Toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode.Name == AimbotKey then
            AimbotEnabled = not AimbotEnabled
        end
    end
end)

----------------------------------------------------
--  Phone GUI System
----------------------------------------------------
local PhoneGui
local PhoneToggleButton

local function CreatePhoneGui()
    PhoneGui = Instance.new("ScreenGui")
    PhoneGui.Name = "PhoneAimbotGui"
    PhoneGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.25, 0, 0.12, 0)
    Frame.Position = UDim2.new(0.7, 0, 0.45, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = PhoneGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 15)

    PhoneToggleButton = Instance.new("TextButton")
    PhoneToggleButton.Size = UDim2.new(0.8, 0, 0.6, 0)
    PhoneToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    PhoneToggleButton.Text = AimbotEnabled and "ON" or "OFF"
    PhoneToggleButton.TextScaled = true
    PhoneToggleButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    PhoneToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PhoneToggleButton.Parent = Frame
    Instance.new("UICorner", PhoneToggleButton).CornerRadius = UDim.new(0, 10)

    PhoneToggleButton.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        ShowFOV = AimbotEnabled -- Sync FOV with aimbot for phone GUI
        PhoneToggleButton.Text = AimbotEnabled and "ON" or "OFF"
        PhoneToggleButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        CreateFOVCircle()
    end)
end

local function RemovePhoneGui()
    if PhoneGui then
        PhoneGui:Destroy()
        PhoneGui = nil
    end
end

--  Toggle in Rayfield Menu
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
local TeleportTab = Window:CreateTab("| Teleport", 138281706845765)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local selectedPlayerName = nil
local customTeleportPosition = nil
local customSpawnPosition = nil
local clickTeleportEnabled = false
local touchTeleportEnabled = false

-- Dropdown for player selection
local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Teleport to Player",
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

-- Button to teleport to selected player
TeleportTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not selectedPlayerName then
            Rayfield:Notify({
                Title = "Error",
                Content = "No player selected.",
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

-- Function to update player dropdown
local function UpdateDropdown()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    PlayerDropdown:Refresh(names, true)
end

-- Initialize dropdown
UpdateDropdown()

-- Update dropdown when players join or leave
Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    UpdateDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    UpdateDropdown()
end)

-- Function to set teleport point
local function setTeleportPoint()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        customTeleportPosition = LocalPlayer.Character.HumanoidRootPart.Position
        Rayfield:Notify({
            Title = "TPpoint Set",
            Content = "Position: " .. tostring(customTeleportPosition),
            Duration = 5,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "HumanoidRootPart not found! Please report in our Discord.",
            Duration = 5,
            Image = 4483362458
        })
    end
end

-- Function to set spawn point
local function setSpawnPoint()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        customSpawnPosition = LocalPlayer.Character.HumanoidRootPart.Position
        Rayfield:Notify({
            Title = "Spawn Point Set",
            Content = "Spawn Position: " .. tostring(customSpawnPosition),
            Duration = 5,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "HumanoidRootPart not found! Please report in our Discord.",
            Duration = 5,
            Image = 4483362458
        })
    end
end

-- Handle character spawn
LocalPlayer.CharacterAdded:Connect(function(character)
    if customSpawnPosition then
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(customSpawnPosition + Vector3.new(0, 5, 0))
    end
end)

-- Mouse Click TP functionality
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and clickTeleportEnabled and not gameProcessedEvent then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local mouse = LocalPlayer:GetMouse()
            local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if raycastResult then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 5, 0))
                Rayfield:Notify({
                    Title = "Click Teleport",
                    Content = "Teleported to clicked position!",
                    Duration = 4,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Click Teleport Failed",
                    Content = "No valid surface found at clicked position.",
                    Duration = 4,
                    Image = 4483362458
                })
            end
        end
    end
end)

-- Touch TP functionality (for phones)
UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
    if touchTeleportEnabled and not gameProcessedEvent and #touchPositions > 0 then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local touchPos = touchPositions[1] -- Use the first touch position
            local ray = workspace.CurrentCamera:ScreenPointToRay(touchPos.X, touchPos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if raycastResult then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 5, 0))
                Rayfield:Notify({
                    Title = "Touch Teleport",
                    Content = "Teleported to tapped position!",
                    Duration = 4,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Touch Teleport Failed",
                    Content = "No valid surface found at tapped position.",
                    Duration = 4,
                    Image = 4483362458
                })
            end
        end
    end
end)

-- Button to set TPpoint
TeleportTab:CreateButton({
    Name = "Set TPpoint",
    Callback = setTeleportPoint
})

-- Button to teleport to TPpoint
TeleportTab:CreateButton({
    Name = "Teleport to TPpoint",
    Callback = function()
        if customTeleportPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(customTeleportPosition + Vector3.new(0, 5, 0))
            Rayfield:Notify({
                Title = "Teleported!",
                Content = "You have been moved to your saved TPpoint.",
                Duration = 4,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "Make sure you set a TPpoint first.",
                Duration = 4,
                Image = 4483362458
            })
        end
    end
})

-- Button to set spawn point
TeleportTab:CreateButton({
    Name = "Change Spawn Point",
    Callback = setSpawnPoint
})

-- Toggle for Mouse Click TP
TeleportTab:CreateToggle({
    Name = "Enable Click TP",
    CurrentValue = false,
    Callback = function(value)
        clickTeleportEnabled = value
        Rayfield:Notify({
            Title = "Click TP",
            Content = value and "Click TP enabled. Click anywhere to teleport." or "Click TP disabled.",
            Duration = 4,
            Image = 4483362458
        })
    end
})

-- Toggle for Touch TP (Phone)
TeleportTab:CreateToggle({
    Name = "Enable Click TP (Phone)",
    CurrentValue = false,
    Callback = function(value)
        touchTeleportEnabled = value
        Rayfield:Notify({
            Title = "Touch TP",
            Content = value and "Touch TP enabled. Tap anywhere to teleport." or "Touch TP disabled.",
            Duration = 4,
            Image = 4483362458
        })
    end
})

    -- Settings Tab
    local SettingsTab = Window:CreateTab("| Settings", 6034509993)

    -- Dropdown für Theme-Auswahl
    local themeNames = {}
    for name, _ in pairs(Themes) do table.insert(themeNames, name) end

    SettingsTab:CreateDropdown({
        Name = "Select Theme",
        Options = themeNames,
        CurrentOption = {SelectedTheme},
        MultipleOptions = false,
        Callback = function(option)
            local o = option
            if type(o) == "table" then o = o[1] end
            if type(o) == "string" then SelectedTheme = o end
        end
    })

    -- Apply Button: Fenster sicher neu erstellen
    SettingsTab:CreateButton({
        Name = "Apply Theme",
        Callback = function()
            local themeToApply = Themes[SelectedTheme] or "Default"
            task.defer(function() -- defer verhindert callback errors
                if Window and typeof(Window.Destroy) == "function" then
                    Window:Destroy()
                end
                CreateWindow(themeToApply)
            end)
        end
    })

    return Window
end

-- Überprüfung und Aufruf der Funktion
if CreateWindow == nil then
    warn("CreateWindow ist nicht definiert!")
    return
end
CreateWindow(SelectedTheme)
