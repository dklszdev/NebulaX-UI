--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║              NEBULAX UI LIBRARY v2.0 AESTHETIC            ║
    ║                   Ultra Modern Edition                    ║
    ║          Optimized for Mobile & Desktop 2024              ║
    ╚═══════════════════════════════════════════════════════════╝
    
    ✨ Features:
    • Glassmorphism Design
    • Advanced Mobile Gestures
    • Stunning Visual Effects
    • Modern Color Palettes
    • Enhanced Sliders & Components
    • Smooth Animations
    • Blur Effects
    • Gradient Systems
    • Touch Optimized
--]]

local NebulaX = {
    Version = "2.0.0",
    Author = "NebulaX Development",
    Windows = {},
    Notifications = {},
    Config = {},
    IsMobileDevice = false,
}

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════════════════
-- ENHANCED UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local Utility = {}

function Utility:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility:IsTablet()
    local screenSize = workspace.CurrentCamera.ViewportSize
    return UserInputService.TouchEnabled and (screenSize.X > 768 or screenSize.Y > 768)
end

function Utility:GetPlatform()
    if UserInputService.GamepadEnabled then return "Console" end
    if self:IsMobile() then
        return self:IsTablet() and "Tablet" or "Mobile"
    end
    return "Desktop"
end

function Utility:GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
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

function Utility:Spring(instance, properties, callback)
    return self:Tween(instance, properties, 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, callback)
end

function Utility:CreateRipple(parent, x, y, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 10
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    
    Utility:Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, function()
        ripple:Destroy()
    end)
end

function Utility:CreateGlow(parent, color, intensity)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    glow.ImageTransparency = 1 - (intensity or 0.3)
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.ZIndex = 0
    glow.Parent = parent
    return glow
end

function Utility:CreateShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

function Utility:MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos
    local smoothDrag = false
    
    local isMobile = self:IsMobile()
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            smoothDrag = true
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    smoothDrag = false
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
            
            if smoothDrag and not isMobile then
                Utility:Tween(frame, {
                    Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                }, 0.15, Enum.EasingStyle.Sine)
            else
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

function Utility:ApplyCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
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

function Utility:AddPadding(instance, all, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    if all then
        padding.PaddingTop = UDim.new(0, all)
        padding.PaddingBottom = UDim.new(0, all)
        padding.PaddingLeft = UDim.new(0, all)
        padding.PaddingRight = UDim.new(0, all)
    else
        padding.PaddingTop = UDim.new(0, top or 10)
        padding.PaddingBottom = UDim.new(0, bottom or 10)
        padding.PaddingLeft = UDim.new(0, left or 10)
        padding.PaddingRight = UDim.new(0, right or 10)
    end
    padding.Parent = instance
    return padding
end

function Utility:CreateBlur(parent, size)
    local blur = Instance.new("BlurEffect")
    blur.Size = size or 10
    blur.Parent = parent
    return blur
end

function Utility:SaveConfig(name, data)
    pcall(function()
        if not isfolder("NebulaX") then
            makefolder("NebulaX")
        end
        writefile("NebulaX/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
end

function Utility:LoadConfig(name)
    local success, result = pcall(function()
        if isfile("NebulaX/" .. name .. ".json") then
            return HttpService:JSONDecode(readfile("NebulaX/" .. name .. ".json"))
        end
        return nil
    end)
    return success and result or nil
end

-- ═══════════════════════════════════════════════════════════
-- MODERN THEME SYSTEM
-- ═══════════════════════════════════════════════════════════

local ThemeManager = {
    CurrentTheme = "Aesthetic",
    Themes = {}
}

-- ✨ Aesthetic Modern Theme
ThemeManager.Themes.Aesthetic = {
    Name = "Aesthetic",
    -- Backgrounds with glassmorphism
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    },
    Secondary = Color3.fromRGB(25, 25, 35),
    Tertiary = Color3.fromRGB(30, 30, 42),
    
    -- Accent colors - Modern Purple/Blue
    Accent = Color3.fromRGB(138, 112, 255),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 112, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 156, 255))
    },
    
    -- Text
    Text = Color3.fromRGB(245, 245, 255),
    TextDark = Color3.fromRGB(150, 150, 170),
    TextMuted = Color3.fromRGB(100, 100, 120),
    
    -- Status colors
    Success = Color3.fromRGB(94, 234, 162),
    Warning = Color3.fromRGB(255, 195, 113),
    Error = Color3.fromRGB(255, 117, 127),
    Info = Color3.fromRGB(116, 185, 255),
    
    -- UI Elements
    Border = Color3.fromRGB(60, 60, 80),
    Hover = Color3.fromRGB(40, 40, 55),
    Active = Color3.fromRGB(138, 112, 255),
    
    -- Glass effect
    GlassTransparency = 0.3,
    BlurIntensity = 20,
}

-- 🌊 Ocean Breeze Theme
ThemeManager.Themes.Ocean = {
    Name = "Ocean",
    Background = Color3.fromRGB(12, 23, 38),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 23, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 25))
    },
    Secondary = Color3.fromRGB(20, 35, 55),
    Tertiary = Color3.fromRGB(28, 45, 68),
    
    Accent = Color3.fromRGB(64, 224, 208),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 224, 208)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 172, 254))
    },
    
    Text = Color3.fromRGB(240, 250, 255),
    TextDark = Color3.fromRGB(150, 200, 220),
    TextMuted = Color3.fromRGB(100, 150, 180),
    
    Success = Color3.fromRGB(104, 211, 145),
    Warning = Color3.fromRGB(255, 206, 86),
    Error = Color3.fromRGB(255, 99, 132),
    Info = Color3.fromRGB(79, 195, 247),
    
    Border = Color3.fromRGB(52, 152, 219),
    Hover = Color3.fromRGB(30, 50, 75),
    Active = Color3.fromRGB(64, 224, 208),
    
    GlassTransparency = 0.25,
    BlurIntensity = 18,
}

-- 🌸 Cherry Blossom Theme
ThemeManager.Themes.Cherry = {
    Name = "Cherry",
    Background = Color3.fromRGB(25, 15, 20),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 18, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 18))
    },
    Secondary = Color3.fromRGB(35, 25, 32),
    Tertiary = Color3.fromRGB(45, 32, 42),
    
    Accent = Color3.fromRGB(255, 128, 171),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 171)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 175, 189))
    },
    
    Text = Color3.fromRGB(255, 240, 245),
    TextDark = Color3.fromRGB(200, 170, 185),
    TextMuted = Color3.fromRGB(150, 120, 140),
    
    Success = Color3.fromRGB(129, 212, 250),
    Warning = Color3.fromRGB(255, 213, 79),
    Error = Color3.fromRGB(239, 83, 80),
    Info = Color3.fromRGB(186, 104, 200),
    
    Border = Color3.fromRGB(255, 128, 171),
    Hover = Color3.fromRGB(50, 35, 45),
    Active = Color3.fromRGB(255, 128, 171),
    
    GlassTransparency = 0.3,
    BlurIntensity = 22,
}

-- 🌆 Cyberpunk Theme
ThemeManager.Themes.Cyberpunk = {
    Name = "Cyberpunk",
    Background = Color3.fromRGB(10, 10, 15),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
    },
    Secondary = Color3.fromRGB(18, 18, 25),
    Tertiary = Color3.fromRGB(25, 25, 35),
    
    Accent = Color3.fromRGB(0, 255, 255),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    },
    
    Text = Color3.fromRGB(0, 255, 255),
    TextDark = Color3.fromRGB(100, 200, 255),
    TextMuted = Color3.fromRGB(80, 150, 200),
    
    Success = Color3.fromRGB(57, 255, 20),
    Warning = Color3.fromRGB(255, 234, 0),
    Error = Color3.fromRGB(255, 0, 110),
    Info = Color3.fromRGB(138, 43, 226),
    
    Border = Color3.fromRGB(0, 255, 255),
    Hover = Color3.fromRGB(30, 30, 45),
    Active = Color3.fromRGB(0, 255, 255),
    
    GlassTransparency = 0.2,
    BlurIntensity = 25,
}

-- 🌙 Midnight Theme
ThemeManager.Themes.Midnight = {
    Name = "Midnight",
    Background = Color3.fromRGB(8, 10, 20),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 15, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 7, 15))
    },
    Secondary = Color3.fromRGB(15, 18, 30),
    Tertiary = Color3.fromRGB(22, 26, 42),
    
    Accent = Color3.fromRGB(147, 112, 219),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 112, 219)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(106, 90, 205))
    },
    
    Text = Color3.fromRGB(230, 230, 250),
    TextDark = Color3.fromRGB(170, 170, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    
    Success = Color3.fromRGB(102, 187, 106),
    Warning = Color3.fromRGB(255, 183, 77),
    Error = Color3.fromRGB(239, 83, 80),
    Info = Color3.fromRGB(100, 181, 246),
    
    Border = Color3.fromRGB(80, 80, 120),
    Hover = Color3.fromRGB(25, 30, 48),
    Active = Color3.fromRGB(147, 112, 219),
    
    GlassTransparency = 0.28,
    BlurIntensity = 20,
}

-- 🌅 Sunset Theme
ThemeManager.Themes.Sunset = {
    Name = "Sunset",
    Background = Color3.fromRGB(30, 15, 15),
    BackgroundGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 10, 15))
    },
    Secondary = Color3.fromRGB(45, 25, 25),
    Tertiary = Color3.fromRGB(55, 32, 32),
    
    Accent = Color3.fromRGB(255, 107, 107),
    AccentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 107, 107)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 159, 64))
    },
    
    Text = Color3.fromRGB(255, 245, 240),
    TextDark = Color3.fromRGB(220, 180, 170),
    TextMuted = Color3.fromRGB(180, 140, 130),
    
    Success = Color3.fromRGB(129, 199, 132),
    Warning = Color3.fromRGB(255, 183, 77),
    Error = Color3.fromRGB(229, 115, 115),
    Info = Color3.fromRGB(100, 181, 246),
    
    Border = Color3.fromRGB(255, 120, 120),
    Hover = Color3.fromRGB(60, 35, 35),
    Active = Color3.fromRGB(255, 107, 107),
    
    GlassTransparency = 0.32,
    BlurIntensity = 18,
}

function ThemeManager:SetTheme(themeName, customAccent)
    local theme = self.Themes[themeName] or self.Themes.Aesthetic
    if customAccent then
        theme.Accent = customAccent
    end
    self.CurrentTheme = themeName
    return theme
end

function ThemeManager:GetTheme()
    return self.Themes[self.CurrentTheme] or self.Themes.Aesthetic
end

function ThemeManager:CreateCustomTheme(name, colors)
    self.Themes[name] = colors
end

-- ═══════════════════════════════════════════════════════════
-- ENHANCED ICON LIBRARY (Lucide Icons)
-- ═══════════════════════════════════════════════════════════

local IconLibrary = {
    -- Navigation & UI
    home = "rbxassetid://10734896629",
    menu = "rbxassetid://10747432175",
    settings = "rbxassetid://10734950309",
    search = "rbxassetid://10734898629",
    filter = "rbxassetid://10747318989",
    
    -- Actions
    plus = "rbxassetid://10734896206",
    minus = "rbxassetid://10734898532",
    check = "rbxassetid://10734896841",
    x = "rbxassetid://10747384394",
    edit = "rbxassetid://10734898086",
    trash = "rbxassetid://10734896966",
    save = "rbxassetid://10734896099",
    copy = "rbxassetid://10734896651",
    download = "rbxassetid://10734896975",
    upload = "rbxassetid://10734897508",
    refresh = "rbxassetid://10747373176",
    
    -- Arrows & Chevrons
    ["arrow-up"] = "rbxassetid://10734297964",
    ["arrow-down"] = "rbxassetid://10734296389",
    ["arrow-left"] = "rbxassetid://10734294993",
    ["arrow-right"] = "rbxassetid://10734296157",
    ["chevron-up"] = "rbxassetid://10734896975",
    ["chevron-down"] = "rbxassetid://10734896926",
    ["chevron-left"] = "rbxassetid://10734896853",
    ["chevron-right"] = "rbxassetid://10734896945",
    
    -- Status & Info
    info = "rbxassetid://10734896814",
    alert = "rbxassetid://10734896499",
    ["alert-circle"] = "rbxassetid://10734896206",
    ["check-circle"] = "rbxassetid://10734896841",
    ["x-circle"] = "rbxassetid://10734896644",
    ["help-circle"] = "rbxassetid://10747384394",
    
    -- Media & Files
    image = "rbxassetid://10734896863",
    file = "rbxassetid://10734896744",
    folder = "rbxassetid://10734896814",
    ["folder-open"] = "rbxassetid://10734896918",
    
    -- User & Social
    user = "rbxassetid://10747374131",
    users = "rbxassetid://10747374131",
    heart = "rbxassetid://10734896852",
    star = "rbxassetid://10734896220",
    bell = "rbxassetid://10734896771",
    mail = "rbxassetid://10734896863",
    
    -- Security
    lock = "rbxassetid://10734897799",
    unlock = "rbxassetid://10734898534",
    eye = "rbxassetid://10747318989",
    ["eye-off"] = "rbxassetid://10747318658",
    shield = "rbxassetid://10734950309",
    
    -- Gaming
    gamepad = "rbxassetid://10734896814",
    target = "rbxassetid://10734897508",
    crosshair = "rbxassetid://10734896651",
    zap = "rbxassetid://10747384394",
    activity = "rbxassetid://10734296389",
    
    -- Tech
    cpu = "rbxassetid://10734896651",
    database = "rbxassetid://10734896651",
    server = "rbxassetid://10734950309",
    wifi = "rbxassetid://10747384394",
    bluetooth = "rbxassetid://10734896206",
    
    -- Tools
    tool = "rbxassetid://10734896945",
    wrench = "rbxassetid://10747384394",
    sliders = "rbxassetid://10734950309",
    palette = "rbxassetid://10734896945",
    
    -- Layout
    grid = "rbxassetid://10734896852",
    list = "rbxassetid://10734897799",
    layout = "rbxassetid://10734896863",
    sidebar = "rbxassetid://10734897799",
    
    -- Other
    sun = "rbxassetid://10734896220",
    moon = "rbxassetid://10734897508",
    cloud = "rbxassetid://10734896651",
    flame = "rbxassetid://10747384394",
    droplet = "rbxassetid://10734896744",
    sparkles = "rbxassetid://10734896220",
}

function IconLibrary:Get(iconName)
    return self[iconName] or self.help
end

-- ═══════════════════════════════════════════════════════════
-- ENHANCED NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

local NotificationManager = {
    Container = nil,
    Queue = {},
    ActiveNotifications = 0,
    MaxNotifications = 5,
}

function NotificationManager:Init()
    if self.Container then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaXNotifications_v2"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999999
    
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = Player.PlayerGui
    end
    
    local isMobile = Utility:IsMobile()
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.BackgroundTransparency = 1
    container.Position = isMobile and UDim2.new(0.5, 0, 0, 10) or UDim2.new(1, -20, 0, 20)
    container.Size = isMobile and UDim2.new(0.9, 0, 0, 0) or UDim2.new(0, 380, 0, 0)
    container.AnchorPoint = isMobile and Vector2.new(0.5, 0) or Vector2.new(1, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = screenGui
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 12)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = isMobile and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Right
    listLayout.Parent = container
    
    self.Container = container
    self.ScreenGui = screenGui
end

function NotificationManager:Create(options)
    self:Init()
    
    options = options or {}
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info"
    local icon = options.Icon
    local callback = options.Callback
    
    local theme = ThemeManager:GetTheme()
    local isMobile = Utility:IsMobile()
    
    local typeColors = {
        Info = theme.Info,
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
    
    -- Remove oldest if too many
    if self.ActiveNotifications >= self.MaxNotifications then
        local oldest = self.Container:FindFirstChild("Notification")
        if oldest then oldest:Destroy() end
    end
    
    -- Notification Container
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = theme.Secondary
    notification.BackgroundTransparency = 0.1
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.Position = UDim2.new(isMobile and 0.5 or 1, isMobile and 0 or 50, 0, 0)
    notification.AnchorPoint = isMobile and Vector2.new(0.5, 0) or Vector2.new(0, 0)
    notification.ClipsDescendants = true
    notification.Parent = self.Container
    
    Utility:ApplyCorner(notification, isMobile and 16 or 14)
    Utility:CreateShadow(notification, 0.6)
    
    -- Glass effect
    local glassOverlay = Instance.new("Frame")
    glassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glassOverlay.BackgroundTransparency = 0.95
    glassOverlay.Size = UDim2.new(1, 0, 1, 0)
    glassOverlay.Parent = notification
    
    Utility:ApplyCorner(glassOverlay, isMobile and 16 or 14)
    
    -- Accent Bar (Left side)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Parent = notification
    
    Utility:ApplyGradient(accentBar, ColorSequence.new{
        ColorSequenceKeypoint.new(0, accentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(accentColor.R * 255 + 30, 255),
            math.min(accentColor.G * 255 + 30, 255),
            math.min(accentColor.B * 255 + 30, 255)
        ))
    }, 90)
    
    -- Glow effect
    Utility:CreateGlow(notification, accentColor, 0.2)
    
    -- Content Container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 18 : 16)
    content.Size = UDim2.new(1, -(isMobile and 40 : 36), 1, -(isMobile and 36 : 32))
    content.Parent = notification
    
    -- Icon
    if icon then
        local iconBG = Instance.new("Frame")
        iconBG.Name = "IconBG"
        iconBG.BackgroundColor3 = accentColor
        iconBG.BackgroundTransparency = 0.9
        iconBG.Size = UDim2.new(0, isMobile and 44 : 40, 0, isMobile and 44 : 40)
        iconBG.Position = UDim2.new(0, 0, 0, 0)
        iconBG.Parent = content
        
        Utility:ApplyCorner(iconBG, isMobile and 12 : 10)
        
        local iconImage = Instance.new("ImageLabel")
        iconImage.Name = "Icon"
        iconImage.BackgroundTransparency = 1
        iconImage.Image = IconLibrary:Get(icon)
        iconImage.ImageColor3 = accentColor
        iconImage.Size = UDim2.new(0, isMobile and 26 : 24, 0, isMobile and 26 : 24)
        iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
        iconImage.Parent = iconBG
    end
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, icon and (isMobile and 54 : 50) or 0, 0, 0)
    titleLabel.Size = UDim2.new(1, -(icon and (isMobile and 84 : 80) or (isMobile and 40 : 30)), 0, isMobile and 24 : 22)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = isMobile and 15 : 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = content
    
    -- Description
    if description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, icon and (isMobile and 54 : 50) or 0, 0, isMobile and 28 : 26)
        descLabel.Size = UDim2.new(1, -(icon and (isMobile and 84 : 80) or (isMobile and 40 : 30)), 1, -(isMobile and 28 : 26))
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = theme.TextDark
        descLabel.TextSize = isMobile and 13 : 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.Parent = content
    end
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -(isMobile and 40 : 30), 0, 0)
    closeBtn.Size = UDim2.new(0, isMobile and 40 : 30, 0, isMobile and 40 : 30)
    closeBtn.Text = ""
    closeBtn.Parent = content
    
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = IconLibrary:Get("x")
    closeIcon.ImageColor3 = theme.TextDark
    closeIcon.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Parent = closeBtn
    
    -- Progress Bar
    local progressBG = Instance.new("Frame")
    progressBG.Name = "ProgressBG"
    progressBG.BackgroundColor3 = theme.Tertiary
    progressBG.BackgroundTransparency = 0.5
    progressBG.BorderSizePixel = 0
    progressBG.Position = UDim2.new(0, 4, 1, -4)
    progressBG.Size = UDim2.new(1, -8, 0, 3)
    progressBG.Parent = notification
    
    Utility:ApplyCorner(progressBG, 2)
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Parent = progressBG
    
    Utility:ApplyCorner(progressBar, 2)
    
    -- Calculate height
    local baseHeight = isMobile and 90 : 80
    if description == "" then
        baseHeight = isMobile and 70 : 60
    end
    
    local textSize = TextService:GetTextSize(
        description,
        isMobile and 13 : 12,
        Enum.Font.Gotham,
        Vector2.new(content.AbsoluteSize.X - (icon and (isMobile and 84 : 80) or (isMobile and 40 : 30)), math.huge)
    )
    
    local finalHeight = math.max(baseHeight, math.min(textSize.Y + (isMobile and 56 : 50), isMobile and 150 : 120))
    
    -- Animations
    self.ActiveNotifications = self.ActiveNotifications + 1
    
    notification.Size = UDim2.new(1, 0, 0, 0)
    
    -- Slide & expand animation
    Utility:Spring(notification, {
        Size = UDim2.new(1, 0, 0, finalHeight),
        Position = UDim2.new(isMobile and 0.5 or 1, 0, 0, 0),
        BackgroundTransparency = 0.1
    })
    
    -- Progress animation
    Utility:Tween(progressBar, {
        Size = UDim2.new(0, 0, 1, 0)
    }, duration, Enum.EasingStyle.Linear)
    
    -- Auto close
    local closed = false
    local function closeNotification()
        if closed then return end
        closed = true
        
        Utility:Tween(notification, {
            Position = UDim2.new(isMobile and 0.5 or 1, isMobile and 0 : 100, 0, 0),
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            notification:Destroy()
            self.ActiveNotifications = math.max(0, self.ActiveNotifications - 1)
        end)
    end
    
    task.delay(duration, closeNotification)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(closeNotification)
    
    -- Hover effects
    closeBtn.MouseEnter:Connect(function()
        Utility:Spring(closeIcon, {
            ImageColor3 = theme.Text,
            Size = UDim2.new(0, (isMobile and 22 : 20), 0, (isMobile and 22 : 20))
        })
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility:Spring(closeIcon, {
            ImageColor3 = theme.TextDark,
            Size = UDim2.new(0, (isMobile and 20 : 18), 0, (isMobile and 20 : 18))
        })
    end)
    
    -- Click callback
    if callback then
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                callback()
                closeNotification()
            end
        end)
    end
    
    return notification
end

-- ═══════════════════════════════════════════════════════════
-- ENHANCED TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════

local TooltipManager = {
    CurrentTooltip = nil,
    Container = nil,
}

function TooltipManager:Init()
    if self.Container then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaXTooltips_v2"
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
    if Utility:IsMobile() then return end -- Disable tooltips on mobile
    
    self:Init()
    self:Hide()
    
    local theme = ThemeManager:GetTheme()
    
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.BackgroundColor3 = theme.Tertiary
    tooltip.BackgroundTransparency = 0.05
    tooltip.BorderSizePixel = 0
    tooltip.Size = UDim2.new(0, 0, 0, 0)
    tooltip.ZIndex = 10
    tooltip.Parent = self.Container
    
    Utility:ApplyCorner(tooltip, 8)
    Utility:CreateShadow(tooltip, 0.5)
    Utility:CreateGlow(tooltip, theme.Accent, 0.15)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -20, 1, -16)
    textLabel.Position = UDim2.new(0, 10, 0, 8)
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Text = text
    textLabel.TextColor3 = theme.Text
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tooltip
    
    local textSize = TextService:GetTextSize(
        text,
        12,
        Enum.Font.GothamMedium,
        Vector2.new(300, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 16)
    
    -- Position near mouse
    local updatePosition = function()
        local mousePos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
    end
    
    updatePosition()
    
    local connection
    connection = RunService.RenderStepped:Connect(updatePosition)
    
    Utility:Spring(tooltip, {BackgroundTransparency = 0.05})
    Utility:Spring(textLabel, {TextTransparency = 0})
    
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
    if Utility:IsMobile() then return end
    
    element.MouseEnter:Connect(function()
        self:Show(text, element)
    end)
    
    element.MouseLeave:Connect(function()
        self:Hide()
    end)
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW CLASS - ENHANCED
-- ═══════════════════════════════════════════════════════════

local Window = {}
Window.__index = Window

function Window:Create(options)
    local self = setmetatable({}, Window)
    
    options = options or {}
    self.Name = options.Name or "NebulaX UI"
    self.Subtitle = options.Subtitle or "v2.0 Aesthetic"
    self.MobileSupport = options.MobileSupport ~= false
    self.Theme = ThemeManager:SetTheme(options.Theme or "Aesthetic", options.AccentColor)
    
    local isMobile = Utility:IsMobile()
    local screenSize = Utility:GetScreenSize()
    
    -- Responsive sizing
    if isMobile then
        self.Size = options.Size or UDim2.new(0.95, 0, 0, math.min(screenSize.Y * 0.8, 650))
    else
        self.Size = options.Size or UDim2.new(0, 620, 0, 520)
    end
    
    self.MinSize = options.MinSize or Vector2.new(400, 300)
    self.Position = options.Position
    self.SaveConfig = options.SaveConfig ~= false
    self.ConfigName = options.ConfigName or "default"
    self.Watermark = options.Watermark
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Visible = true
    self.IsMobile = isMobile
    
    self:CreateUI()
    
    task.delay(0.5, function()
        self:LoadConfiguration()
    end)
    
    return self
end

function Window:CreateUI()
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaX_v2_" .. self.Name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    screenGui.IgnoreGuiInset = true
    
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
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = self.Size
    mainFrame.Position = self.Position or UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Utility:ApplyCorner(mainFrame, isMobile and 20 : 16)
    
    -- Glass/Blur overlay
    local glassOverlay = Instance.new("Frame")
    glassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glassOverlay.BackgroundTransparency = 0.97
    glassOverlay.Size = UDim2.new(1, 0, 1, 0)
    glassOverlay.Parent = mainFrame
    
    Utility:ApplyCorner(glassOverlay, isMobile and 20 : 16)
    
    -- Background Gradient
    Utility:ApplyGradient(mainFrame, theme.BackgroundGradient, 135)
    
    -- Enhanced Shadow
    Utility:CreateShadow(mainFrame, 0.4)
    
    -- Accent Glow
    Utility:CreateGlow(mainFrame, theme.Accent, 0.1)
    
    -- Border
    Utility:ApplyStroke(mainFrame, theme.Border, 1, 0.7)
    
    self.MainFrame = mainFrame
    
    -- Create UI Elements
    self:CreateHeader()
    self:CreateTabContainer()
    self:CreateContentArea()
    self:CreateFooter()
    
    if self.Watermark then
        self:CreateWatermark()
    end
    
    -- Make draggable
    if not isMobile then
        Utility:MakeDraggable(mainFrame, self.Header)
    end
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftControl then
            self:Toggle()
        end
    end)
    
    -- Mobile swipe to minimize
    if isMobile then
        local swipeStart = nil
        local swipeThreshold = 50
        
        self.Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                swipeStart = input.Position
            end
        end)
        
        self.Header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and swipeStart then
                local swipeDelta = input.Position - swipeStart
                if swipeDelta.Y > swipeThreshold then
                    self:Minimize()
                end
                swipeStart = nil
            end
        end)
    end
end

function Window:CreateHeader()
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    local headerHeight = isMobile and 70 : 60
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = theme.Secondary
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.Parent = self.MainFrame
    
    Utility:ApplyCorner(header, isMobile and 20 : 16)
    
    -- Glass effect
    local headerGlass = Instance.new("Frame")
    headerGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    headerGlass.BackgroundTransparency = 0.96
    headerGlass.Size = UDim2.new(1, 0, 1, 0)
    headerGlass.Parent = header
    
    Utility:ApplyCorner(headerGlass, isMobile and 20 : 16)
    
    -- Fix corner bottom
    local cornerFix = Instance.new("Frame")
    cornerFix.BackgroundColor3 = theme.Secondary
    cornerFix.BackgroundTransparency = 0.1
    cornerFix.BorderSizePixel = 0
    cornerFix.Position = UDim2.new(0, 0, 1, -15)
    cornerFix.Size = UDim2.new(1, 0, 0, 15)
    cornerFix.Parent = header
    
    -- Accent gradient line
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.BackgroundColor3 = theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.Size = UDim2.new(1, 0, 0, 3)
    accentLine.Parent = header
    
    Utility:ApplyGradient(accentLine, theme.AccentGradient, 90)
    
    -- Logo Container
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.BackgroundColor3 = theme.Accent
    logoContainer.BackgroundTransparency = 0.9
    logoContainer.Position = UDim2.new(0, isMobile and 20 : 18, 0.5, 0)
    logoContainer.Size = UDim2.new(0, isMobile and 42 : 38, 0, isMobile and 42 : 38)
    logoContainer.AnchorPoint = Vector2.new(0, 0.5)
    logoContainer.Parent = header
    
    Utility:ApplyCorner(logoContainer, isMobile and 12 : 10)
    Utility:CreateGlow(logoContainer, theme.Accent, 0.25)
    
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.BackgroundTransparency = 1
    logo.Image = IconLibrary:Get("sparkles")
    logo.ImageColor3 = theme.Accent
    logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    logo.Size = UDim2.new(0, isMobile and 24 : 22, 0, isMobile and 24 : 22)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Parent = logoContainer
    
    -- Spinning animation
    RunService.RenderStepped:Connect(function()
        logo.Rotation = logo.Rotation + 0.5
    end)
    
    -- Title Container
    local titleContainer = Instance.new("Frame")
    titleContainer.BackgroundTransparency = 1
    titleContainer.Position = UDim2.new(0, isMobile and 75 : 68, 0, isMobile and 15 : 12)
    titleContainer.Size = UDim2.new(0.5, -(isMobile and 75 : 68), 1, -(isMobile and 30 : 24))
    titleContainer.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, isMobile and 22 : 20)
    title.Font = Enum.Font.GothamBlack
    title.Text = self.Name
    title.TextColor3 = theme.Text
    title.TextSize = isMobile and 18 : 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = titleContainer
    
    -- Title gradient
    Utility:ApplyGradient(title, ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.Text),
        ColorSequenceKeypoint.new(1, theme.Accent)
    }, 90)
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 0, 0, isMobile and 24 : 22)
    subtitle.Size = UDim2.new(1, 0, 0, isMobile and 16 : 14)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Text = self.Subtitle
    subtitle.TextColor3 = theme.TextDark
    subtitle.TextSize = isMobile and 13 : 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    subtitle.Parent = titleContainer
    
    -- Control Buttons
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "Controls"
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Position = UDim2.new(1, -(isMobile and 140 : 130), 0.5, 0)
    controlsContainer.Size = UDim2.new(0, isMobile and 130 : 120, 0, isMobile and 40 : 36)
    controlsContainer.AnchorPoint = Vector2.new(0, 0.5)
    controlsContainer.Parent = header
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, isMobile and 10 : 8)
    controlsLayout.Parent = controlsContainer
    
    -- Create control buttons
    self:CreateControlButton(controlsContainer, "minimize", function()
        self:Minimize()
    end)
    
    self:CreateControlButton(controlsContainer, "settings", function()
        self:OpenSettings()
    end)
    
    self:CreateControlButton(controlsContainer, "x", function()
        self:Destroy()
    end)
    
    self.Header = header
end

function Window:CreateControlButton(parent, icon, callback)
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    local btnSize = isMobile and 36 : 32
    
    local button = Instance.new("TextButton")
    button.Name = icon .. "Button"
    button.BackgroundColor3 = theme.Tertiary
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, btnSize, 0, btnSize)
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    Utility:ApplyCorner(button, isMobile and 10 : 8)
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.BackgroundTransparency = 1
    iconImage.Image = IconLibrary:Get(icon)
    iconImage.ImageColor3 = theme.TextDark
    iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconImage.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImage.Parent = button
    
    button.MouseButton1Click:Connect(function()
        Utility:CreateRipple(button, button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2, theme.Accent)
        if callback then callback() end
    end)
    
    button.MouseEnter:Connect(function()
        Utility:Spring(button, {
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 0.1
        })
        Utility:Spring(iconImage, {
            ImageColor3 = theme.Text,
            Size = UDim2.new(0, (isMobile and 22 : 20), 0, (isMobile and 22 : 20))
        })
    end)
    
    button.MouseLeave:Connect(function()
        Utility:Spring(button, {
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 0.3
        })
        Utility:Spring(iconImage, {
            ImageColor3 = theme.TextDark,
            Size = UDim2.new(0, (isMobile and 20 : 18), 0, (isMobile and 20 : 18))
        })
    end)
    
    TooltipManager:Attach(button, icon:gsub("^%l", string.upper):gsub("-", " "))
    
    return button
end

function Window:CreateTabContainer()
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    local headerHeight = isMobile and 70 : 60
    local footerHeight = isMobile and 50 : 45
    local tabWidth = isMobile and 0 : 180
    
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = theme.Secondary
    tabContainer.BackgroundTransparency = isMobile and 1 : 0.2
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = isMobile and UDim2.new(0, 0, 1, -footerHeight) or UDim2.new(0, 0, 0, headerHeight)
    tabContainer.Size = isMobile and UDim2.new(1, 0, 0, footerHeight) or UDim2.new(0, tabWidth, 1, -(headerHeight + footerHeight))
    tabContainer.ScrollBarThickness = isMobile and 0 : 4
    tabContainer.ScrollBarImageColor3 = theme.Accent
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = isMobile and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
    tabContainer.ScrollingDirection = isMobile and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
    tabContainer.Parent = self.MainFrame
    
    if not isMobile then
        local glass = Instance.new("Frame")
        glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        glass.BackgroundTransparency = 0.96
        glass.Size = UDim2.new(1, 0, 1, 0)
        glass.Parent = tabContainer
    end
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, isMobile and 8 : 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = isMobile and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center
    listLayout.Parent = tabContainer
    
    Utility:AddPadding(tabContainer, isMobile and 12 : 12)
    
    self.TabContainer = tabContainer
end

function Window:CreateContentArea()
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    local headerHeight = isMobile and 70 : 60
    local footerHeight = isMobile and 50 : 45
    local tabWidth = isMobile and 0 : 180
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Position = isMobile and UDim2.new(0, 0, 0, headerHeight) or UDim2.new(0, tabWidth, 0, headerHeight)
    contentArea.Size = isMobile and UDim2.new(1, 0, 1, -(headerHeight + footerHeight + (isMobile and footerHeight : 0))) or UDim2.new(1, -tabWidth, 1, -(headerHeight + footerHeight))
    contentArea.ClipsDescendants = true
    contentArea.Parent = self.MainFrame
    
    self.ContentArea = contentArea
end

function Window:CreateFooter()
    local theme = self.Theme
    local isMobile = self.IsMobile
    
    local footerHeight = isMobile and 50 : 45
    
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.BackgroundColor3 = theme.Secondary
    footer.BackgroundTransparency = 0.1
    footer.BorderSizePixel = 0
    footer.Position = UDim2.new(0, 0, 1, -footerHeight)
    footer.Size = UDim2.new(1, 0, 0, footerHeight)
    footer.Parent = self.MainFrame
    
    if not isMobile then
        Utility:ApplyCorner(footer, 16)
        
        local cornerFix = Instance.new("Frame")
        cornerFix.BackgroundColor3 = theme.Secondary
        cornerFix.BackgroundTransparency = 0.1
        cornerFix.BorderSizePixel = 0
        cornerFix.Size = UDim2.new(1, 0, 0, 15)
        cornerFix.Parent = footer
    end
    
    -- Glass effect
    local footerGlass = Instance.new("Frame")
    footerGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    footerGlass.BackgroundTransparency = 0.96
    footerGlass.Size = UDim2.new(1, 0, 1, 0)
    footerGlass.Parent = footer
    
    if not isMobile then
        Utility:ApplyCorner(footerGlass, 16)
    end
    
    -- Accent line
    local accentLine = Instance.new("Frame")
    accentLine.BackgroundColor3 = theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Parent = footer
    
    Utility:ApplyGradient(accentLine, theme.AccentGradient, 90)
    
    -- Footer content
    local footerText = Instance.new("TextLabel")
    footerText.BackgroundTransparency = 1
    footerText.Position = UDim2.new(0, isMobile and 15 : 18, 0.5, 0)
    footerText.Size = UDim2.new(0.5, 0, 0, isMobile and 18 : 16)
    footerText.AnchorPoint = Vector2.new(0, 0.5)
    footerText.Font = Enum.Font.GothamBlack
    footerText.Text = "NebulaX v" .. NebulaX.Version
    footerText.TextColor3 = theme.Accent
    footerText.TextSize = isMobile and 12 : 11
    footerText.TextXAlignment = Enum.TextXAlignment.Left
    footerText.Parent = footer
    
    local userInfo = Instance.new("TextLabel")
    userInfo.BackgroundTransparency = 1
    userInfo.Position = UDim2.new(1, -(isMobile and 15 : 18), 0.5, 0)
    userInfo.Size = UDim2.new(0.5, 0, 0, isMobile and 18 : 16)
    userInfo.AnchorPoint = Vector2.new(1, 0.5)
    userInfo.Font = Enum.Font.GothamMedium
    userInfo.Text = (isMobile and "" or Player.Name .. " | ") .. Utility:GetPlatform()
    userInfo.TextColor3 = theme.TextDark
    userInfo.TextSize = isMobile and 11 : 10
    userInfo.TextXAlignment = Enum.TextXAlignment.Right
    userInfo.TextTruncate = Enum.TextTruncate.AtEnd
    userInfo.Parent = footer
    
    self.Footer = footer
end

function Window:CreateWatermark()
    local theme = self.Theme
    local isMobile = Utility:IsMobile()
    
    local watermark = Instance.new("Frame")
    watermark.Name = "Watermark"
    watermark.BackgroundColor3 = theme.Secondary
    watermark.BackgroundTransparency = 0.1
    watermark.BorderSizePixel = 0
    watermark.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 15 : 12)
    watermark.Size = UDim2.new(0, isMobile and 220 : 200, 0, isMobile and 40 : 36)
    watermark.Parent = self.ScreenGui
    
    Utility:ApplyCorner(watermark, isMobile and 12 : 10)
    Utility:CreateShadow(watermark, 0.6)
    Utility:CreateGlow(watermark, theme.Accent, 0.15)
    
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = watermark
    
    Utility:ApplyCorner(glass, isMobile and 12 : 10)
    
    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Image = IconLibrary:Get("activity")
    icon.ImageColor3 = theme.Accent
    icon.Position = UDim2.new(0, isMobile and 12 : 10, 0.5, 0)
    icon.Size = UDim2.new(0, isMobile and 22 : 20, 0, isMobile and 22 : 20)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Parent = watermark
    
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Position = UDim2.new(0, isMobile and 42 : 38, 0.5, 0)
    text.Size = UDim2.new(1, -(isMobile and 50 : 46), 0, isMobile and 18 : 16)
    text.AnchorPoint = Vector2.new(0, 0.5)
    text.Font = Enum.Font.GothamBold
    text.Text = self.Watermark or "NebulaX"
    text.TextColor3 = theme.Text
    text.TextSize = isMobile and 13 : 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = watermark
    
    -- FPS Counter
    local fps = 0
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        fps = fps + 1
        if tick() - lastUpdate >= 1 then
            text.Text = string.format("%s | %d FPS", self.Watermark or "NebulaX", fps)
            fps = 0
            lastUpdate = tick()
        end
    end)
end

-- Continuará con los métodos de Tab, Section y Elementos...
-- (Por límite de caracteres, incluiré la parte 2 en el siguiente mensaje)
-- ═══════════════════════════════════════════════════════════
-- WINDOW METHODS - CONTINUED
-- ═══════════════════════════════════════════════════════════

function Window:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "file"
    local orderIndex = options.Order or (#self.Tabs + 1)
    
    local theme = self.Theme
    local isMobile = self.IsMobile
    
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
    tabButton.BackgroundColor3 = theme.Tertiary
    tabButton.BackgroundTransparency = 0.3
    tabButton.BorderSizePixel = 0
    tabButton.Size = isMobile and UDim2.new(0, 100, 1, -24) or UDim2.new(1, -24, 0, 50)
    tabButton.AutoButtonColor = false
    tabButton.Text = ""
    tabButton.LayoutOrder = orderIndex
    tabButton.Parent = self.TabContainer
    
    Utility:ApplyCorner(tabButton, isMobile and 12 : 10)
    
    -- Icon Container
    local iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.BackgroundColor3 = theme.Accent
    iconContainer.BackgroundTransparency = 0.9
    iconContainer.Position = isMobile and UDim2.new(0.5, 0, 0, 10) or UDim2.new(0, 12, 0, 10)
    iconContainer.Size = UDim2.new(0, isMobile and 32 : 28, 0, isMobile and 32 : 28)
    iconContainer.AnchorPoint = isMobile and Vector2.new(0.5, 0) or Vector2.new(0, 0)
    iconContainer.Parent = tabButton
    
    Utility:ApplyCorner(iconContainer, isMobile and 8 : 7)
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.BackgroundTransparency = 1
    iconImage.Image = IconLibrary:Get(tabIcon)
    iconImage.ImageColor3 = theme.TextDark
    iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconImage.Size = UDim2.new(0, isMobile and 18 : 16, 0, isMobile and 18 : 16)
    iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImage.Parent = iconContainer
    
    -- Tab Label
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.BackgroundTransparency = 1
    tabLabel.Position = isMobile and UDim2.new(0, 0, 1, -18) or UDim2.new(0, 48, 0, 0)
    tabLabel.Size = isMobile and UDim2.new(1, 0, 0, 16) or UDim2.new(1, -48, 1, 0)
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.Text = tabName
    tabLabel.TextColor3 = theme.TextDark
    tabLabel.TextSize = isMobile and 11 : 13
    tabLabel.TextXAlignment = isMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    tabLabel.TextYAlignment = isMobile and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center
    tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tabLabel.Parent = tabButton
    
    -- Active Indicator
    local activeIndicator = Instance.new("Frame")
    activeIndicator.Name = "ActiveIndicator"
    activeIndicator.BackgroundColor3 = theme.Accent
    activeIndicator.BorderSizePixel = 0
    activeIndicator.Position = isMobile and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
    activeIndicator.Size = isMobile and UDim2.new(1, 0, 0, 3) or UDim2.new(0, 3, 1, 0)
    activeIndicator.Visible = false
    activeIndicator.Parent = tabButton
    
    if isMobile then
        Utility:ApplyCorner(activeIndicator, 2)
    end
    
    Utility:ApplyGradient(activeIndicator, theme.AccentGradient, isMobile and 90 : 0)
    
    -- Tab Content Container
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tabName .. "Content"
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.ScrollBarThickness = isMobile and 0 : 4
    tabContent.ScrollBarImageColor3 = theme.Accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = self.ContentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, isMobile and 16 : 14)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    Utility:AddPadding(tabContent, isMobile and 18 : 16)
    
    tab.Button = tabButton
    tab.Content = tabContent
    tab.IconImage = iconImage
    tab.IconContainer = iconContainer
    tab.Label = tabLabel
    tab.ActiveIndicator = activeIndicator
    
    -- Tab selection
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
        Utility:CreateRipple(tabButton, tabButton.AbsoluteSize.X/2, tabButton.AbsoluteSize.Y/2, theme.Accent)
    end)
    
    tabButton.MouseEnter:Connect(function()
        if not tab.Visible then
            Utility:Spring(tabButton, {BackgroundTransparency = 0.1})
            Utility:Spring(iconContainer, {BackgroundTransparency = 0.85})
            Utility:Spring(iconImage, {
                ImageColor3 = theme.Text,
                Size = UDim2.new(0, (isMobile and 20 : 18), 0, (isMobile and 20 : 18))
            })
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if not tab.Visible then
            Utility:Spring(tabButton, {BackgroundTransparency = 0.3})
            Utility:Spring(iconContainer, {BackgroundTransparency = 0.9})
            Utility:Spring(iconImage, {
                ImageColor3 = theme.TextDark,
                Size = UDim2.new(0, (isMobile and 18 : 16), 0, (isMobile and 18 : 16))
            })
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        task.delay(0.1, function()
            self:SelectTab(tab)
        end)
    end
    
    return setmetatable(tab, {__index = TabMethods})
end

function Window:SelectTab(tab)
    local theme = self.Theme
    
    for _, t in pairs(self.Tabs) do
        t.Visible = false
        t.Content.Visible = false
        t.ActiveIndicator.Visible = false
        
        Utility:Spring(t.Button, {BackgroundTransparency = 0.3})
        Utility:Spring(t.IconContainer, {BackgroundTransparency = 0.9})
        Utility:Spring(t.IconImage, {ImageColor3 = theme.TextDark})
        Utility:Spring(t.Label, {TextColor3 = theme.TextDark})
    end
    
    tab.Visible = true
    tab.Content.Visible = true
    tab.ActiveIndicator.Visible = true
    self.CurrentTab = tab
    
    Utility:Spring(tab.Button, {BackgroundTransparency = 0.05})
    Utility:Spring(tab.IconContainer, {BackgroundTransparency = 0.1})
    Utility:Spring(tab.IconImage, {ImageColor3 = theme.Accent})
    Utility:Spring(tab.Label, {TextColor3 = theme.Text})
    
    -- Glow effect on icon
    Utility:CreateGlow(tab.IconContainer, theme.Accent, 0.3)
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    
    local theme = self.Theme
    local headerHeight = self.IsMobile and 70 : 60
    
    if self.Minimized then
        Utility:Spring(self.MainFrame, {
            Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, headerHeight)
        })
    else
        Utility:Spring(self.MainFrame, {
            Size = self.Size
        })
    end
end

function Window:Toggle()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.MainFrame.Visible = true
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        Utility:Spring(self.MainFrame, {
            Size = self.Size,
            BackgroundTransparency = 0.05
        })
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
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        self:SaveConfiguration()
        self.ScreenGui:Destroy()
    end)
end

function Window:OpenSettings()
    NebulaX:Notify({
        Title = "Settings",
        Description = "Settings panel coming soon!",
        Type = "Info",
        Icon = "settings",
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
    
    for tabName, elements in pairs(config) do
        for _, tab in pairs(self.Tabs) do
            if tab.Name == tabName then
                for elementName, value in pairs(elements) do
                    local element = tab.Elements[elementName]
                    if element and element.Set then
                        pcall(function()
                            element:Set(value)
                        end)
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
    local theme = self.Window.Theme
    local isMobile = self.Window.IsMobile
    
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
    sectionLayout.Padding = UDim.new(0, isMobile and 12 : 10)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = sectionFrame
    
    -- Section Header
    local headerContainer = Instance.new("Frame")
    headerContainer.Name = "HeaderContainer"
    headerContainer.BackgroundTransparency = 1
    headerContainer.Size = UDim2.new(1, 0, 0, isMobile and 32 : 28)
    headerContainer.LayoutOrder = 0
    headerContainer.Parent = sectionFrame
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, -50, 1, 0)
    header.Font = Enum.Font.GothamBlack
    header.Text = name
    header.TextColor3 = theme.Text
    header.TextSize = isMobile and 16 : 15
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = headerContainer
    
    -- Gradient text effect
    Utility:ApplyGradient(header, ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.Text),
        ColorSequenceKeypoint.new(1, theme.Accent)
    }, 90)
    
    -- Decorative line
    local decorLine = Instance.new("Frame")
    decorLine.Name = "DecorLine"
    decorLine.BackgroundColor3 = theme.Accent
    decorLine.BorderSizePixel = 0
    decorLine.Position = UDim2.new(1, -40, 0.5, 0)
    decorLine.Size = UDim2.new(0, 40, 0, 2)
    decorLine.AnchorPoint = Vector2.new(1, 0.5)
    decorLine.Parent = headerContainer
    
    Utility:ApplyCorner(decorLine, 1)
    Utility:ApplyGradient(decorLine, theme.AccentGradient, 90)
    
    section.Frame = sectionFrame
    table.insert(self.Sections, section)
    
    return setmetatable(section, {__index = SectionMethods})
end

-- Quick methods
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
-- SECTION METHODS - UI ELEMENTS
-- ═══════════════════════════════════════════════════════════

SectionMethods = {}

-- ═════════════════ LABEL ═════════════════
function SectionMethods:CreateLabel(options)
    options = options or {}
    local text = options.Text or "Label"
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
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
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = theme.TextDark
    label.TextSize = isMobile and 14 : 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.RichText = true
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
    local description = options.Description or ""
    local callback = options.Callback or function() end
    local icon = options.Icon
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local buttonHeight = description ~= "" and (isMobile and 70 : 60) or (isMobile and 50 : 45)
    
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.BackgroundColor3 = theme.Secondary
    buttonFrame.BackgroundTransparency = 0.2
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Size = UDim2.new(1, 0, 0, buttonHeight)
    buttonFrame.AutoButtonColor = false
    buttonFrame.Text = ""
    buttonFrame.LayoutOrder = #self.Elements + 1
    buttonFrame.Parent = self.Frame
    
    Utility:ApplyCorner(buttonFrame, isMobile and 14 : 12)
    Utility:CreateShadow(buttonFrame, 0.8)
    
    -- Glass overlay
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = buttonFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    -- Border
    local border = Utility:ApplyStroke(buttonFrame, theme.Border, 1, 0.7)
    
    -- Icon
    if icon then
        local iconBG = Instance.new("Frame")
        iconBG.BackgroundColor3 = theme.Accent
        iconBG.BackgroundTransparency = 0.9
        iconBG.Position = UDim2.new(0, isMobile and 15 : 12, 0.5, 0)
        iconBG.Size = UDim2.new(0, isMobile and 40 : 36, 0, isMobile and 40 : 36)
        iconBG.AnchorPoint = Vector2.new(0, 0.5)
        iconBG.Parent = buttonFrame
        
        Utility:ApplyCorner(iconBG, isMobile and 10 : 9)
        
        local iconImage = Instance.new("ImageLabel")
        iconImage.BackgroundTransparency = 1
        iconImage.Image = IconLibrary:Get(icon)
        iconImage.ImageColor3 = theme.Accent
        iconImage.Size = UDim2.new(0, isMobile and 22 : 20, 0, isMobile and 22 : 20)
        iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
        iconImage.Parent = iconBG
    end
    
    local textContainer = Instance.new("Frame")
    textContainer.BackgroundTransparency = 1
    textContainer.Position = UDim2.new(0, icon and (isMobile and 65 : 58) or (isMobile and 15 : 12), 0, isMobile and 12 : 10)
    textContainer.Size = UDim2.new(1, -(icon and (isMobile and 80 : 70) or (isMobile and 30 : 24)), 1, -(isMobile and 24 : 20))
    textContainer.Parent = buttonFrame
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Size = UDim2.new(1, 0, 0, isMobile and 20 : 18)
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.Text = name
    buttonLabel.TextColor3 = theme.Text
    buttonLabel.TextSize = isMobile and 15 : 14
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.TextTruncate = Enum.TextTruncate.AtEnd
    buttonLabel.Parent = textContainer
    
    if description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 0, 0, isMobile and 22 : 20)
        descLabel.Size = UDim2.new(1, 0, 1, -(isMobile and 22 : 20))
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = theme.TextDark
        descLabel.TextSize = isMobile and 12 : 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.Parent = textContainer
    end
    
    -- Click animation
    buttonFrame.MouseButton1Click:Connect(function()
        Utility:CreateRipple(buttonFrame, buttonFrame.AbsoluteSize.X/2, buttonFrame.AbsoluteSize.Y/2, theme.Accent)
        
        -- Bounce animation
        Utility:Tween(buttonFrame, {Size = UDim2.new(1, -4, 0, buttonHeight - 2)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            Utility:Spring(buttonFrame, {Size = UDim2.new(1, 0, 0, buttonHeight)})
        end)
        
        callback()
    end)
    
    buttonFrame.MouseEnter:Connect(function()
        Utility:Spring(buttonFrame, {BackgroundTransparency = 0.05})
        Utility:Spring(border, {Transparency = 0.3})
        Utility:CreateGlow(buttonFrame, theme.Accent, 0.2)
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        Utility:Spring(buttonFrame, {BackgroundTransparency = 0.2})
        Utility:Spring(border, {Transparency = 0.7})
    end)
    
    local element = {
        Frame = buttonFrame,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═════════════════ TOGGLE (ENHANCED) ═════════════════
function SectionMethods:CreateToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local default = options.Default or false
    local description = options.Description or ""
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local toggleHeight = description ~= "" and (isMobile and 65 : 55) or (isMobile and 50 : 45)
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.BackgroundColor3 = theme.Secondary
    toggleFrame.BackgroundTransparency = 0.2
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Size = UDim2.new(1, 0, 0, toggleHeight)
    toggleFrame.LayoutOrder = #self.Elements + 1
    toggleFrame.Parent = self.Frame
    
    Utility:ApplyCorner(toggleFrame, isMobile and 14 : 12)
    Utility:CreateShadow(toggleFrame, 0.8)
    Utility:ApplyStroke(toggleFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = toggleFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    -- Text container
    local textContainer = Instance.new("Frame")
    textContainer.BackgroundTransparency = 1
    textContainer.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 12 : 10)
    textContainer.Size = UDim2.new(1, -(isMobile and 85 : 75), 1, -(isMobile and 24 : 20))
    textContainer.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Size = UDim2.new(1, 0, 0, isMobile and 18 : 16)
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.Text = name
    toggleLabel.TextColor3 = theme.Text
    toggleLabel.TextSize = isMobile and 14 : 13
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    toggleLabel.Parent = textContainer
    
    if description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 0, 0, isMobile and 20 : 18)
        descLabel.Size = UDim2.new(1, 0, 1, -(isMobile and 20 : 18))
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = theme.TextDark
        descLabel.TextSize = isMobile and 11 : 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.Parent = textContainer
    end
    
    -- Toggle Switch (Modern Design)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.BackgroundColor3 = default and theme.Accent or theme.Tertiary
    toggleButton.BackgroundTransparency = 0.1
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(1, -(isMobile and 62 : 56), 0.5, 0)
    toggleButton.Size = UDim2.new(0, isMobile and 54 : 48, 0, isMobile and 30 : 26)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.AutoButtonColor = false
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    Utility:ApplyCorner(toggleButton, isMobile and 15 : 13)
    
    -- Glow when active
    if default then
        Utility:CreateGlow(toggleButton, theme.Accent, 0.3)
    end
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Position = default and UDim2.new(1, -(isMobile and 26 : 23), 0.5, 0) or UDim2.new(0, isMobile and 3 : 3, 0.5, 0)
    toggleCircle.Size = UDim2.new(0, isMobile and 24 : 20, 0, isMobile and 24 : 20)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.Parent = toggleButton
    
    Utility:ApplyCorner(toggleCircle, isMobile and 12 : 10)
    Utility:CreateShadow(toggleCircle, 0.5)
    
    -- Check icon
    local checkIcon = Instance.new("ImageLabel")
    checkIcon.Name = "CheckIcon"
    checkIcon.BackgroundTransparency = 1
    checkIcon.Image = IconLibrary:Get("check")
    checkIcon.ImageColor3 = theme.Accent
    checkIcon.ImageTransparency = default and 0 or 1
    checkIcon.Size = UDim2.new(0, isMobile and 14 : 12, 0, isMobile and 14 : 12)
    checkIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    checkIcon.Parent = toggleCircle
    
    local toggled = default
    
    local function updateToggle(value, skipCallback)
        toggled = value
        
        -- Background color
        Utility:Spring(toggleButton, {
            BackgroundColor3 = toggled and theme.Accent or theme.Tertiary,
            BackgroundTransparency = 0.1
        })
        
        -- Circle position
        Utility:Spring(toggleCircle, {
            Position = toggled and UDim2.new(1, -(isMobile and 26 : 23), 0.5, 0) or UDim2.new(0, isMobile and 3 : 3, 0.5, 0)
        })
        
        -- Check icon
        Utility:Spring(checkIcon, {
            ImageTransparency = toggled and 0 or 1,
            Rotation = toggled and 360 or 0
        })
        
        -- Glow effect
        if toggled then
            Utility:CreateGlow(toggleButton, theme.Accent, 0.3)
        end
        
        if not skipCallback then
            callback(toggled)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not toggled)
        Utility:CreateRipple(toggleButton, toggleButton.AbsoluteSize.X/2, toggleButton.AbsoluteSize.Y/2, theme.Accent)
    end)
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            updateToggle(not toggled)
        end
    end)
    
    toggleButton.MouseEnter:Connect(function()
        Utility:Spring(toggleCircle, {
            Size = UDim2.new(0, (isMobile and 26 : 22), 0, (isMobile and 26 : 22))
        })
    end)
    
    toggleButton.MouseLeave:Connect(function()
        Utility:Spring(toggleCircle, {
            Size = UDim2.new(0, (isMobile and 24 : 20), 0, (isMobile and 24 : 20))
        })
    end)
    
    local element = {
        Frame = toggleFrame,
        Value = toggled,
        Set = function(self, value)
            updateToggle(value, true)
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    if default then
        task.defer(function()
            callback(default)
        end)
    end
    
    return element
end

-- ═════════════════ SLIDER (ULTRA ENHANCED) ═════════════════
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
    local isMobile = self.Tab.Window.IsMobile
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.BackgroundColor3 = theme.Secondary
    sliderFrame.BackgroundTransparency = 0.2
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 75 : 68)
    sliderFrame.LayoutOrder = #self.Elements + 1
    sliderFrame.Parent = self.Frame
    
    Utility:ApplyCorner(sliderFrame, isMobile and 14 : 12)
    Utility:CreateShadow(sliderFrame, 0.8)
    Utility:ApplyStroke(sliderFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = sliderFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    -- Header
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 12 : 10)
    sliderLabel.Size = UDim2.new(0.6, 0, 0, isMobile and 18 : 16)
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.Text = name
    sliderLabel.TextColor3 = theme.Text
    sliderLabel.TextSize = isMobile and 14 : 13
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.TextTruncate = Enum.TextTruncate.AtEnd
    sliderLabel.Parent = sliderFrame
    
    -- Value display (Modern pill design)
    local valuePill = Instance.new("Frame")
    valuePill.BackgroundColor3 = theme.Accent
    valuePill.BackgroundTransparency = 0.85
    valuePill.BorderSizePixel = 0
    valuePill.Position = UDim2.new(1, -(isMobile and 75 : 68), 0, isMobile and 10 : 8)
    valuePill.Size = UDim2.new(0, isMobile and 65 : 58, 0, isMobile and 24 : 22)
    valuePill.Parent = sliderFrame
    
    Utility:ApplyCorner(valuePill, isMobile and 12 : 11)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = theme.Accent
    valueLabel.TextSize = isMobile and 13 : 12
    valueLabel.Parent = valuePill
    
    -- Slider Track Container
    local sliderTrackContainer = Instance.new("Frame")
    sliderTrackContainer.BackgroundTransparency = 1
    sliderTrackContainer.Position = UDim2.new(0, isMobile and 15 : 12, 1, -(isMobile and 25 : 22))
    sliderTrackContainer.Size = UDim2.new(1, -(isMobile and 30 : 24), 0, isMobile and 10 : 8)
    sliderTrackContainer.Parent = sliderFrame
    
    -- Track Background
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.BackgroundColor3 = theme.Tertiary
    sliderTrack.BackgroundTransparency = 0.3
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Size = UDim2.new(1, 0, 1, 0)
    sliderTrack.Parent = sliderTrackContainer
    
    Utility:ApplyCorner(sliderTrack, isMobile and 5 : 4)
    
    -- Fill (Gradient)
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.BackgroundColor3 = theme.Accent
    sliderFill.BackgroundTransparency = 0.1
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.ZIndex = 2
    sliderFill.Parent = sliderTrack
    
    Utility:ApplyCorner(sliderFill, isMobile and 5 : 4)
    Utility:ApplyGradient(sliderFill, theme.AccentGradient, 90)
    
    -- Handle (Enhanced)
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "Handle"
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
    sliderHandle.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderHandle.ZIndex = 3
    sliderHandle.Parent = sliderFill
    
    Utility:ApplyCorner(sliderHandle, isMobile and 10 : 9)
    Utility:CreateShadow(sliderHandle, 0.4)
    
    -- Handle inner glow
    local handleGlow = Instance.new("Frame")
    handleGlow.BackgroundColor3 = theme.Accent
    handleGlow.BackgroundTransparency = 0.5
    handleGlow.BorderSizePixel = 0
    handleGlow.Size = UDim2.new(0.6, 0, 0.6, 0)
    handleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    handleGlow.Parent = sliderHandle
    
    Utility:ApplyCorner(handleGlow, isMobile and 5 : 4)
    
    local dragging = false
    local currentValue = default
    
    local function updateValue(value)
        value = math.clamp(value, range[1], range[2])
        value = math.floor(value / increment + 0.5) * increment
        currentValue = value
        
        local percent = (value - range[1]) / (range[2] - range[1])
        
        Utility:Spring(sliderFill, {
            Size = UDim2.new(percent, 0, 1, 0)
        })
        
        Utility:Spring(sliderHandle, {
            Position = UDim2.new(1, 0, 0.5, 0)
        })
        
        -- Animate value change
        valueLabel.Text = tostring(value) .. suffix
        Utility:Spring(valuePill, {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, (isMobile and 68 : 61), 0, (isMobile and 24 : 22))
        })
        
        task.wait(0.1)
        Utility:Spring(valuePill, {
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, (isMobile and 65 : 58), 0, (isMobile and 24 : 22))
        })
        
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
            
            -- Scale up handle
            Utility:Spring(sliderHandle, {
                Size = UDim2.new(0, (isMobile and 24 : 22), 0, (isMobile and 24 : 22))
            })
            
            -- Glow effect
            Utility:CreateGlow(sliderHandle, theme.Accent, 0.4)
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            
            Utility:Spring(sliderHandle, {
                Size = UDim2.new(0, (isMobile and 20 : 18), 0, (isMobile and 20 : 18))
            })
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            slide(input)
        end
    end)
    
    -- Hover effect
    sliderTrack.MouseEnter:Connect(function()
        if not dragging then
            Utility:Spring(sliderHandle, {
                Size = UDim2.new(0, (isMobile and 22 : 20), 0, (isMobile and 22 : 20))
            })
        end
    end)
    
    sliderTrack.MouseLeave:Connect(function()
        if not dragging then
            Utility:Spring(sliderHandle, {
                Size = UDim2.new(0, (isMobile and 20 : 18), 0, (isMobile and 20 : 18))
            })
        end
    end)
    
    local element = {
        Frame = sliderFrame,
        Value = currentValue,
        Set = function(self, value)
            updateValue(value)
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    updateValue(default)
    
    return element
end

-- Continuaré en el siguiente mensaje con Dropdown, Textbox, ColorPicker, Keybind y ejemplos de uso...
-- ═════════════════ DROPDOWN (ULTRA ENHANCED) ═════════════════
function SectionMethods:CreateDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local list = options.Options or {"Option 1", "Option 2"}
    local default = options.Default or list[1]
    local callback = options.Callback or function() end
    local multiSelect = options.MultiSelect or false
    local searchable = options.Searchable or false
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.BackgroundColor3 = theme.Secondary
    dropdownFrame.BackgroundTransparency = 0.2
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Size = UDim2.new(1, 0, 0, isMobile and 55 : 50)
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.LayoutOrder = #self.Elements + 1
    dropdownFrame.Parent = self.Frame
    
    Utility:ApplyCorner(dropdownFrame, isMobile and 14 : 12)
    Utility:CreateShadow(dropdownFrame, 0.8)
    Utility:ApplyStroke(dropdownFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = dropdownFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    -- Header Button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Header"
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Size = UDim2.new(1, 0, 0, isMobile and 55 : 50)
    dropdownButton.AutoButtonColor = false
    dropdownButton.Text = ""
    dropdownButton.ZIndex = 2
    dropdownButton.Parent = dropdownFrame
    
    -- Icon
    local iconBG = Instance.new("Frame")
    iconBG.BackgroundColor3 = theme.Accent
    iconBG.BackgroundTransparency = 0.9
    iconBG.Position = UDim2.new(0, isMobile and 15 : 12, 0.5, 0)
    iconBG.Size = UDim2.new(0, isMobile and 36 : 32, 0, isMobile and 36 : 32)
    iconBG.AnchorPoint = Vector2.new(0, 0.5)
    iconBG.Parent = dropdownButton
    
    Utility:ApplyCorner(iconBG, isMobile and 9 : 8)
    
    local dropIcon = Instance.new("ImageLabel")
    dropIcon.BackgroundTransparency = 1
    dropIcon.Image = IconLibrary:Get("list")
    dropIcon.ImageColor3 = theme.Accent
    dropIcon.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    dropIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    dropIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    dropIcon.Parent = iconBG
    
    -- Text container
    local textContainer = Instance.new("Frame")
    textContainer.BackgroundTransparency = 1
    textContainer.Position = UDim2.new(0, isMobile and 60 : 52, 0, isMobile and 10 : 8)
    textContainer.Size = UDim2.new(1, -(isMobile and 110 : 100), 1, -(isMobile and 20 : 16))
    textContainer.Parent = dropdownButton
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Size = UDim2.new(1, 0, 0, isMobile and 16 : 14)
    dropdownLabel.Font = Enum.Font.GothamBold
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = theme.Text
    dropdownLabel.TextSize = isMobile and 13 : 12
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.TextTruncate = Enum.TextTruncate.AtEnd
    dropdownLabel.Parent = textContainer
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Position = UDim2.new(0, 0, 0, isMobile and 18 : 16)
    selectedLabel.Size = UDim2.new(1, 0, 1, -(isMobile and 18 : 16))
    selectedLabel.Font = Enum.Font.GothamMedium
    selectedLabel.Text = default
    selectedLabel.TextColor3 = theme.Accent
    selectedLabel.TextSize = isMobile and 12 : 11
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.Parent = textContainer
    
    -- Chevron
    local chevron = Instance.new("ImageLabel")
    chevron.BackgroundTransparency = 1
    chevron.Image = IconLibrary:Get("chevron-down")
    chevron.ImageColor3 = theme.TextDark
    chevron.Position = UDim2.new(1, -(isMobile and 40 : 35), 0.5, 0)
    chevron.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    chevron.AnchorPoint = Vector2.new(0, 0.5)
    chevron.Parent = dropdownButton
    
    -- Search Box (if searchable)
    local searchBox
    if searchable then
        searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.BackgroundColor3 = theme.Tertiary
        searchBox.BackgroundTransparency = 0.3
        searchBox.BorderSizePixel = 0
        searchBox.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 62 : 57)
        searchBox.Size = UDim2.new(1, -(isMobile and 30 : 24), 0, isMobile and 38 : 34)
        searchBox.Font = Enum.Font.Gotham
        searchBox.PlaceholderText = "🔍 Search..."
        searchBox.PlaceholderColor3 = theme.TextDark
        searchBox.Text = ""
        searchBox.TextColor3 = theme.Text
        searchBox.TextSize = isMobile and 13 : 12
        searchBox.ClearTextOnFocus = false
        searchBox.Visible = false
        searchBox.Parent = dropdownFrame
        
        Utility:ApplyCorner(searchBox, isMobile and 10 : 9)
        Utility:AddPadding(searchBox, isMobile and 10 : 8)
    end
    
    -- Options Container
    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Name = "Options"
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Position = UDim2.new(0, 0, 0, searchable and (isMobile and 108 : 98) or (isMobile and 55 : 50))
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.ScrollBarThickness = isMobile and 0 : 3
    optionsContainer.ScrollBarImageColor3 = theme.Accent
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsContainer.Visible = false
    optionsContainer.Parent = dropdownFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, isMobile and 6 : 4)
    optionsLayout.SortOrder = Enum.SortOrder.Name
    optionsLayout.Parent = optionsContainer
    
    Utility:AddPadding(optionsContainer, isMobile and 12 : 10, nil, nil, nil, isMobile and 8 : 6)
    
    local expanded = false
    local currentValue = default
    local selectedOptions = multiSelect and {[default] = true} or {}
    
    local function updateSelected()
        if multiSelect then
            local selected = {}
            for opt, _ in pairs(selectedOptions) do
                table.insert(selected, opt)
            end
            selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None Selected"
            currentValue = selected
        else
            selectedLabel.Text = currentValue
        end
    end
    
    local function createOption(optionName)
        local optionButton = Instance.new("TextButton")
        optionButton.Name = optionName
        optionButton.BackgroundColor3 = theme.Tertiary
        optionButton.BackgroundTransparency = 0.4
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, isMobile and 42 : 38)
        optionButton.AutoButtonColor = false
        optionButton.Text = ""
        optionButton.Parent = optionsContainer
        
        Utility:ApplyCorner(optionButton, isMobile and 10 : 9)
        
        -- Gradient hover effect
        local hoverGradient = Instance.new("Frame")
        hoverGradient.BackgroundColor3 = theme.Accent
        hoverGradient.BackgroundTransparency = 1
        hoverGradient.Size = UDim2.new(1, 0, 1, 0)
        hoverGradient.Parent = optionButton
        
        Utility:ApplyCorner(hoverGradient, isMobile and 10 : 9)
        Utility:ApplyGradient(hoverGradient, theme.AccentGradient, 90)
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.BackgroundTransparency = 1
        optionLabel.Position = UDim2.new(0, isMobile and 14 : 12, 0, 0)
        optionLabel.Size = UDim2.new(1, multiSelect and -(isMobile and 48 : 42) or -(isMobile and 14 : 12), 1, 0)
        optionLabel.Font = Enum.Font.GothamBold
        optionLabel.Text = optionName
        optionLabel.TextColor3 = theme.Text
        optionLabel.TextSize = isMobile and 13 : 12
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
        optionLabel.Parent = optionButton
        
        if multiSelect then
            -- Checkbox
            local checkbox = Instance.new("Frame")
            checkbox.BackgroundColor3 = theme.Background
            checkbox.BackgroundTransparency = 0.2
            checkbox.BorderSizePixel = 0
            checkbox.Position = UDim2.new(1, -(isMobile and 32 : 28), 0.5, 0)
            checkbox.Size = UDim2.new(0, isMobile and 22 : 20, 0, isMobile and 22 : 20)
            checkbox.AnchorPoint = Vector2.new(0, 0.5)
            checkbox.Parent = optionButton
            
            Utility:ApplyCorner(checkbox, isMobile and 6 : 5)
            Utility:ApplyStroke(checkbox, theme.Accent, 2, selectedOptions[optionName] and 0 or 0.7)
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.BackgroundTransparency = 1
            checkmark.Image = IconLibrary:Get("check")
            checkmark.ImageColor3 = theme.Accent
            checkmark.Size = UDim2.new(0.7, 0, 0.7, 0)
            checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
            checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
            checkmark.ImageTransparency = selectedOptions[optionName] and 0 or 1
            checkmark.Parent = checkbox
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOptions[optionName] = not selectedOptions[optionName]
                
                Utility:Spring(checkmark, {
                    ImageTransparency = selectedOptions[optionName] and 0 or 1,
                    Rotation = selectedOptions[optionName] and 360 or 0
                })
                
                Utility:Spring(checkbox, {
                    BackgroundColor3 = selectedOptions[optionName] and theme.Accent or theme.Background,
                    BackgroundTransparency = selectedOptions[optionName] and 0.8 : 0.2
                })
                
                local stroke = checkbox:FindFirstChildOfClass("UIStroke")
                if stroke then
                    Utility:Spring(stroke, {
                        Transparency = selectedOptions[optionName] and 0 or 0.7
                    })
                end
                
                updateSelected()
                callback(currentValue)
            end)
        else
            optionButton.MouseButton1Click:Connect(function()
                currentValue = optionName
                updateSelected()
                callback(currentValue)
                
                Utility:CreateRipple(optionButton, optionButton.AbsoluteSize.X/2, optionButton.AbsoluteSize.Y/2, theme.Accent)
                
                task.wait(0.15)
                dropdownButton.MouseButton1Click:Fire()
            end)
        end
        
        optionButton.MouseEnter:Connect(function()
            Utility:Spring(optionButton, {BackgroundTransparency = 0.1})
            Utility:Spring(hoverGradient, {BackgroundTransparency = 0.85})
            Utility:Spring(optionLabel, {TextColor3 = theme.Accent})
        end)
        
        optionButton.MouseLeave:Connect(function()
            Utility:Spring(optionButton, {BackgroundTransparency = 0.4})
            Utility:Spring(hoverGradient, {BackgroundTransparency = 1})
            Utility:Spring(optionLabel, {TextColor3 = theme.Text})
        end)
        
        return optionButton
    end
    
    for _, option in ipairs(list) do
        createOption(option)
    end
    
    -- Search functionality
    if searchable and searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = searchBox.Text:lower()
            for _, child in pairs(optionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Visible = child.Name:lower():find(query) ~= nil
                end
            end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        local targetRotation = expanded and 180 or 0
        local maxHeight = isMobile and 250 : 200
        local optionCount = #list
        local calculatedHeight = math.min(optionCount * (isMobile and 48 : 44), maxHeight)
        local targetHeight = expanded and calculatedHeight or 0
        local searchHeight = (searchable and expanded) and (isMobile and 53 : 48) or 0
        
        Utility:Spring(chevron, {Rotation = targetRotation})
        
        if searchBox then
            searchBox.Visible = expanded
        end
        
        Utility:Spring(optionsContainer, {
            Size = UDim2.new(1, 0, 0, targetHeight)
        })
        
        Utility:Spring(dropdownFrame, {
            Size = UDim2.new(1, 0, 0, (isMobile and 55 : 50) + targetHeight + searchHeight)
        })
        
        if expanded then
            Utility:CreateGlow(dropdownFrame, theme.Accent, 0.2)
        end
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
            local optBtn = optionsContainer:FindFirstChild(option)
            if optBtn then optBtn:Destroy() end
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    updateSelected()
    
    return element
end

-- ═════════════════ TEXTBOX (ENHANCED) ═════════════════
function SectionMethods:CreateTextbox(options)
    options = options or {}
    local name = options.Name or "Textbox"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local numeric = options.Numeric or false
    local multiline = options.Multiline or false
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local textboxHeight = multiline and (isMobile and 110 : 100) or (isMobile and 80 : 72)
    
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = "Textbox"
    textboxFrame.BackgroundColor3 = theme.Secondary
    textboxFrame.BackgroundTransparency = 0.2
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Size = UDim2.new(1, 0, 0, textboxHeight)
    textboxFrame.LayoutOrder = #self.Elements + 1
    textboxFrame.Parent = self.Frame
    
    Utility:ApplyCorner(textboxFrame, isMobile and 14 : 12)
    Utility:CreateShadow(textboxFrame, 0.8)
    local border = Utility:ApplyStroke(textboxFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = textboxFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    local textboxLabel = Instance.new("TextLabel")
    textboxLabel.BackgroundTransparency = 1
    textboxLabel.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 12 : 10)
    textboxLabel.Size = UDim2.new(1, -(isMobile and 30 : 24), 0, isMobile and 18 : 16)
    textboxLabel.Font = Enum.Font.GothamBold
    textboxLabel.Text = name
    textboxLabel.TextColor3 = theme.Text
    textboxLabel.TextSize = isMobile and 14 : 13
    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textboxLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textboxLabel.Parent = textboxFrame
    
    local inputContainer = Instance.new("Frame")
    inputContainer.BackgroundColor3 = theme.Tertiary
    inputContainer.BackgroundTransparency = 0.3
    inputContainer.BorderSizePixel = 0
    inputContainer.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 38 : 34)
    inputContainer.Size = UDim2.new(1, -(isMobile and 30 : 24), 1, -(isMobile and 50 : 44))
    inputContainer.Parent = textboxFrame
    
    Utility:ApplyCorner(inputContainer, isMobile and 10 : 9)
    
    local textboxInput = Instance.new("TextBox")
    textboxInput.Name = "Input"
    textboxInput.BackgroundTransparency = 1
    textboxInput.Size = UDim2.new(1, 0, 1, 0)
    textboxInput.Font = Enum.Font.GothamMedium
    textboxInput.PlaceholderText = placeholder
    textboxInput.PlaceholderColor3 = theme.TextDark
    textboxInput.Text = default
    textboxInput.TextColor3 = theme.Text
    textboxInput.TextSize = isMobile and 13 : 12
    textboxInput.TextXAlignment = Enum.TextXAlignment.Left
    textboxInput.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    textboxInput.ClearTextOnFocus = false
    textboxInput.MultiLine = multiline
    textboxInput.TextWrapped = multiline
    textboxInput.Parent = inputContainer
    
    Utility:AddPadding(textboxInput, isMobile and 12 : 10)
    
    local currentValue = default
    
    -- Character counter (if not numeric)
    local charCounter
    if not numeric then
        charCounter = Instance.new("TextLabel")
        charCounter.BackgroundTransparency = 1
        charCounter.Position = UDim2.new(1, -(isMobile and 50 : 45), 1, -(isMobile and 12 : 10))
        charCounter.Size = UDim2.new(0, isMobile and 45 : 40, 0, isMobile and 14 : 12)
        charCounter.AnchorPoint = Vector2.new(1, 1)
        charCounter.Font = Enum.Font.GothamBold
        charCounter.Text = #default
        charCounter.TextColor3 = theme.TextDark
        charCounter.TextSize = isMobile and 10 : 9
        charCounter.TextXAlignment = Enum.TextXAlignment.Right
        charCounter.Parent = inputContainer
    end
    
    textboxInput.FocusLost:Connect(function(enterPressed)
        local value = textboxInput.Text
        
        if numeric then
            value = tonumber(value) or 0
            textboxInput.Text = tostring(value)
        end
        
        currentValue = value
        callback(value, enterPressed)
        
        -- Reset border
        Utility:Spring(border, {Transparency = 0.7})
        Utility:Spring(inputContainer, {BackgroundTransparency = 0.3})
    end)
    
    textboxInput.Focused:Connect(function()
        Utility:Spring(inputContainer, {BackgroundTransparency = 0.1})
        Utility:Spring(border, {
            Color = theme.Accent,
            Transparency = 0.3
        })
        Utility:CreateGlow(textboxFrame, theme.Accent, 0.2)
    end)
    
    textboxInput:GetPropertyChangedSignal("Text"):Connect(function()
        if numeric then
            textboxInput.Text = textboxInput.Text:gsub("[^%d%.%-]", "")
        end
        
        if charCounter then
            charCounter.Text = #textboxInput.Text
            
            -- Color based on length
            local textLength = #textboxInput.Text
            if textLength > 100 then
                charCounter.TextColor3 = theme.Error
            elseif textLength > 50 then
                charCounter.TextColor3 = theme.Warning
            else
                charCounter.TextColor3 = theme.TextDark
            end
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

-- ═════════════════ COLOR PICKER (ADVANCED HSV) ═════════════════
function SectionMethods:CreateColorPicker(options)
    options = options or {}
    local name = options.Name or "Color Picker"
    local default = options.Default or Color3.fromRGB(255, 0, 0)
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "ColorPicker"
    pickerFrame.BackgroundColor3 = theme.Secondary
    pickerFrame.BackgroundTransparency = 0.2
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 : 45)
    pickerFrame.ClipsDescendants = true
    pickerFrame.LayoutOrder = #self.Elements + 1
    pickerFrame.Parent = self.Frame
    
    Utility:ApplyCorner(pickerFrame, isMobile and 14 : 12)
    Utility:CreateShadow(pickerFrame, 0.8)
    Utility:ApplyStroke(pickerFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = pickerFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    local pickerLabel = Instance.new("TextLabel")
    pickerLabel.BackgroundTransparency = 1
    pickerLabel.Position = UDim2.new(0, isMobile and 15 : 12, 0, 0)
    pickerLabel.Size = UDim2.new(1, -(isMobile and 75 : 68), 1, 0)
    pickerLabel.Font = Enum.Font.GothamBold
    pickerLabel.Text = name
    pickerLabel.TextColor3 = theme.Text
    pickerLabel.TextSize = isMobile and 14 : 13
    pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    pickerLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pickerLabel.Parent = pickerFrame
    
    -- Color Display Button
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Position = UDim2.new(1, -(isMobile and 56 : 50), 0.5, 0)
    colorDisplay.Size = UDim2.new(0, isMobile and 44 : 38, 0, isMobile and 32 : 28)
    colorDisplay.AnchorPoint = Vector2.new(0, 0.5)
    colorDisplay.Text = ""
    colorDisplay.Parent = pickerFrame
    
    Utility:ApplyCorner(colorDisplay, isMobile and 10 : 9)
    Utility:CreateShadow(colorDisplay, 0.6)
    Utility:ApplyStroke(colorDisplay, Color3.fromRGB(255, 255, 255), 2, 0.3)
    
    -- Rainbow border animation
    local rainbowBorder = colorDisplay:FindFirstChildOfClass("UIStroke")
    if rainbowBorder then
        RunService.RenderStepped:Connect(function()
            local hue = (tick() % 5) / 5
            rainbowBorder.Color = Color3.fromHSV(hue, 1, 1)
        end)
    end
    
    local currentColor = default
    local expanded = false
    
    -- Picker Canvas
    local pickerCanvas = Instance.new("Frame")
    pickerCanvas.Name = "Canvas"
    pickerCanvas.BackgroundColor3 = theme.Tertiary
    pickerCanvas.BackgroundTransparency = 0.1
    pickerCanvas.BorderSizePixel = 0
    pickerCanvas.Position = UDim2.new(0, isMobile and 15 : 12, 0, isMobile and 60 : 55)
    pickerCanvas.Size = UDim2.new(1, -(isMobile and 30 : 24), 0, 0)
    pickerCanvas.ClipsDescendants = true
    pickerCanvas.Parent = pickerFrame
    
    Utility:ApplyCorner(pickerCanvas, isMobile and 10 : 9)
    
    -- RGB Sliders
    local function createColorSlider(colorName, yPos, defaultVal)
        local colors = {
            R = Color3.fromRGB(255, 100, 100),
            G = Color3.fromRGB(100, 255, 100),
            B = Color3.fromRGB(100, 100, 255)
        }
        
        local sliderBG = Instance.new("Frame")
        sliderBG.BackgroundColor3 = theme.Background
        sliderBG.BackgroundTransparency = 0.3
        sliderBG.BorderSizePixel = 0
        sliderBG.Position = UDim2.new(0, isMobile and 12 : 10, 0, yPos)
        sliderBG.Size = UDim2.new(1, -(isMobile and 24 : 20), 0, isMobile and 36 : 32)
        sliderBG.Parent = pickerCanvas
        
        Utility:ApplyCorner(sliderBG, isMobile and 8 : 7)
        
        -- Label
        local labelBG = Instance.new("Frame")
        labelBG.BackgroundColor3 = colors[colorName]
        labelBG.BackgroundTransparency = 0.8
        labelBG.BorderSizePixel = 0
        labelBG.Size = UDim2.new(0, isMobile and 32 : 28, 1, 0)
        labelBG.Parent = sliderBG
        
        Utility:ApplyCorner(labelBG, isMobile and 8 : 7)
        
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBlack
        label.Text = colorName
        label.TextColor3 = colors[colorName]
        label.TextSize = isMobile and 14 : 13
        label.Parent = labelBG
        
        -- Track
        local track = Instance.new("Frame")
        track.BackgroundColor3 = theme.Secondary
        track.BackgroundTransparency = 0.3
        track.BorderSizePixel = 0
        track.Position = UDim2.new(0, isMobile and 40 : 36, 0.5, 0)
        track.Size = UDim2.new(1, -(isMobile and 105 : 95), 0, isMobile and 10 : 8)
        track.AnchorPoint = Vector2.new(0, 0.5)
        track.Parent = sliderBG
        
        Utility:ApplyCorner(track, isMobile and 5 : 4)
        
        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = colors[colorName]
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(defaultVal/255, 0, 1, 0)
        fill.Parent = track
        
        Utility:ApplyCorner(fill, isMobile and 5 : 4)
        
        -- Handle
        local handle = Instance.new("Frame")
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.BorderSizePixel = 0
        handle.Position = UDim2.new(1, 0, 0.5, 0)
        handle.Size = UDim2.new(0, isMobile and 18 : 16, 0, isMobile and 18 : 16)
        handle.AnchorPoint = Vector2.new(0.5, 0.5)
        handle.Parent = fill
        
        Utility:ApplyCorner(handle, isMobile and 9 : 8)
        Utility:CreateShadow(handle, 0.5)
        
        -- Value Label
        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Position = UDim2.new(1, -(isMobile and 55 : 50), 0, 0)
        valueLabel.Size = UDim2.new(0, isMobile and 50 : 45, 1, 0)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Text = tostring(math.floor(defaultVal))
        valueLabel.TextColor3 = colors[colorName]
        valueLabel.TextSize = isMobile and 13 : 12
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                updateSlider(math.clamp(pos * 255, 0, 255))
                
                Utility:Spring(handle, {
                    Size = UDim2.new(0, (isMobile and 22 : 20), 0, (isMobile and 22 : 20))
                })
            end
        end)
        
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                Utility:Spring(handle, {
                    Size = UDim2.new(0, (isMobile and 18 : 16), 0, (isMobile and 18 : 16))
                })
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch) then
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                updateSlider(math.clamp(pos * 255, 0, 255))
            end
        end)
        
        return updateSlider
    end
    
    local updateR = createColorSlider("R", isMobile and 12 : 10, default.R * 255)
    local updateG = createColorSlider("G", isMobile and 54 : 48, default.G * 255)
    local updateB = createColorSlider("B", isMobile and 96 : 86, default.B * 255)
    
    -- Hex Input
    local hexContainer = Instance.new("Frame")
    hexContainer.BackgroundColor3 = theme.Background
    hexContainer.BackgroundTransparency = 0.3
    hexContainer.BorderSizePixel = 0
    hexContainer.Position = UDim2.new(0, isMobile and 12 : 10, 0, isMobile and 144 : 130)
    hexContainer.Size = UDim2.new(1, -(isMobile and 24 : 20), 0, isMobile and 38 : 34)
    hexContainer.Parent = pickerCanvas
    
    Utility:ApplyCorner(hexContainer, isMobile and 8 : 7)
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.BackgroundTransparency = 1
    hexLabel.Position = UDim2.new(0, isMobile and 12 : 10, 0, 0)
    hexLabel.Size = UDim2.new(0, isMobile and 45 : 40, 1, 0)
    hexLabel.Font = Enum.Font.GothamBold
    hexLabel.Text = "HEX"
    hexLabel.TextColor3 = theme.Text
    hexLabel.TextSize = isMobile and 12 : 11
    hexLabel.TextXAlignment = Enum.TextXAlignment.Left
    hexLabel.Parent = hexContainer
    
    local hexInput = Instance.new("TextBox")
    hexInput.BackgroundTransparency = 1
    hexInput.Position = UDim2.new(0, isMobile and 60 : 55, 0, 0)
    hexInput.Size = UDim2.new(1, -(isMobile and 120 : 110), 1, 0)
    hexInput.Font = Enum.Font.GothamMedium
    hexInput.Text = string.format("#%02X%02X%02X", default.R * 255, default.G * 255, default.B * 255)
    hexInput.TextColor3 = theme.TextDark
    hexInput.TextSize = isMobile and 12 : 11
    hexInput.TextXAlignment = Enum.TextXAlignment.Left
    hexInput.ClearTextOnFocus = false
    hexInput.Parent = hexContainer
    
    -- Copy button
    local copyBtn = Instance.new("TextButton")
    copyBtn.BackgroundColor3 = theme.Accent
    copyBtn.BackgroundTransparency = 0.8
    copyBtn.BorderSizePixel = 0
    copyBtn.Position = UDim2.new(1, -(isMobile and 50 : 45), 0.5, 0)
    copyBtn.Size = UDim2.new(0, isMobile and 44 : 40, 0, isMobile and 26 : 24)
    copyBtn.AnchorPoint = Vector2.new(0, 0.5)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = theme.Accent
    copyBtn.TextSize = isMobile and 10 : 9
    copyBtn.Parent = hexContainer
    
    Utility:ApplyCorner(copyBtn, isMobile and 6 : 5)
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(hexInput.Text)
            NebulaX:Notify({
                Title = "Copied!",
                Description = "Color code copied to clipboard",
                Type = "Success",
                Duration = 2
            })
        end
        Utility:CreateRipple(copyBtn, copyBtn.AbsoluteSize.X/2, copyBtn.AbsoluteSize.Y/2, theme.Accent)
    end)
    
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 255
            local g = tonumber(hex:sub(3,4), 16) or 255
            local b = tonumber(hex:sub(5,6), 16) or 255
            
            updateR(r)
            updateG(g)
            updateB(b)
        end
    end)
    
    colorDisplay.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        local targetHeight = expanded and (isMobile and 195 : 175) or 0
        
        Utility:Spring(pickerCanvas, {
            Size = UDim2.new(1, -(isMobile and 30 : 24), 0, targetHeight)
        })
        
        Utility:Spring(pickerFrame, {
            Size = UDim2.new(1, 0, 0, (isMobile and 50 : 45) + targetHeight + (expanded and (isMobile and 20 : 15) or 0))
        })
        
        if expanded then
            Utility:CreateGlow(pickerFrame, currentColor, 0.3)
        end
    end)
    
    -- Update hex on color change
    local function updateHex()
        hexInput.Text = string.format("#%02X%02X%02X", 
            currentColor.R * 255, 
            currentColor.G * 255, 
            currentColor.B * 255
        )
    end
    
    local oldCallback = callback
    callback = function(color)
        updateHex()
        oldCallback(color)
    end
    
    local element = {
        Frame = pickerFrame,
        Value = currentColor,
        Set = function(self, color)
            currentColor = color
            colorDisplay.BackgroundColor3 = color
            updateR(color.R * 255)
            updateG(color.G * 255)
            updateB(color.B * 255)
            updateHex()
        end,
        Callback = callback
    }
    
    table.insert(self.Elements, element)
    self.Tab.Elements[name] = element
    
    return element
end

-- ═════════════════ KEYBIND (ENHANCED) ═════════════════
function SectionMethods:CreateKeybind(options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default or Enum.KeyCode.E
    local callback = options.Callback or function() end
    local theme = self.Tab.Window.Theme
    local isMobile = self.Tab.Window.IsMobile
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.BackgroundColor3 = theme.Secondary
    keybindFrame.BackgroundTransparency = 0.2
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 : 45)
    keybindFrame.LayoutOrder = #self.Elements + 1
    keybindFrame.Parent = self.Frame
    
    Utility:ApplyCorner(keybindFrame, isMobile and 14 : 12)
    Utility:CreateShadow(keybindFrame, 0.8)
    Utility:ApplyStroke(keybindFrame, theme.Border, 1, 0.7)
    
    -- Glass
    local glass = Instance.new("Frame")
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.96
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Parent = keybindFrame
    
    Utility:ApplyCorner(glass, isMobile and 14 : 12)
    
    -- Icon
    local iconBG = Instance.new("Frame")
    iconBG.BackgroundColor3 = theme.Accent
    iconBG.BackgroundTransparency = 0.9
    iconBG.Position = UDim2.new(0, isMobile and 15 : 12, 0.5, 0)
    iconBG.Size = UDim2.new(0, isMobile and 36 : 32, 0, isMobile and 36 : 32)
    iconBG.AnchorPoint = Vector2.new(0, 0.5)
    iconBG.Parent = keybindFrame
    
    Utility:ApplyCorner(iconBG, isMobile and 9 : 8)
    
    local keyIcon = Instance.new("ImageLabel")
    keyIcon.BackgroundTransparency = 1
    keyIcon.Image = IconLibrary:Get("cpu")
    keyIcon.ImageColor3 = theme.Accent
    keyIcon.Size = UDim2.new(0, isMobile and 20 : 18, 0, isMobile and 20 : 18)
    keyIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    keyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    keyIcon.Parent = iconBG
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Position = UDim2.new(0, isMobile and 60 : 52, 0, 0)
    keybindLabel.Size = UDim2.new(1, -(isMobile and 160 : 145), 1, 0)
    keybindLabel.Font = Enum.Font.GothamBold
    keybindLabel.Text = name
    keybindLabel.TextColor3 = theme.Text
    keybindLabel.TextSize = isMobile and 14 : 13
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.TextTruncate = Enum.TextTruncate.AtEnd
    keybindLabel.Parent = keybindFrame
    
    -- Key Button
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "KeyButton"
    keybindButton.BackgroundColor3 = theme.Tertiary
    keybindButton.BackgroundTransparency = 0.2
    keybindButton.BorderSizePixel = 0
    keybindButton.Position = UDim2.new(1, -(isMobile and 92 : 84), 0.5, 0)
    keybindButton.Size = UDim2.new(0, isMobile and 80 : 72, 0, isMobile and 32 : 28)
    keybindButton.AnchorPoint = Vector2.new(0, 0.5)
    keybindButton.Font = Enum.Font.GothamBlack
    keybindButton.Text = default.Name
    keybindButton.TextColor3 = theme.Text
    keybindButton.TextSize = isMobile and 11 : 10
    keybindButton.AutoButtonColor = false
    keybindButton.Parent = keybindFrame
    
    Utility:ApplyCorner(keybindButton, isMobile and 8 : 7)
    Utility:ApplyGradient(keybindButton, ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.Tertiary),
        ColorSequenceKeypoint.new(1, theme.Secondary)
    }, 45)
    
    local currentKey = default
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        keybindButton.Text = "..."
        
        Utility:Spring(keybindButton, {
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, (isMobile and 84 : 76), 0, (isMobile and 34 : 30))
        })
        
        Utility:CreateGlow(keybindButton, theme.Accent, 0.4)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
                listening = false
                
                Utility:Spring(keybindButton, {
                    BackgroundColor3 = theme.Tertiary,
                    BackgroundTransparency = 0.2,
                    Size = UDim2.new(0, (isMobile and 80 : 72), 0, (isMobile and 32 : 28))
                })
            end
        elseif not gameProcessed and input.KeyCode == currentKey then
            callback()
            
            -- Visual feedback
            Utility:CreateRipple(keybindButton, keybindButton.AbsoluteSize.X/2, keybindButton.AbsoluteSize.Y/2, theme.Accent)
        end
    end)
    
    keybindButton.MouseEnter:Connect(function()
        if not listening then
            Utility:Spring(keybindButton, {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, (isMobile and 84 : 76), 0, (isMobile and 34 : 30))
            })
        end
    end)
    
    keybindButton.MouseLeave:Connect(function()
        if not listening then
            Utility:Spring(keybindButton, {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, (isMobile and 80 : 72), 0, (isMobile and 32 : 28))
            })
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
-- MAIN API
-- ═══════════════════════════════════════════════════════════

function NebulaX:CreateWindow(options)
    local window = Window:Create(options)
    table.insert(self.Windows, window)
    NebulaX.IsMobileDevice = window.IsMobile
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
    print("[NebulaX v2.0] Touch optimizations enabled")
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

local startupArt = [[
╔═══════════════════════════════════════════════════════════╗
║            🌌 NEBULAX UI v2.0 AESTHETIC 🌌               ║
║                                                           ║
║  ✨ Ultra Modern Design                                  ║
║  📱 Mobile Optimized                                     ║
║  🎨 6 Beautiful Themes                                   ║
║  🚀 Smooth Animations                                    ║
║  💎 Glassmorphism Effects                                ║
║                                                           ║
║  Platform: ]] .. Utility:GetPlatform() .. string.rep(" ", 43 - #Utility:GetPlatform()) .. [[║
╚═══════════════════════════════════════════════════════════╝
]]

print(startupArt)

return NebulaX
