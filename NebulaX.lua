-- NebulaX UI Library
-- Versión 1.0.0
-- Compatible con múltiples ejecutores Luau

local NebulaX = {}
NebulaX.__index = NebulaX

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Módulos
local Themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/dklszdev/NebulaX-UI/refs/heads/main/Themes.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/dklszdev/NebulaX-UI/refs/heads/main/Utils.lua"))()
local Mobile = loadstring(game:HttpGet("https://raw.githubusercontent.com/dklszdev/NebulaX-UI/refs/heads/main/Mobile.lua"))()

-- Configuración global
NebulaX.Config = {
    DefaultTheme = "Dark",
    AnimationSpeed = 0.2,
    MobileBreakpoint = 600,
    EnableBlurEffects = true,
    DebugMode = false
}

-- Variables internas
NebulaX._windows = {}
NebulaX._currentWindow = nil
NebulaX._notifications = {}
NebulaX._dragConnections = {}
NebulaX._mobileOptimized = false

-- Detección de plataforma
function NebulaX.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

function NebulaX.IsDesktop()
    return UserInputService.MouseEnabled
end

function NebulaX.GetExecutor()
    -- Detección de ejecutor (compatible con múltiples)
    local executor = "Unknown"
    
    if syn and syn.request then
        executor = "Synapse"
    elseif KRNL_LOADED then
        executor = "Krnl"
    elseif secure_load then
        executor = "ScriptWare"
    elseif fluxus then
        executor = "Fluxus"
    end
    
    return executor
end

-- Sistema de temas
function NebulaX.SetTheme(themeName)
    local themeData = Themes.GetTheme(themeName)
    if not themeData then
        warn(`Tema '{themeName}' no encontrado. Usando tema por defecto.`)
        themeData = Themes.GetTheme(NebulaX.Config.DefaultTheme)
    end
    
    NebulaX.CurrentTheme = themeData
    NebulaX._applyThemeToAllWindows()
end

function NebulaX._applyThemeToAllWindows()
    for _, window in pairs(NebulaX._windows) do
        if window and window.ApplyTheme then
            window:ApplyTheme(NebulaX.CurrentTheme)
        end
    end
end

-- Optimizaciones móviles
function NebulaX.EnableTouchOptimizations()
    if not NebulaX.IsMobile() then return end
    
    NebulaX._mobileOptimized = true
    Mobile.ApplyTouchOptimizations()
end

-- Creación de ventana principal
function NebulaX:CreateWindow(config)
    local windowConfig = {
        Name = config.Name or "NebulaX Window",
        Subtitle = config.Subtitle or "",
        Size = config.Size or UDim2.new(0, 500, 0, 400),
        Position = config.Position or UDim2.new(0.5, -250, 0.5, -200),
        Theme = config.Theme or NebulaX.Config.DefaultTheme,
        AccentColor = config.AccentColor or Color3.fromRGB(0, 150, 255),
        MinSize = config.MinSize or UDim2.new(0, 300, 0, 200),
        MobileSupport = config.MobileSupport or true,
        Icon = config.Icon or "✨"
    }
    
    local newWindow = NebulaX.Window.new(windowConfig)
    table.insert(NebulaX._windows, newWindow)
    NebulaX._currentWindow = newWindow
    
    return newWindow
end

-- Sistema de notificaciones
function NebulaX:Notify(config)
    local notification = {
        Id = HttpService:GenerateGUID(false),
        Title = config.Title or "Notification",
        Message = config.Message or "",
        Duration = config.Duration or 5,
        Type = config.Type or "Info", -- Info, Success, Warning, Error
        Icon = config.Icon or "ℹ️"
    }
    
    NebulaX.NotificationManager:Show(notification)
end

-- Clase Window
NebulaX.Window = {}
NebulaX.Window.__index = NebulaX.Window

function NebulaX.Window.new(config)
    local self = setmetatable({}, NebulaX.Window)
    
    self.Config = config
    self.Tabs = {}
    self.Elements = {}
    self.IsOpen = false
    self.CurrentTab = nil
    
    self:_createUI()
    self:ApplyTheme(NebulaX.CurrentTheme or Themes.GetTheme(config.Theme))
    
    return self
end

function NebulaX.Window:_createUI()
    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NebulaXWindow"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Contenedor principal con efectos
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Config.Size
    self.MainFrame.Position = self.Config.Position
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    
    -- Efectos visuales
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.new(1, 1, 1)
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.8
    UIStroke.Parent = self.MainFrame
    
    -- Header
    self:_createHeader()
    
    -- Contenedor de contenido
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -80)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    -- Footer
    self:_createFooter()
    
    -- Sistema de arrastre
    self:_setupDrag()
    
    self.MainFrame.Parent = self.ScreenGui
    self:Toggle(true)
end

function NebulaX.Window:_createHeader()
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, 40)
    self.Header.Position = UDim2.new(0, 0, 0, 0)
    self.Header.BackgroundTransparency = 1
    self.Header.Parent = self.MainFrame
    
    -- Icono y título
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Name = "TitleContainer"
    TitleContainer.Size = UDim2.new(0.5, 0, 1, 0)
    TitleContainer.Position = UDim2.new(0, 10, 0, 0)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = self.Header
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = "IconLabel"
    IconLabel.Size = UDim2.new(0, 30, 0, 30)
    IconLabel.Position = UDim2.new(0, 0, 0.5, -15)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = self.Config.Icon
    IconLabel.TextColor3 = Color3.new(1, 1, 1)
    IconLabel.TextSize = 18
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = TitleContainer
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 35, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Config.Name
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleContainer
    
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "SubtitleLabel"
    SubtitleLabel.Size = UDim2.new(1, -40, 0, 12)
    SubtitleLabel.Position = UDim2.new(0, 35, 0, 20)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = self.Config.Subtitle
    SubtitleLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    SubtitleLabel.TextSize = 12
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TitleContainer
    
    -- Controles de ventana
    self:_createWindowControls()
end

function NebulaX.Window:_createWindowControls()
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0.5, -10, 1, 0)
    Controls.Position = UDim2.new(0.5, 10, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = self.Header
    
    -- Botones de control (minimizar, cerrar, etc.)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    CloseButton.BackgroundTransparency = 0.8
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Controls
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)
    
    -- Efectos hover
    Utils.AddHoverEffect(CloseButton, 0.8, 0.6)
end

function NebulaX.Window:_createFooter()
    self.Footer = Instance.new("Frame")
    self.Footer.Name = "Footer"
    self.Footer.Size = UDim2.new(1, 0, 0, 40)
    self.Footer.Position = UDim2.new(0, 0, 1, -40)
    self.Footer.BackgroundTransparency = 1
    self.Footer.Parent = self.MainFrame
    
    -- Información del footer
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Size = UDim2.new(1, -20, 1, 0)
    InfoLabel.Position = UDim2.new(0, 10, 0, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "NebulaX UI v1.0.0 | " .. NebulaX.GetExecutor()
    InfoLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = self.Footer
end

function NebulaX.Window:_setupDrag()
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    self.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

function NebulaX.Window:ApplyTheme(theme)
    if not theme then return end
    
    -- Aplicar tema a todos los elementos de la ventana
    self.MainFrame.BackgroundColor3 = theme.BackgroundColor
    self.MainFrame.BackgroundTransparency = theme.BackgroundTransparency
    
    -- Aplicar a header, footer, etc.
    for _, element in pairs(self.Elements) do
        if element.ApplyTheme then
            element:ApplyTheme(theme)
        end
    end
end

function NebulaX.Window:Toggle(visible)
    self.IsOpen = visible
    self.MainFrame.Visible = visible
    
    if visible then
        -- Animación de entrada
        self.MainFrame.Size = UDim2.new(0, 10, 0, 10)
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = self.Config.Size
        }):Play()
    else
        -- Animación de salida
        TweenService:Create(self.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1
        }):Play()
    end
end

function NebulaX.Window:CreateTab(config)
    local tabConfig = {
        Name = config.Name or "Nueva Pestaña",
        Icon = config.Icon or "📄"
    }
    
    local newTab = NebulaX.Tab.new(tabConfig, self)
    table.insert(self.Tabs, newTab)
    
    if not self.CurrentTab then
        self.CurrentTab = newTab
        newTab:SetActive(true)
    end
    
    return newTab
end

-- Clase Tab
NebulaX.Tab = {}
NebulaX.Tab.__index = NebulaX.Tab

function NebulaX.Tab.new(config, parentWindow)
    local self = setmetatable({}, NebulaX.Tab)
    
    self.Config = config
    self.ParentWindow = parentWindow
    self.Sections = {}
    self.IsActive = false
    
    self:_createUI()
    
    return self
end

function NebulaX.Tab:_createUI()
    -- Implementación de la UI de la pestaña
    -- (Código simplificado por longitud)
end

function NebulaX.Tab:CreateSection(config)
    local sectionConfig = {
        Name = config.Name or "Nueva Sección",
        Collapsible = config.Collapsible or true
    }
    
    local newSection = NebulaX.Section.new(sectionConfig, self)
    table.insert(self.Sections, newSection)
    
    return newSection
end

function NebulaX.Tab:SetActive(active)
    self.IsActive = active
    -- Mostrar/ocultar contenido de la pestaña
end

-- Clase Section
NebulaX.Section = {}
NebulaX.Section.__index = NebulaX.Section

function NebulaX.Section.new(config, parentTab)
    local self = setmetatable({}, NebulaX.Section)
    
    self.Config = config
    self.ParentTab = parentTab
    self.Elements = {}
    self.IsCollapsed = false
    
    self:_createUI()
    
    return self
end

function NebulaX.Section:_createUI()
    -- Implementación de la UI de la sección
end

function NebulaX.Section:CreateSlider(config)
    local sliderConfig = {
        Name = config.Name or "Slider",
        Range = config.Range or {0, 100},
        Default = config.Default or 50,
        Suffix = config.Suffix or "",
        VisualFeedback = config.VisualFeedback or true,
        Callback = config.Callback or function() end
    }
    
    local newSlider = NebulaX.Slider.new(sliderConfig, self)
    table.insert(self.Elements, newSlider)
    
    return newSlider
end

function NebulaX.Section:CreateButton(config)
    local buttonConfig = {
        Name = config.Name or "Button",
        Icon = config.Icon or "⚡",
        Callback = config.Callback or function() end
    }
    
    local newButton = NebulaX.Button.new(buttonConfig, self)
    table.insert(self.Elements, newButton)
    
    return newButton
end

function NebulaX.Section:CreateToggle(config)
    local toggleConfig = {
        Name = config.Name or "Toggle",
        Default = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    local newToggle = NebulaX.Toggle.new(toggleConfig, self)
    table.insert(self.Elements, newToggle)
    
    return newToggle
end

function NebulaX.Section:CreateDropdown(config)
    local dropdownConfig = {
        Name = config.Name or "Dropdown",
        Options = config.Options or {},
        Default = config.Default or 1,
        Searchable = config.Searchable or true,
        Callback = config.Callback or function() end
    }
    
    local newDropdown = NebulaX.Dropdown.new(dropdownConfig, self)
    table.insert(self.Elements, newDropdown)
    
    return newDropdown
end

-- Componente Slider avanzado
NebulaX.Slider = {}
NebulaX.Slider.__index = NebulaX.Slider

function NebulaX.Slider.new(config, parentSection)
    local self = setmetatable({}, NebulaX.Slider)
    
    self.Config = config
    self.ParentSection = parentSection
    self.Value = config.Default
    self.Dragging = false
    
    self:_createUI()
    self:SetValue(config.Default)
    
    return self
end

function NebulaX.Slider:_createUI()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = "SliderContainer"
    sliderContainer.Size = UDim2.new(1, -20, 0, 60)
    sliderContainer.Position = UDim2.new(0, 10, 0, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = self.ParentSection.Container
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Config.Name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderContainer
    
    -- Valor actual
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(self.Value) .. self.Config.Suffix
    valueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderContainer
    
    -- Track del slider
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    track.BorderSizePixel = 0
    track.Parent = sliderContainer
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Fill del slider
    self.Fill = Instance.new("Frame")
    self.Fill.Name = "Fill"
    self.Fill.Size = UDim2.new(0, 0, 1, 0)
    self.Fill.Position = UDim2.new(0, 0, 0, 0)
    self.Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    self.Fill.BorderSizePixel = 0
    self.Fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = self.Fill
    
    -- Thumb del slider
    self.Thumb = Instance.new("TextButton")
    self.Thumb.Name = "Thumb"
    self.Thumb.Size = UDim2.new(0, 16, 0, 16)
    self.Thumb.Position = UDim2.new(0, 0, 0.5, -8)
    self.Thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    self.Thumb.Text = ""
    self.Thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = self.Thumb
    
    -- Sistema de interacción
    self:_setupInteraction()
    
    self.Container = sliderContainer
end

function NebulaX.Slider:_setupInteraction()
    local function updateSlider(input)
        if not self.Dragging then return end
        
        local track = self.Thumb.Parent
        local trackAbsoluteSize = track.AbsoluteSize.X
        local trackAbsolutePosition = track.AbsolutePosition.X
        
        local mouseX = input.Position.X
        local relativeX = math.clamp(mouseX - trackAbsolutePosition, 0, trackAbsoluteSize)
        local percentage = relativeX / trackAbsoluteSize
        
        local minValue, maxValue = self.Config.Range[1], self.Config.Range[2]
        local newValue = math.floor(minValue + (maxValue - minValue) * percentage)
        
        self:SetValue(newValue)
        self.Config.Callback(newValue)
    end
    
    self.Thumb.MouseButton1Down:Connect(function()
        self.Dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    -- Soporte táctil
    if NebulaX.IsMobile() then
        self.Thumb.TouchTap:Connect(function()
            self.Dragging = true
        end)
    end
end

function NebulaX.Slider:SetValue(value)
    local minValue, maxValue = self.Config.Range[1], self.Config.Range[2]
    self.Value = math.clamp(value, minValue, maxValue)
    
    local percentage = (self.Value - minValue) / (maxValue - minValue)
    
    -- Actualizar UI
    self.Fill.Size = UDim2.new(percentage, 0, 1, 0)
    self.Thumb.Position = UDim2.new(percentage, -8, 0.5, -8)
    
    if self.Container:FindFirstChild("ValueLabel") then
        self.Container.ValueLabel.Text = tostring(self.Value) .. self.Config.Suffix
    end
    
    -- Feedback visual
    if self.Config.VisualFeedback then
        TweenService:Create(self.Thumb, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 20, 0, 20)
        }):Play()
        
        delay(0.1, function()
            TweenService:Create(self.Thumb, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end)
    end
end

-- Inicialización
function NebulaX.Init()
    -- Aplicar tema por defecto
    NebulaX.SetTheme(NebulaX.Config.DefaultTheme)
    
    -- Aplicar optimizaciones móviles si es necesario
    if NebulaX.IsMobile() then
        NebulaX.EnableTouchOptimizations()
    end
    
    -- Sistema de notificaciones
    NebulaX.NotificationManager = NebulaX.NotificationSystem.new()
    
    print("NebulaX UI cargado correctamente - Executor: " .. NebulaX.GetExecutor())
end

-- Ejecutar inicialización
NebulaX.Init()

return NebulaX
