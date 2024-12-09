local HttpService = game:GetService("HttpService")

-- GitHub URL to the JSON file containing keys
local githubURL = "https://raw.githubusercontent.com/yourUsername/yourRepository/main/keys.json"

-- Cache for keys
local keysData = {}

-- Function to load keys from GitHub
local function loadKeys()
    local success, result = pcall(function()
        return HttpService:GetAsync(githubURL)
    end)
    if success then
        local data = HttpService:JSONDecode(result)
        keysData = data.keys or {}
        print("Keys successfully loaded!")
    else
        warn("Failed to load keys: " .. tostring(result))
    end
end

-- Load keys at the start
loadKeys()

-- Periodically update keys, e.g., every 10 minutes
task.spawn(function()
    while true do
        loadKeys()
        task.wait(600) -- 600 seconds = 10 minutes
    end
end)

-- Function to validate the key
local function validateKey(playerName, enteredKey)
    local correctKey = keysData[playerName]
    if not correctKey then
        return false, "No key found for this player."
    end
    if enteredKey == correctKey then
        return true, "Key correct! Access granted."
    else
        return false, "Invalid key. Access denied."
    end
end

-- Function to create the GUI for key input
local function createKeyGui(player)
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGui"

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Enter your Key"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Parent = frame

    -- TextBox for key input
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0.3, 0)
    textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
    textBox.PlaceholderText = "Enter your key..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.new(1, 1, 1)
    textBox.TextColor3 = Color3.new(0, 0, 0)
    textBox.Parent = frame

    -- Confirm button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.2, 0)
    button.Position = UDim2.new(0.1, 0, 0.75, 0)
    button.Text = "Confirm"
    button.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = frame

    -- GUI parented to PlayerGui
    screenGui.Parent = playerGui

    -- Button click logic
    button.MouseButton1Click:Connect(function()
        local enteredKey = textBox.Text
        local isValid, response = validateKey(player.Name, enteredKey)

        if isValid then
            print(player.Name .. ": Access granted.")
            screenGui:Destroy() -- Remove the GUI
            -- Execute the loadstring
            local success, err = pcall(function()
                loadstring("print('" .. player.Name .. " has executed a script!')")()
            end)
            if not success then
                warn("Error executing loadstring: " .. err)
            end
        else
            textBox.Text = ""
            title.Text = response
            title.TextColor3 = Color3.new(1, 0, 0) -- Red for error
        end
    end)
end

-- Player event
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createKeyGui(player)
    end)
end)
