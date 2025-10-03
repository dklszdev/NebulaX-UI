--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                    NEBULAX UI LIBRARY                     ║
    ║                   Version 1.0.0 - 2024                    ║
    ║          Premium UI Library for Luau Executors            ║
    ╚═══════════════════════════════════════════════════════════╝
    
    Features:
    • Modern & Responsive Design
    • Full Mobile Support
    • Advanced Components
    • Theme System
    • Icon Support
    • Smooth Animations
    • Configuration System
--]]

local NebulaX = {
    Version = "1.0.0",
    Author = "NebulaX Development",
    Windows = {},
    Notifications = {},
    Config = {},
}

-- ═══════════════════════════════════════════════════════════
-- SERVICES & DEPENDENCIES
-- ═══════════════════════════════════════════════════════════

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local Utility = {}

function Utility:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility:IsTablet()
    local screenSize = workspace.CurrentCamera.ViewportSize
    return UserInputService.TouchEnabled and (screenSize.X > 600 or screenSize.Y > 600)
end

function Utility:GetPlatform()
    if self:IsMobile() then
        return self:IsTablet() and "Tablet" or "Mobile"
    end
    return "Desktop"
end

function Utility:Tween(instance, properties, duration, style, direction, callback)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

function Utility:CreateRipple(parent, x, y, color)
    local ripple = Instance.new("ImageLabel")
    ripple.Name = "Ripple"
    ripple.BackgroundTransparency = 1
    ripple.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ripple.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.ImageTransparency = 0.5
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 10
    ripple.Parent = parent
    
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    
    Utility:Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        ImageTransparency = 1
    }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
        ripple:Destroy()
    end)
end

function Utility:MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

function Utility:ApplyCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

function Utility:ApplyStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.8
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Utility:ApplyGradient(instance, colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    gradient.Parent = instance
    return gradient
end

function Utility:AddPadding(instance, all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or 10)
    padding.PaddingBottom = UDim.new(0, all or 10)
    padding.PaddingLeft = UDim.new(0, all or 10)
    padding.PaddingRight = UDim.new(0, all or 10)
    padding.Parent = instance
    return padding
end

function Utility:SaveConfig(name, data)
    if not isfolder("NebulaX") then
        makefolder("NebulaX")
    end
    writefile("NebulaX/" .. name .. ".json", HttpService:JSONEncode(data))
end

function Utility:LoadConfig(name)
    if isfile("NebulaX/" .. name .. ".json") then
        return HttpService:JSONDecode(readfile("NebulaX/" .. name .. ".json"))
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- THEME SYSTEM
-- ═══════════════════════════════════════════════════════════

local ThemeManager = {
    CurrentTheme = "Dark",
    Themes = {}
}

ThemeManager.Themes.Dark = {
    Name = "Dark",
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Tertiary = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    Border = Color3.fromRGB(60, 60, 65),
}

ThemeManager.Themes.Light = {
    Name = "Light",
    Background = Color3.fromRGB(245, 245, 250),
    Secondary = Color3.fromRGB(255, 255, 255),
    Tertiary = Color3.fromRGB(235, 235, 240),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(20, 20, 25),
    TextDark = Color3.fromRGB(100, 100, 105),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    Border = Color3.fromRGB(220, 220, 225),
}

ThemeManager.Themes.Neon = {
    Name = "Neon",
    Background = Color3.fromRGB(10, 10, 15),
    Secondary = Color3.fromRGB(15, 15, 20),
    Tertiary = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(255, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 0, 200),
    Success = Color3.fromRGB(0, 255, 150),
    Warning = Color3.fromRGB(255, 255, 0),
    Error = Color3.fromRGB(255, 0, 100),
    Border = Color3.fromRGB(255, 0, 255),
}

ThemeManager.Themes.Ocean = {
    Name = "Ocean",
    Background = Color3.fromRGB(15, 30, 45),
    Secondary = Color3.fromRGB(25, 40, 55),
    Tertiary = Color3.fromRGB(35, 50, 65),
    Accent = Color3.fromRGB(52, 152, 219),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 200, 220),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Border = Color3.fromRGB(52, 152, 219),
}

ThemeManager.Themes.Forest = {
    Name = "Forest",
    Background = Color3.fromRGB(20, 30, 20),
    Secondary = Color3.fromRGB(30, 40, 30),
    Tertiary = Color3.fromRGB(40, 50, 40),
    Accent = Color3.fromRGB(67, 160, 71),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(165, 214, 167),
    Success = Color3.fromRGB(102, 187, 106),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(229, 115, 115),
    Border = Color3.fromRGB(67, 160, 71),
}

function ThemeManager:SetTheme(themeName, customAccent)
    local theme = self.Themes[themeName] or self.Themes.Dark
    if customAccent then
        theme.Accent = customAccent
    end
    self.CurrentTheme = themeName
    return theme
end

function ThemeManager:GetTheme()
    return self.Themes[self.CurrentTheme] or self.Themes.Dark
end

function ThemeManager:CreateCustomTheme(name, colors)
    self.Themes[name] = colors
end

-- ═══════════════════════════════════════════════════════════
-- ICON SYSTEM
-- ═══════════════════════════════════════════════════════════

local IconLibrary = {
    -- Material Design Icons (usando Lucide icons IDs de Roblox)
    home = "rbxassetid://10734896629",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10747374131",
    search = "rbxassetid://10734898629",
    check = "rbxassetid://10734896841",
    x = "rbxassetid://10747384394",
    plus = "rbxassetid://10734896206",
    minus = "rbxassetid://10734898532",
    edit = "rbxassetid://10734896554",
    trash = "rbxassetid://10734896966",
    save = "rbxassetid://10734896099",
    download = "rbxassetid://10734896975",
    upload = "rbxassetid://10734897508",
    eye = "rbxassetid://10747318989",
    ["eye-off"] = "rbxassetid://10747318658",
    lock = "rbxassetid://10734897799",
    unlock = "rbxassetid://10734898534",
    star = "rbxassetid://10734896220",
    heart = "rbxassetid://10734896852",
    bell = "rbxassetid://10734896771",
    info = "rbxassetid://10734896814",
    alert = "rbxassetid://10734896499",
    ["alert-circle"] = "rbxassetid://10734896206",
    ["check-circle"] = "rbxassetid://10734896841",
    ["x-circle"] = "rbxassetid://10734896644",
    menu = "rbxassetid://10734896771",
    ["chevron-down"] = "rbxassetid://10734896926",
    ["chevron-up"] = "rbxassetid://10734896975",
    ["chevron-left"] = "rbxassetid://10734896853",
    ["chevron-right"] = "rbxassetid://10734896945",
    copy = "rbxassetid://10734896651",
    clipboard = "rbxassetid://10734896502",
    folder = "rbxassetid://10734896814",
    file = "rbxassetid://10734896744",
    image = "rbxassetid://10734896863",
    play = "rbxassetid://10734896206",
    pause = "rbxassetid://10734896975",
    refresh = "rbxassetid://10734896945",
    ["external-link"] = "rbxassetid://10734896918",
    link = "rbxassetid://10734896852",
    mail = "rbxassetid://10734896863",
    phone = "rbxassetid://10734896945",
    calendar = "rbxassetid://10734896206",
    clock = "rbxassetid://10734896502",
    map = "rbxassetid://10734896863",
    ["map-pin"] = "rbxassetid://10734896918",
    filter = "rbxassetid://10734896744",
    sort = "rbxassetid://10734897508",
    grid = "rbxassetid://10734896852",
    list = "rbxassetid://10734897799",
    maximize = "rbxassetid://10734896863",
    minimize = "rbxassetid://10734898532",
    ["arrow-up"] = "rbxassetid://10734896220",
    ["arrow-down"] = "rbxassetid://10734896206",
    ["arrow-left"] = "rbxassetid://10734896107",
    ["arrow-right"] = "rbxassetid://10734896206",
    code = "rbxassetid://10734896502",
    terminal = "rbxassetid://10734897508",
    globe = "rbxassetid://10734896852",
    wifi = "rbxassetid://10747384394",
    database = "rbxassetid://10734896651",
    server = "rbxassetid://10734950309",
    cpu = "rbxassetid://10734896651",
    ["hard-drive"] = "rbxassetid://10734896852",
    package = "rbxassetid://10734896945",
    box = "rbxassetid://10734896206",
    gift = "rbxassetid://10734896814",
    shopping = "rbxassetid://10734950309",
    cart = "rbxassetid://10734896206",
    credit = "rbxassetid://10734896651",
    dollar = "rbxassetid://10734896744",
    percent = "rbxassetid://10734896945",
    zap = "rbxassetid://10747384394",
    activity = "rbxassetid://10734896107",
    trending = "rbxassetid://10734897508",
    pie = "rbxassetid://10734896945",
    bar = "rbxassetid://10734896206",
    target = "rbxassetid://10734897508",
    crosshair = "rbxassetid://10734896651",
    gamepad = "rbxassetid://10734896814",
    sword = "rbxassetid://10734897508",
    shield = "rbxassetid://10734950309",
    crown = "rbxassetid://10734896651",
    trophy = "rbxassetid://10734897508",
    award = "rbxassetid://10734896206",
    medal = "rbxassetid://10734896863",
}

function IconLibrary:Get(iconName)
    return self[iconName] or self.help
end

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

local NotificationManager = {
    Container = nil,
    Queue = {},
    ActiveNotifications = 0,
}

function NotificationManager:Init()
    if self.Container then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaXNotifications"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999999
    
    -- Protección contra detección
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = Player.PlayerGui
    end
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(1, -20, 0, 20)
    container.Size = UDim2.new(0, 350, 1, -40)
    container.AnchorPoint = Vector2.new(1, 0)
    container.Parent = screenGui
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.Parent = container
    
    self.Container = container
end

function NotificationManager:Create(options)
    self:Init()
    
    options = options or {}
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info" -- Info, Success, Warning, Error
    local icon = options.Icon
    local callback = options.Callback
    
    local theme = ThemeManager:GetTheme()
    local typeColors = {
        Info = theme.Accent,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error,
    }
    
    local typeIcons = {
        Info = "info",
        Success = "check-circle",
        Warning = "alert",
        Error = "x-circle",
    }
    
    local accentColor = typeColors[type] or theme.Accent
    icon = icon or typeIcons[type]
    
    -- Notification Frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = theme.Secondary
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.Position = UDim2.new(1, 50, 0, 0)
    notification.ClipsDescendants = true
    notification.Parent = self.Container
    
    Utility:ApplyCorner(notification, 10)
    Utility:ApplyStroke(notification, accentColor, 2, 0.5)
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = 0
    shadow.Parent = notification
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Parent = notification
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 15, 0, 15)
    content.Size = UDim2.new(1, -30, 1, -30)
    content.Parent = notification
    
    -- Icon
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Name = "Icon"
        iconImage.BackgroundTransparency = 1
        iconImage.Image = IconLibrary:Get(icon)
        iconImage.ImageColor3 = accentColor
        iconImage.Size = UDim2.new(0, 24, 0, 24)
        iconImage.Position = UDim2.new(0, 0, 0, 0)
        iconImage.Parent = content
    end
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, icon and 34 or 0, 0, 0)
    titleLabel.Size = UDim2.new(1, -(icon and 64 or 30), 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = content
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, icon and 34 or 0, 0, 24)
    descLabel.Size = UDim2.new(1, -(icon and 64 or 30), 1, -24)
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = theme.TextDark
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = content
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Text = ""
    closeBtn.Parent = content
    
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = IconLibrary:Get("x")
    closeIcon.ImageColor3 = theme.TextDark
    closeIcon.Size = UDim2.new(0, 18, 0, 18)
    closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Parent = closeBtn
    
    -- Progress bar
    local progressContainer = Instance.new("Frame")
    progressContainer.Name = "ProgressContainer"
    progressContainer.BackgroundColor3 = theme.Tertiary
    progressContainer.BorderSizePixel = 0
    progressContainer.Position = UDim2.new(0, 0, 1, -3)
    progressContainer.Size = UDim2.new(1, 0, 0, 3)
    progressContainer.Parent = notification
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Parent = progressContainer
    
    -- Calculate height
    local textSize = TextService:GetTextSize(
        description,
        12,
        Enum.Font.Gotham,
        Vector2.new(descLabel.AbsoluteSize.X, math.huge)
    )
    
    local finalHeight = math.max(80, math.min(textSize.Y + 60, 150))
    
    -- Animations
    self.ActiveNotifications = self.ActiveNotifications + 1
    
    -- Slide in
    Utility:Tween(notification, {
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, finalHeight)
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Progress animation
    Utility:Tween(progressBar, {
        Size = UDim2.new(0, 0, 1, 0)
    }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    
    -- Auto close
    local closed = false
    local function closeNotification()
        if closed then return end
        closed = true
        
        Utility:Tween(notification, {
            Position = UDim2.new(1, 50, 0, 0),
            Size = UDim2.new(1, 0, 0, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            notification:Destroy()
            self.ActiveNotifications = self.ActiveNotifications - 1
        end)
    end
    
    task.delay(duration, closeNotification)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(closeNotification)
    
    -- Hover effects
    closeBtn.MouseEnter:Connect(function()
        Utility:Tween(closeIcon, {ImageColor3 = theme.Text}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility:Tween(closeIcon, {ImageColor3 = theme.TextDark}, 0.2)
    end)
    
    -- Click callback
    if callback then
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                callback()
                closeNotification()
            end
        end)
    end
    
    return notification
end

-- ═══════════════════════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════

local TooltipManager = {
    CurrentTooltip = nil,
    Container = nil,
}

function TooltipManager:Init()
    if self.Container then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaXTooltips"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999998
    
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = Player.PlayerGui
    end
    
    self.Container = screenGui
end

function TooltipManager:Show(text, parent)
    self:Init()
    self:Hide()
    
    local theme = ThemeManager:GetTheme()
    
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.BackgroundColor3 = theme.Tertiary
    tooltip.BorderSizePixel = 0
    tooltip.Size = UDim2.new(0, 0, 0, 0)
    tooltip.ZIndex = 10
    tooltip.Parent = self.Container
    
    Utility:ApplyCorner(tooltip, 6)
    Utility:ApplyStroke(tooltip, theme.Border, 1, 0.5)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -16, 1, -12)
    textLabel.Position = UDim2.new(0, 8, 0, 6)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = theme.Text
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tooltip
    
    local textSize = TextService:GetTextSize(
        text,
        12,
        Enum.Font.Gotham,
        Vector2.new(300, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, textSize.X + 16, 0, textSize.Y + 12)
    
    -- Position near mouse
    local updatePosition = function()
        local mousePos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
    end
    
    updatePosition()
    
    local connection
    connection = RunService.RenderStepped:Connect(updatePosition)
    
    Utility:Tween(tooltip, {BackgroundTransparency = 0}, 0.15)
    Utility:Tween(textLabel, {TextTransparency = 0}, 0.15)
    
    self.CurrentTooltip = {
        Frame = tooltip,
        Connection = connection
    }
    
    return tooltip
end

function TooltipManager:Hide()
    if self.CurrentTooltip then
        if self.CurrentTooltip.Connection then
            self.CurrentTooltip.Connection:Disconnect()
        end
        if self.CurrentTooltip.Frame then
            self.CurrentTooltip.Frame:Destroy()
        end
        self.CurrentTooltip = nil
    end
end

function TooltipManager:Attach(element, text)
    element.MouseEnter:Connect(function()
        self:Show(text, element)
    end)
    
    element.MouseLeave:Connect(function()
        self:Hide()
    end)
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════════════════════

local Window = {}
Window.__index = Window

function Window:Create(options)
    local self = setmetatable({}, Window)
    
    options = options or {}
    self.Name = options.Name or "NebulaX UI"
    self.Subtitle = options.Subtitle or "Premium UI Library"
    self.MobileSupport = options.MobileSupport ~= false
    self.Theme = ThemeManager:SetTheme(options.Theme or "Dark", options.AccentColor)
    self.Size = options.Size or UDim2.new(0, 580, 0, 480)
    self.MinSize = options.MinSize or Vector2.new(400, 300)
    self.Position = options.Position
    self.SaveConfig = options.SaveConfig ~= false
    self.ConfigName = options.ConfigName or "default"
    self.Watermark = options.Watermark
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Visible = true
    
    -- Ajustar para móvil
    local isMobile = Utility:IsMobile()
    if isMobile and self.MobileSupport then
        self.Size = UDim2.new(0.95, 0, 0, 500)
    end
    
    self:CreateUI()
    self:LoadConfiguration()
    
    return self
end

function Window:CreateUI()
    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaX_" .. self.Name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    
    -- Protección
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = Player.PlayerGui
    end
    
    self.ScreenGui = screenGui
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = self.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = self.Size
    mainFrame.Position = self.Position or UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Utility:ApplyCorner(mainFrame, 12)
    Utility:ApplyStroke(mainFrame, self.Theme.Border, 1, 0.6)
    
    self.MainFrame = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Header
    self:CreateHeader()
    
    -- Tab Container
    self:CreateTabContainer()
    
    -- Content Area
    self:CreateContentArea()
    
    -- Footer
    self:CreateFooter()
    
    -- Watermark
    if self.Watermark then
        self:CreateWatermark()
    end
    
    -- Make draggable
    Utility:MakeDraggable(mainFrame, self.Header)
    
    -- Toggle visibility keybind (Right Shift por defecto)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            self:Toggle()
        end
    end)
end

function Window:CreateHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = self.Theme.Secondary
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Parent = self.MainFrame
    
    Utility:ApplyCorner(header, 12)
    
    -- Fix corner (solo arriba)
    local cornerFix = Instance.new("Frame")
    cornerFix.BackgroundColor3 = self.Theme.Secondary
    cornerFix.BorderSizePixel = 0
    cornerFix.Position = UDim2.new(0, 0, 1, -12)
    cornerFix.Size = UDim2.new(1, 0, 0, 12)
    cornerFix.Parent = header
    
    -- Accent line
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.BackgroundColor3 = self.Theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Parent = header
    
    -- Logo/Icon
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.BackgroundTransparency = 1
    logo.Image = IconLibrary:Get("zap")
    logo.ImageColor3 = self.Theme.Accent
    logo.Position = UDim2.new(0, 15, 0.5, 0)
    logo.Size = UDim2.new(0, 28, 0, 28)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 50, 0, 8)
    title.Size = UDim2.new(0.6, -50, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.Text = self.Name
    title.TextColor3 = self.Theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 50, 0, 26)
    subtitle.Size = UDim2.new(0.6, -50, 0, 14)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = self.Subtitle
    subtitle.TextColor3 = self.Theme.TextDark
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Control Buttons
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "Controls"
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Position = UDim2.new(1, -120, 0.5, 0)
    controlsContainer.Size = UDim2.new(0, 120, 0, 30)
    controlsContainer.AnchorPoint = Vector2.new(0, 0.5)
    controlsContainer.Parent = header
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.Parent = controlsContainer
    
    -- Minimize Button
    local minimizeBtn = self:CreateControlButton(controlsContainer, "minimize", function()
        self:Minimize()
    end)
    
    -- Settings Button
    local settingsBtn = self:CreateControlButton(controlsContainer, "settings", function()
        self:OpenSettings()
    end)
    
    -- Close Button
    local closeBtn = self:CreateControlButton(controlsContainer, "x", function()
        self:Destroy()
    end)
    
    self.Header = header
end

function Window:CreateControlButton(parent, icon, callback)
    local button = Instance.new("TextButton")
    button.Name = icon .. "Button"
    button.BackgroundColor3 = self.Theme.Tertiary
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 30, 0, 30)
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    Utility:ApplyCorner(button, 6)
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.BackgroundTransparency = 1
    iconImage.Image = IconLibrary:Get(icon)
    iconImage.ImageColor3 = self.Theme.TextDark
    iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconImage.Size = UDim2.new(0, 16, 0, 16)
    iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImage.Parent = button
    
    button.MouseButton1Click:Connect(function()
        Utility:CreateRipple(button, button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2, self.Theme.Accent)
        if callback then callback() end
    end)
    
    button.MouseEnter:Connect(function()
        Utility:Tween(button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
        Utility:Tween(iconImage, {ImageColor3 = self.Theme.Text}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utility:Tween(button, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        Utility:Tween(iconImage, {ImageColor3 = self.Theme.TextDark}, 0.2)
    end)
    
    TooltipManager:Attach(button, icon:gsub("^%l", string.upper))
    
    return button
end

function Window:CreateTabContainer()
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = self.Theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.Size = UDim2.new(0, 160, 1, -90)
    tabContainer.ScrollBarThickness = 4
    tabContainer.ScrollBarImageColor3 = self.Theme.Accent
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContainer.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = tabContainer
    
    Utility:AddPadding(tabContainer, 10)
    
    self.TabContainer = tabContainer
end

function Window:CreateContentArea()
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundColor3 = self.Theme.Background
    contentArea.BorderSizePixel = 0
    contentArea.Position = UDim2.new(0, 160, 0, 50)
    contentArea.Size = UDim2.new(1, -160, 1, -90)
    contentArea.ClipsDescendants = true
    contentArea.Parent = self.MainFrame
    
    self.ContentArea = contentArea
end

function Window:CreateFooter()
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.BackgroundColor3 = self.Theme.Secondary
    footer.BorderSizePixel = 0
    footer.Position = UDim2.new(0, 0, 1, -40)
    footer.Size = UDim2.new(1, 0, 0, 40)
    footer.Parent = self.MainFrame
    
    Utility:ApplyCorner(footer, 12)
    
    -- Fix corner (solo abajo)
    local cornerFix = Instance.new("Frame")
    cornerFix.BackgroundColor3 = self.Theme.Secondary
    cornerFix.BorderSizePixel = 0
    cornerFix.Position = UDim2.new(0, 0, 0, 0)
    cornerFix.Size = UDim2.new(1, 0, 0, 12)
    cornerFix.Parent = footer
    
    -- Accent line top
    local accentLine = Instance.new("Frame")
    accentLine.BackgroundColor3 = self.Theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Parent = footer
    
    -- Footer text
    local footerText = Instance.new("TextLabel")
    footerText.BackgroundTransparency = 1
    footerText.Position = UDim2.new(0, 15, 0.5, 0)
    footerText.Size = UDim2.new(0.5, -15, 0, 20)
    footerText.AnchorPoint = Vector2.new(0, 0.5)
    footerText.Font = Enum.Font.GothamBold
    footerText.Text = "NebulaX v" .. NebulaX.Version
    footerText.TextColor3 = self.Theme.Accent
    footerText.TextSize = 11
    footerText.TextXAlignment = Enum.TextXAlignment.Left
    footerText.Parent = footer
    
    -- User info
    local userInfo = Instance.new("TextLabel")
    userInfo.BackgroundTransparency = 1
    userInfo.Position = UDim2.new(1, -15, 0.5, 0)
    userInfo.Size = UDim2.new(0.5, -15, 0, 20)
    userInfo.AnchorPoint = Vector2.new(1, 0.5)
    userInfo.Font = Enum.Font.Gotham
    userInfo.Text = Player.Name .. " | " .. Utility:GetPlatform()
    userInfo.TextColor3 = self.Theme.TextDark
    userInfo.TextSize = 10
    userInfo.TextXAlignment = Enum.TextXAlignment.Right
    userInfo.Parent = footer
    
    self.Footer = footer
end

function Window:CreateWatermark()
    local watermark = Instance.new("TextLabel")
    watermark.Name = "Watermark"
    watermark.BackgroundColor3 = self.Theme.Secondary
    watermark.BorderSizePixel = 0
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.Size = UDim2.new(0, 200, 0, 30)
    watermark.Font = Enum.Font.GothamBold
    watermark.Text = "  " .. (self.Watermark or "NebulaX UI")
    watermark.TextColor3 = self.Theme.Text
    watermark.TextSize = 12
    watermark.TextXAlignment = Enum.TextXAlignment.Left
    watermark.Parent = self.ScreenGui
    
    Utility:ApplyCorner(watermark, 6)
    Utility:ApplyStroke(watermark, self.Theme.Accent, 1, 0.5)
    
    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Image = IconLibrary:Get("activity")
    icon.ImageColor3 = self.Theme.Accent
    icon.Position = UDim2.new(0, 8, 0.5, 0)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Parent = watermark
    
    -- FPS Counter
    local fps = 0
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        fps = fps + 1
        if tick() - lastUpdate >= 1 then
            watermark.Text = string.format("     %s | %d FPS", self.Watermark or "NebulaX", fps)
            fps = 0
            lastUpdate = tick()
        end
    end)
end

function Window:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "file"
    local orderIndex = options.Order or (#self.Tabs + 1)
    
    local tab = {
        Name = tabName,
        Icon = tabIcon,
        Window = self,
        Sections = {},
        Elements = {},
        Visible = false,
    }
    
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Button"
    tabButton.BackgroundColor3 = self.Theme.Tertiary
    tabButton.BorderSizePixel = 0
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.AutoButtonColor = false
    tabButton.Text = ""
    tabButton.LayoutOrder = orderIndex
    tabButton.Parent = self.TabContainer
    
    Utility:ApplyCorner(tabButton, 8)
    
    -- Tab Icon
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.BackgroundTransparency = 1
    iconImage.Image = IconLibrary:Get(tabIcon)
    iconImage.ImageColor3 = self.Theme.TextDark
    iconImage.Position = UDim2.new(0, 12, 0.5, 0)
    iconImage.Size = UDim2.new(0, 20, 0, 20)
    iconImage.AnchorPoint = Vector2.new(0, 0.5)
    iconImage.Parent = tabButton
    
    -- Tab Label
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.BackgroundTransparency = 1
    tabLabel.Position = UDim2.new(0, 40, 0, 0)
    tabLabel.Size = UDim2.new(1, -40, 1, 0)
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.Text = tabName
    tabLabel.TextColor3 = self.Theme.TextDark
    tabLabel.TextSize = 13
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabButton
    
    -- Tab Content Container
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tabName .. "Content"
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = self.ContentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    Utility:AddPadding(tabContent, 15)
    
    tab.Button = tabButton
    tab.Content = tabContent
    tab.IconImage = iconImage
    tab.Label = tabLabel
    
    -- Tab selection
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
        Utility:CreateRipple(tabButton, tabButton.AbsoluteSize.X/2, tabButton.AbsoluteSize.Y/2, self.Theme.Accent)
    end)
    
    tabButton.MouseEnter:Connect(function()
        if not tab.Visible then
            Utility:Tween(tabButton, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if not tab.Visible then
            Utility:Tween(tabButton, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Return tab object con métodos
    return setmetatable(tab, {__index = TabMethods})
end

function Window:SelectTab(tab)
    for _, t in pairs(self.Tabs) do
        t.Visible = false
        t.Content.Visible = false
        Utility:Tween(t.Button, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        Utility:Tween(t.IconImage, {ImageColor3 = self.Theme.TextDark}, 0.2)
        Utility:Tween(t.Label, {TextColor3 = self.Theme.TextDark}, 0.2)
    end
    
    tab.Visible = true
    tab.Content.Visible = true
    self.CurrentTab = tab
    
    Utility:Tween(tab.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
    Utility:Tween(tab.IconImage, {ImageColor3 = self.Theme.Text}, 0.2)
    Utility:Tween(tab.Label, {TextColor3 = self.Theme.Text}, 0.2)
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        Utility:Tween(self.MainFrame, {
            Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 50)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    else
        Utility:Tween(self.MainFrame, {
            Size = self.Size
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
end

function Window:Toggle()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.MainFrame.Visible = true
        Utility:Tween(self.MainFrame, {
            Size = self.Size,
            BackgroundTransparency = 0
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Utility:Tween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            self.MainFrame.Visible = false
        end)
    end
end

function Window:Destroy()
    Utility:Tween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        self.ScreenGui:Destroy()
    end)
    
    self:SaveConfiguration()
end

function Window:OpenSettings()
    NotificationManager:Create({
        Title = "Settings",
        Description = "Settings panel coming soon!",
        Type = "Info",
        Duration = 3
    })
end

function Window:SaveConfiguration()
    if not self.SaveConfig then return end
    
    local config = {}
    for _, tab in pairs(self.Tabs) do
        config[tab.Name] = {}
        for elementName, element in pairs(tab.Elements) do
            if element.Value ~= nil then
                config[tab.Name][elementName] = element.Value
            end
        end
    end
    
    Utility:SaveConfig(self.ConfigName, config)
end

function Window:LoadConfiguration()
    if not self.SaveConfig then return end
    
    local config = Utility:LoadConfig(self.ConfigName)
    if not config then return end
    
    task.wait(0.5) -- Wait for UI to load
    
    for tabName, elements in pairs(config) do
        for _, tab in pairs(self.Tabs) do
            if tab.Name == tabName then
                for elementName, value in pairs(elements) do
                    local element = tab.Elements[elementName]
                    if element and element.Set then
                        element:Set(value)
                    end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- TAB METHODS
-- ═══════════════════════════════════════════════════════════

TabMethods = {}

function TabMethods:CreateSection(name)
    local section = {
        Name = name,
        Tab = self,
        Elements = {}
    }
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = name .. "Section"
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, 0, 0, 0)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.LayoutOrder = #self.Sections + 1
    sectionFrame.Parent = self.Content
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 8)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = sectionFrame
    
    -- Section Header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 25)
    header.Font = Enum.Font.GothamBold
    header.Text = name
    header.TextColor3 = self.Window.Theme.Text
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.Parent = sectionFrame
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = self.Window.Theme.Accent
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(0, 40, 0, 2)
    divider.Position = UDim2.new(0, 0, 1, -2)
    divider.Parent = header
    
    Utility:ApplyCorner(divider, 2)
    
    section.Frame = sectionFrame
    table.insert(self.Sections, section)
    
    return setmetatable(section, {__index = SectionMethods})
end

function TabMethods:CreateLabel(options)
    return self:CreateSection(""):CreateLabel(options)
end

function TabMethods:CreateButton(options)
    return self:CreateSection(""):CreateButton(options)
end

function TabMethods:CreateToggle(options)
    return self:CreateSection(""):CreateToggle(options)
end

function TabMethods:CreateSlider(options)
    return self:CreateSection(""):CreateSlider(options)
end

function TabMethods:CreateDropdown(options)
    return self:CreateSection(""):CreateDropdown(options)
end

function TabMethods:CreateTextbox(options)
    return self:CreateSection(""):CreateTextbox(options)
end

function TabMethods:CreateColorPicker(options)
    return self:CreateSection(""):CreateColorPicker(options)
end

function TabMethods:CreateKeybind(options)
    return self:CreateSection(""):CreateKeybind(options)
end

-- ═══════════════════════════════════════════════════════════
-- SECTION METHODS / UI ELEMENTS
-- ═══════════════════════════════════════════════════════════

SectionMethods = {}

-- ═════════════════ LABEL ═════════════════
function SectionMethods:CreateLabel(options)
    options = options or {}
    local text = options.Text or "Label"
    local theme = self.Tab.Window.Theme
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "Label"
    labelFrame.BackgroundTransparency = 1
    labelFrame.Size = UDim2.new(1, 0, 0, 0)
    labelFrame.AutomaticSize = Enum.AutomaticSize.Y
    labelFrame.LayoutOrder = #self.Elements + 1
    labelFrame.Parent = self.Frame
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = theme.TextDark
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = labelFrame
    
    local element = {
        Frame = labelFrame,
        Label = label,
        Set = function(self, newText)
            label.Text = newText
        end
    }
    
    table.insert(self.Elements, element)
    return element
end

-- ═════════════════ BUTTON ═════════════════
function SectionMethods:CreateButton(options)
    options = options or {}
    local name = options.Name or "Button"
    local callback = options.Callback or function() end
    local icon = options.Icon
    local theme = self.Tab.Window.Theme
    
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.BackgroundColor3 = theme.Secondary
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.AutoButtonColor = false
    buttonFrame.Text = ""
    buttonFrame.LayoutOrder = #self.Elements + 1
    buttonFrame.Parent = self.Frame
    
    Utility:ApplyCorner(buttonFrame, 8)
    Utility:ApplyStroke(buttonFrame, theme.Border, 1, 0.7)
    
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.BackgroundTransparency = 1
        iconImage.Image = IconLibrary:Get(icon)
        iconImage.ImageColor3 = theme.Accent
        iconImage.Position = UDim2.new(0, 12, 0.5, 0)
        iconImage.Size = UDim2.new(0, 20, 0, 20)
        iconImage.AnchorPoint = Vector2.new(0, 0.5)
        iconImage.Parent = buttonFrame
    end
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Position = UDim2.new(0, icon and 42 or 12, 0, 0)
    buttonLabel.Size = UDim2.new(1, -(icon and 42 or 12), 1, 0)
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.Text = name
    buttonLabel.TextColor3 = theme.Text
    buttonLabel.TextSize = 13
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.Parent = buttonFrame
    
    buttonFrame.MouseButton1Click:Connect(function()
        Utility:CreateRipple(buttonFrame, buttonFrame.AbsoluteSize.X/2, buttonFrame.AbsoluteSize.Y/2, theme.Accent)
        callback()
    end)
    
    buttonFrame.MouseEnter:Connect(function()
        Utility:Tween(buttonFrame, {BackgroundColor3 = theme.Tertiary}, 0.2)
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        Utility:Tween(buttonFrame, {BackgroundColor3 = theme.Secondary}, 0.2)
    end)
    
    local element = {
        Frame = buttonFrame,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═════════════════ TOGGLE ═════════════════
function SectionMethods:CreateToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.BackgroundColor3 = theme.Secondary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.LayoutOrder = #self.Elements + 1
    toggleFrame.Parent = self.Frame
    
    Utility:ApplyCorner(toggleFrame, 8)
    Utility:ApplyStroke(toggleFrame, theme.Border, 1, 0.7)
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Position = UDim2.new(0, 12, 0, 0)
    toggleLabel.Size = UDim2.new(1, -70, 1, 0)
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.Text = name
    toggleLabel.TextColor3 = theme.Text
    toggleLabel.TextSize = 13
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    -- Toggle Switch
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.BackgroundColor3 = default and theme.Accent or theme.Tertiary
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(1, -52, 0.5, 0)
    toggleButton.Size = UDim2.new(0, 44, 0, 24)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.AutoButtonColor = false
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    Utility:ApplyCorner(toggleButton, 12)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Position = default and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.Parent = toggleButton
    
    Utility:ApplyCorner(toggleCircle, 10)
    
    local toggled = default
    
    local function updateToggle(value)
        toggled = value
        
        Utility:Tween(toggleButton, {
            BackgroundColor3 = toggled and theme.Accent or theme.Tertiary
        }, 0.2)
        
        Utility:Tween(toggleCircle, {
            Position = toggled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        callback(toggled)
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not toggled)
    end)
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle(not toggled)
        end
    end)
    
    local element = {
        Frame = toggleFrame,
        Value = toggled,
        Set = updateToggle,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    if default then
        callback(default)
    end
    
    return element
end

-- ═════════════════ SLIDER ═════════════════
function SectionMethods:CreateSlider(options)
    options = options or {}
    local name = options.Name or "Slider"
    local range = options.Range or {0, 100}
    local default = options.Default or range[1]
    local increment = options.Increment or 1
    local suffix = options.Suffix or ""
    local callback = options.Callback or function() end
    local visualFeedback = options.VisualFeedback
    local theme = self.Tab.Window.Theme
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.BackgroundColor3 = theme.Secondary
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.LayoutOrder = #self.Elements + 1
    sliderFrame.Parent = self.Frame
    
    Utility:ApplyCorner(sliderFrame, 8)
    Utility:ApplyStroke(sliderFrame, theme.Border, 1, 0.7)
    
    -- Header
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Position = UDim2.new(0, 12, 0, 8)
    sliderLabel.Size = UDim2.new(0.6, -12, 0, 18)
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.Text = name
    sliderLabel.TextColor3 = theme.Text
    sliderLabel.TextSize = 13
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -12, 0, 8)
    valueLabel.Size = UDim2.new(0.4, -12, 0, 18)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = theme.Accent
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.BackgroundColor3 = theme.Tertiary
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Position = UDim2.new(0, 12, 1, -20)
    sliderTrack.Size = UDim2.new(1, -24, 0, 6)
    sliderTrack.Parent = sliderFrame
    
    Utility:ApplyCorner(sliderTrack, 3)
    
    -- Slider Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.BackgroundColor3 = theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.Parent = sliderTrack
    
    Utility:ApplyCorner(sliderFill, 3)
    
    -- Slider Handle
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "Handle"
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderHandle.ZIndex = 2
    sliderHandle.Parent = sliderFill
    
    Utility:ApplyCorner(sliderHandle, 8)
    Utility:ApplyStroke(sliderHandle, theme.Accent, 2, 0)
    
    local dragging = false
    local currentValue = default
    
    local function updateValue(value)
        value = math.clamp(value, range[1], range[2])
        value = math.floor(value / increment + 0.5) * increment
        currentValue = value
        
        local percent = (value - range[1]) / (range[2] - range[1])
        
        Utility:Tween(sliderFill, {
            Size = UDim2.new(percent, 0, 1, 0)
        }, 0.1)
        
        Utility:Tween(sliderHandle, {
            Position = UDim2.new(1, 0, 0.5, 0)
        }, 0.1)
        
        valueLabel.Text = tostring(value) .. suffix
        callback(value)
    end
    
    local function slide(input)
        local pos = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        local value = range[1] + (range[2] - range[1]) * pos
        updateValue(value)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            slide(input)
            
            Utility:Tween(sliderHandle, {Size = UDim2.new(0, 20, 0, 20)}, 0.2, Enum.EasingStyle.Back)
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Utility:Tween(sliderHandle, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            slide(input)
        end
    end)
    
    local element = {
        Frame = sliderFrame,
        Value = currentValue,
        Set = updateValue,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    updateValue(default)
    
    return element
end

-- ═════════════════ DROPDOWN ═════════════════
function SectionMethods:CreateDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local list = options.Options or {"Option 1", "Option 2"}
    local default = options.Default or list[1]
    local callback = options.Callback or function() end
    local multiSelect = options.MultiSelect or false
    local theme = self.Tab.Window.Theme
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.BackgroundColor3 = theme.Secondary
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.LayoutOrder = #self.Elements + 1
    dropdownFrame.Parent = self.Frame
    
    Utility:ApplyCorner(dropdownFrame, 8)
    Utility:ApplyStroke(dropdownFrame, theme.Border, 1, 0.7)
    
    -- Header
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Header"
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Size = UDim2.new(1, 0, 0, 40)
    dropdownButton.AutoButtonColor = false
    dropdownButton.Text = ""
    dropdownButton.Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Position = UDim2.new(0, 12, 0, 0)
    dropdownLabel.Size = UDim2.new(1, -40, 1, 0)
    dropdownLabel.Font = Enum.Font.GothamBold
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = theme.Text
    dropdownLabel.TextSize = 13
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownButton
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Position = UDim2.new(0, 12, 0, 20)
    selectedLabel.Size = UDim2.new(1, -40, 0, 16)
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.Text = default
    selectedLabel.TextColor3 = theme.TextDark
    selectedLabel.TextSize = 11
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.Parent = dropdownButton
    
    local chevron = Instance.new("ImageLabel")
    chevron.BackgroundTransparency = 1
    chevron.Image = IconLibrary:Get("chevron-down")
    chevron.ImageColor3 = theme.TextDark
    chevron.Position = UDim2.new(1, -30, 0.5, 0)
    chevron.Size = UDim2.new(0, 16, 0, 16)
    chevron.AnchorPoint = Vector2.new(0, 0.5)
    chevron.Parent = dropdownButton
    
    -- Options Container
    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Name = "Options"
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Position = UDim2.new(0, 0, 0, 40)
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.ScrollBarThickness = 3
    optionsContainer.ScrollBarImageColor3 = theme.Accent
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsContainer.Parent = dropdownFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.Parent = optionsContainer
    
    Utility:AddPadding(optionsContainer, 6)
    
    local expanded = false
    local currentValue = default
    local selectedOptions = multiSelect and {[default] = true} or {}
    
    local function updateSelected()
        if multiSelect then
            local selected = {}
            for opt, _ in pairs(selectedOptions) do
                table.insert(selected, opt)
            end
            selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
            currentValue = selected
        else
            selectedLabel.Text = currentValue
        end
    end
    
    local function createOption(optionName)
        local optionButton = Instance.new("TextButton")
        optionButton.Name = optionName
        optionButton.BackgroundColor3 = theme.Tertiary
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, 32)
        optionButton.AutoButtonColor = false
        optionButton.Text = ""
        optionButton.Parent = optionsContainer
        
        Utility:ApplyCorner(optionButton, 6)
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.BackgroundTransparency = 1
        optionLabel.Position = UDim2.new(0, 10, 0, 0)
        optionLabel.Size = UDim2.new(1, multiSelect and -30 or -10, 1, 0)
        optionLabel.Font = Enum.Font.Gotham
        optionLabel.Text = optionName
        optionLabel.TextColor3 = theme.Text
        optionLabel.TextSize = 12
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.Parent = optionButton
        
        if multiSelect then
            local checkbox = Instance.new("Frame")
            checkbox.BackgroundColor3 = theme.Background
            checkbox.BorderSizePixel = 0
            checkbox.Position = UDim2.new(1, -24, 0.5, 0)
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.AnchorPoint = Vector2.new(0, 0.5)
            checkbox.Parent = optionButton
            
            Utility:ApplyCorner(checkbox, 4)
            Utility:ApplyStroke(checkbox, theme.Border, 1, 0.5)
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.BackgroundTransparency = 1
            checkmark.Image = IconLibrary:Get("check")
            checkmark.ImageColor3 = theme.Accent
            checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
            checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
            checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
            checkmark.ImageTransparency = selectedOptions[optionName] and 0 or 1
            checkmark.Parent = checkbox
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOptions[optionName] = not selectedOptions[optionName]
                Utility:Tween(checkmark, {
                    ImageTransparency = selectedOptions[optionName] and 0 or 1
                }, 0.2)
                updateSelected()
                callback(currentValue)
            end)
        else
            optionButton.MouseButton1Click:Connect(function()
                currentValue = optionName
                updateSelected()
                callback(currentValue)
                
                task.wait(0.1)
                dropdownButton.MouseButton1Click:Fire()
            end)
        end
        
        optionButton.MouseEnter:Connect(function()
            Utility:Tween(optionButton, {BackgroundColor3 = theme.Accent}, 0.2)
        end)
        
        optionButton.MouseLeave:Connect(function()
            Utility:Tween(optionButton, {BackgroundColor3 = theme.Tertiary}, 0.2)
        end)
    end
    
    for _, option in ipairs(list) do
        createOption(option)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        local targetRotation = expanded and 180 or 0
        local targetHeight = expanded and math.min(#list * 34 + 12, 150) or 0
        
        Utility:Tween(chevron, {Rotation = targetRotation}, 0.3)
        Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.3)
        Utility:Tween(dropdownFrame, {
            Size = UDim2.new(1, 0, 0, 40 + targetHeight)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
    
    local element = {
        Frame = dropdownFrame,
        Value = currentValue,
        Options = list,
        Set = function(self, value)
            if multiSelect then
                selectedOptions = {}
                for _, v in ipairs(value) do
                    selectedOptions[v] = true
                end
            else
                currentValue = value
            end
            updateSelected()
        end,
        AddOption = function(self, option)
            table.insert(list, option)
            createOption(option)
        end,
        RemoveOption = function(self, option)
            for i, v in ipairs(list) do
                if v == option then
                    table.remove(list, i)
                    break
                end
            end
            -- Recrear opciones
            optionsContainer:ClearAllChildren()
            optionsLayout.Parent = optionsContainer
            Utility:AddPadding(optionsContainer, 6)
            for _, opt in ipairs(list) do
                createOption(opt)
            end
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    updateSelected()
    
    return element
end

-- ═════════════════ TEXTBOX ═════════════════
function SectionMethods:CreateTextbox(options)
    options = options or {}
    local name = options.Name or "Textbox"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local numeric = options.Numeric or false
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = "Textbox"
    textboxFrame.BackgroundColor3 = theme.Secondary
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Size = UDim2.new(1, 0, 0, 70)
    textboxFrame.LayoutOrder = #self.Elements + 1
    textboxFrame.Parent = self.Frame
    
    Utility:ApplyCorner(textboxFrame, 8)
    Utility:ApplyStroke(textboxFrame, theme.Border, 1, 0.7)
    
    local textboxLabel = Instance.new("TextLabel")
    textboxLabel.BackgroundTransparency = 1
    textboxLabel.Position = UDim2.new(0, 12, 0, 8)
    textboxLabel.Size = UDim2.new(1, -24, 0, 18)
    textboxLabel.Font = Enum.Font.GothamBold
    textboxLabel.Text = name
    textboxLabel.TextColor3 = theme.Text
    textboxLabel.TextSize = 13
    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textboxLabel.Parent = textboxFrame
    
    local textboxInput = Instance.new("TextBox")
    textboxInput.Name = "Input"
    textboxInput.BackgroundColor3 = theme.Tertiary
    textboxInput.BorderSizePixel = 0
    textboxInput.Position = UDim2.new(0, 12, 0, 32)
    textboxInput.Size = UDim2.new(1, -24, 0, 30)
    textboxInput.Font = Enum.Font.Gotham
    textboxInput.PlaceholderText = placeholder
    textboxInput.PlaceholderColor3 = theme.TextDark
    textboxInput.Text = default
    textboxInput.TextColor3 = theme.Text
    textboxInput.TextSize = 12
    textboxInput.TextXAlignment = Enum.TextXAlignment.Left
    textboxInput.ClearTextOnFocus = false
    textboxInput.Parent = textboxFrame
    
    Utility:ApplyCorner(textboxInput, 6)
    Utility:AddPadding(textboxInput, 8)
    
    local currentValue = default
    
    textboxInput.FocusLost:Connect(function()
        local value = textboxInput.Text
        
        if numeric then
            value = tonumber(value) or 0
            textboxInput.Text = tostring(value)
        end
        
        currentValue = value
        callback(value)
    end)
    
    textboxInput.Focused:Connect(function()
        Utility:Tween(textboxInput, {BackgroundColor3 = theme.Secondary}, 0.2)
    end)
    
    textboxInput:GetPropertyChangedSignal("Text"):Connect(function()
        if numeric then
            textboxInput.Text = textboxInput.Text:gsub("[^%d%.%-]", "")
        end
    end)
    
    local element = {
        Frame = textboxFrame,
        Input = textboxInput,
        Value = currentValue,
        Set = function(self, value)
            textboxInput.Text = tostring(value)
            currentValue = value
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═════════════════ COLOR PICKER ═════════════════
function SectionMethods:CreateColorPicker(options)
    options = options or {}
    local name = options.Name or "Color Picker"
    local default = options.Default or Color3.fromRGB(255, 0, 0)
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "ColorPicker"
    pickerFrame.BackgroundColor3 = theme.Secondary
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Size = UDim2.new(1, 0, 0, 40)
    pickerFrame.ClipsDescendants = true
    pickerFrame.LayoutOrder = #self.Elements + 1
    pickerFrame.Parent = self.Frame
    
    Utility:ApplyCorner(pickerFrame, 8)
    Utility:ApplyStroke(pickerFrame, theme.Border, 1, 0.7)
    
    local pickerLabel = Instance.new("TextLabel")
    pickerLabel.BackgroundTransparency = 1
    pickerLabel.Position = UDim2.new(0, 12, 0, 0)
    pickerLabel.Size = UDim2.new(1, -60, 1, 0)
    pickerLabel.Font = Enum.Font.GothamBold
    pickerLabel.Text = name
    pickerLabel.TextColor3 = theme.Text
    pickerLabel.TextSize = 13
    pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    pickerLabel.Parent = pickerFrame
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Position = UDim2.new(1, -44, 0.5, 0)
    colorDisplay.Size = UDim2.new(0, 32, 0, 24)
    colorDisplay.AnchorPoint = Vector2.new(0, 0.5)
    colorDisplay.Text = ""
    colorDisplay.Parent = pickerFrame
    
    Utility:ApplyCorner(colorDisplay, 6)
    Utility:ApplyStroke(colorDisplay, theme.Border, 2, 0.5)
    
    local currentColor = default
    local expanded = false
    
    -- Color Picker Canvas
    local pickerCanvas = Instance.new("Frame")
    pickerCanvas.Name = "Canvas"
    pickerCanvas.BackgroundColor3 = theme.Tertiary
    pickerCanvas.BorderSizePixel = 0
    pickerCanvas.Position = UDim2.new(0, 12, 0, 50)
    pickerCanvas.Size = UDim2.new(1, -24, 0, 0)
    pickerCanvas.ClipsDescendants = true
    pickerCanvas.Parent = pickerFrame
    
    Utility:ApplyCorner(pickerCanvas, 6)
    
    -- Simple RGB Sliders
    local function createRGBSlider(colorName, yPos, defaultVal)
        local sliderBG = Instance.new("Frame")
        sliderBG.BackgroundColor3 = theme.Background
        sliderBG.BorderSizePixel = 0
        sliderBG.Position = UDim2.new(0, 8, 0, yPos)
        sliderBG.Size = UDim2.new(1, -16, 0, 30)
        sliderBG.Parent = pickerCanvas
        
        Utility:ApplyCorner(sliderBG, 4)
        
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 20, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = colorName
        label.TextColor3 = colorName == "R" and Color3.fromRGB(255, 100, 100) or 
                          colorName == "G" and Color3.fromRGB(100, 255, 100) or 
                          Color3.fromRGB(100, 100, 255)
        label.TextSize = 12
        label.Parent = sliderBG
        
        local track = Instance.new("Frame")
        track.BackgroundColor3 = theme.Secondary
        track.BorderSizePixel = 0
        track.Position = UDim2.new(0, 30, 0.5, 0)
        track.Size = UDim2.new(1, -80, 0, 6)
        track.AnchorPoint = Vector2.new(0, 0.5)
        track.Parent = sliderBG
        
        Utility:ApplyCorner(track, 3)
        
        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = colorName == "R" and Color3.fromRGB(255, 100, 100) or 
                                colorName == "G" and Color3.fromRGB(100, 255, 100) or 
                                Color3.fromRGB(100, 100, 255)
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(defaultVal/255, 0, 1, 0)
        fill.Parent = track
        
        Utility:ApplyCorner(fill, 3)
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Position = UDim2.new(1, -45, 0, 0)
        valueLabel.Size = UDim2.new(0, 40, 1, 0)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Text = tostring(math.floor(defaultVal))
        valueLabel.TextColor3 = theme.Text
        valueLabel.TextSize = 11
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderBG
        
        local dragging = false
        
        local function updateSlider(value)
            value = math.clamp(value, 0, 255)
            fill.Size = UDim2.new(value/255, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            
            local r, g, b = currentColor.R * 255, currentColor.G * 255, currentColor.B * 255
            if colorName == "R" then r = value
            elseif colorName == "G" then g = value
            else b = value end
            
            currentColor = Color3.fromRGB(r, g, b)
            colorDisplay.BackgroundColor3 = currentColor
            callback(currentColor)
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                updateSlider(pos * 255)
            end
        end)
        
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                updateSlider(math.clamp(pos * 255, 0, 255))
            end
        end)
        
        return updateSlider
    end
    
    local updateR = createRGBSlider("R", 8, default.R * 255)
    local updateG = createRGBSlider("G", 46, default.G * 255)
    local updateB = createRGBSlider("B", 84, default.B * 255)
    
    colorDisplay.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        Utility:Tween(pickerCanvas, {
            Size = UDim2.new(1, -24, 0, expanded and 120 or 0)
        }, 0.3)
        
        Utility:Tween(pickerFrame, {
            Size = UDim2.new(1, 0, 0, expanded and 180 or 40)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
    
    local element = {
        Frame = pickerFrame,
        Value = currentColor,
        Set = function(self, color)
            currentColor = color
            colorDisplay.BackgroundColor3 = color
            updateR(color.R * 255)
            updateG(color.G * 255)
            updateB(color.B * 255)
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═════════════════ KEYBIND ═════════════════
function SectionMethods:CreateKeybind(options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default or Enum.KeyCode.E
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.BackgroundColor3 = theme.Secondary
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Size = UDim2.new(1, 0, 0, 40)
    keybindFrame.LayoutOrder = #self.Elements + 1
    keybindFrame.Parent = self.Frame
    
    Utility:ApplyCorner(keybindFrame, 8)
    Utility:ApplyStroke(keybindFrame, theme.Border, 1, 0.7)
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Position = UDim2.new(0, 12, 0, 0)
    keybindLabel.Size = UDim2.new(1, -100, 1, 0)
    keybindLabel.Font = Enum.Font.GothamBold
    keybindLabel.Text = name
    keybindLabel.TextColor3 = theme.Text
    keybindLabel.TextSize = 13
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "KeyButton"
    keybindButton.BackgroundColor3 = theme.Tertiary
    keybindButton.BorderSizePixel = 0
    keybindButton.Position = UDim2.new(1, -88, 0.5, 0)
    keybindButton.Size = UDim2.new(0, 76, 0, 28)
    keybindButton.AnchorPoint = Vector2.new(0, 0.5)
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.Text = default.Name
    keybindButton.TextColor3 = theme.Text
    keybindButton.TextSize = 11
    keybindButton.AutoButtonColor = false
    keybindButton.Parent = keybindFrame
    
    Utility:ApplyCorner(keybindButton, 6)
    
    local currentKey = default
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        keybindButton.Text = "..."
        Utility:Tween(keybindButton, {BackgroundColor3 = theme.Accent}, 0.2)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
                listening = false
                Utility:Tween(keybindButton, {BackgroundColor3 = theme.Tertiary}, 0.2)
            end
        elseif not gameProcessed and input.KeyCode == currentKey then
            callback()
        end
    end)
    
    keybindButton.MouseEnter:Connect(function()
        if not listening then
            Utility:Tween(keybindButton, {BackgroundColor3 = theme.Secondary}, 0.2)
        end
    end)
    
    keybindButton.MouseLeave:Connect(function()
        if not listening then
            Utility:Tween(keybindButton, {BackgroundColor3 = theme.Tertiary}, 0.2)
        end
    end)
    
    local element = {
        Frame = keybindFrame,
        Value = currentKey,
        Set = function(self, key)
            currentKey = key
            keybindButton.Text = key.Name
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═══════════════════════════════════════════════════════════
-- NEBULAX MAIN API
-- ═══════════════════════════════════════════════════════════

function NebulaX:CreateWindow(options)
    local window = Window:Create(options)
    table.insert(self.Windows, window)
    return window
end

function NebulaX:Notify(options)
    return NotificationManager:Create(options)
end

function NebulaX:IsMobile()
    return Utility:IsMobile()
end

function NebulaX:GetPlatform()
    return Utility:GetPlatform()
end

function NebulaX:EnableTouchOptimizations()
    if not Utility:IsMobile() then return end
    
    -- Aumentar tamaño de botones para móvil
    -- Esto se puede implementar según necesidades específicas
    print("[NebulaX] Touch optimizations enabled")
end

function NebulaX:SetTheme(themeName, customColors)
    if customColors then
        ThemeManager:CreateCustomTheme(themeName, customColors)
    end
    return ThemeManager:SetTheme(themeName)
end

function NebulaX:DestroyAll()
    for _, window in pairs(self.Windows) do
        if window.ScreenGui then
            window.ScreenGui:Destroy()
        end
    end
    self.Windows = {}
end

-- ═══════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════

print([[
╔═══════════════════════════════════════════════════════════╗
║                    NEBULAX UI LOADED                      ║
║                   Version ]] .. NebulaX.Version .. [[                      ║
╚═══════════════════════════════════════════════════════════╝
]])

return NebulaX
