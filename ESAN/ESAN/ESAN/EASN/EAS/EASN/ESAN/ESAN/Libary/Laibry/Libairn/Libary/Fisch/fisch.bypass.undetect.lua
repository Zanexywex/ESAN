local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = playerGui:FindFirstChild("NotifyGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotifyGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
end

local container = screenGui:FindFirstChild("NotifyContainer")
if not container then
    container = Instance.new("Frame")
    container.Name = "NotifyContainer"
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position = UDim2.new(0.5, 0, 0, 40)
    container.Size = UDim2.new(0, 360, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    container.ClipsDescendants = false
    container.AutomaticSize = Enum.AutomaticSize.Y

    local uiList = Instance.new("UIListLayout")
    uiList.Name = "Layout"
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 8)
    uiList.Parent = container
end

local NOTIFY_WIDTH = 360
local NOTIFY_HEIGHT = 80
local MAX_NOTIFIES = 6

local function makeNotifyFrame(title, desc)
    local frame = Instance.new("Frame")
    frame.Name = "NotifyFrame"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = -math.floor(tick() * 1000)

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0, 0)
    card.Position = UDim2.new(0, 0, 0, 0)
    card.Size = UDim2.new(1, 0, 0, NOTIFY_HEIGHT)
    card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    card.BorderSizePixel = 0
    card.Parent = frame
    card.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -16, 0, 24)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top
    titleLabel.Text = tostring(title or "")
    titleLabel.TextTransparency = 1 -- start hidden
    titleLabel.Parent = card

    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Desc"
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(1, -16, 0, 44)
    descLabel.Position = UDim2.new(0, 12, 0, 30)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 14
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.RichText = false
    descLabel.Text = tostring(desc or "")
    descLabel.TextTransparency = 1 -- start hidden
    descLabel.Parent = card

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 48, 0, 48)
    icon.Position = UDim2.new(0, 12, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://106249685759117" -- << ไอคอน
    icon.Parent = card
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = icon

    card.Active = true
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            frame:SetAttribute("forceRemove", true)
        end
    end)

    return frame
end

local function trimOld()
    local children = container:GetChildren()
    local notifies = {}
    for _,c in ipairs(children) do
        if c.Name == "NotifyFrame" then
            table.insert(notifies, c)
        end
    end
    table.sort(notifies, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
    while #notifies > MAX_NOTIFIES do
        local oldest = table.remove(notifies)
        if oldest and oldest.Parent then
            oldest:SetAttribute("forceRemove", true)
        end
    end
end

function notify(title, description, duration)
    duration = tonumber(duration) or 3
    local frame = makeNotifyFrame(title, description)
    frame.Parent = container
    trimOld()

    local openTween = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, NOTIFY_HEIGHT)})
    local card = frame:FindFirstChild("Card")
    card.BackgroundTransparency = 1
    local fadeIn = TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 0})

    openTween:Play()
    fadeIn:Play()

    -- Fade in text
    local titleLabel = card:FindFirstChild("Title")
    local descLabel = card:FindFirstChild("Desc")
    if titleLabel then
        TweenService:Create(titleLabel, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    end
    if descLabel then
        TweenService:Create(descLabel, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    end

    -- Icon animation
    local icon = card:FindFirstChild("Icon")
    if icon then
        icon.Size = UDim2.new(0, 0, 0, 0)
        local iconTween = TweenService:Create(icon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 48, 0, 48)})
        iconTween:Play()
    end

    -- Wait until time runs out
    local t0 = tick()
    while tick() - t0 < duration do
        if frame:GetAttribute("forceRemove") then break end
        task.wait(0.1)
    end

    -- Fade out
    local closeTween = TweenService:Create(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(1, 0, 0, 0)})
    local fadeOut = TweenService:Create(card, TweenInfo.new(0.22), {BackgroundTransparency = 1})

    if titleLabel then
        TweenService:Create(titleLabel, TweenInfo.new(0.22), {TextTransparency = 1}):Play()
    end
    if descLabel then
        TweenService:Create(descLabel, TweenInfo.new(0.22), {TextTransparency = 1}):Play()
    end

    closeTween:Play()
    fadeOut:Play()
    closeTween.Completed:Wait()
    frame:Destroy()
end

_G.robloxNotify = notify
screenGui:SetAttribute("notifyFunctionAvailable", true)

return notify
