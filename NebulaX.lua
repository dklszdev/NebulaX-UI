-- NebulaX UI - Versión Autocontenida Corregida
local NebulaX = {}
NebulaX.__index = NebulaX

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Módulos integrados (sin dependencias externas)
local Themes = {
    Dark = {
        Name = "Dark",
        BackgroundColor = Color3.fromRGB(30, 30, 35),
        BackgroundTransparency = 0.1,
        HeaderColor = Color3.fromRGB(25, 25, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        AccentColor = Color3.fromRGB(0, 150, 255),
        SuccessColor = Color3.fromRGB(85, 255, 85),
        WarningColor = Color3.fromRGB(255, 255, 85),
        ErrorColor = Color3.fromRGB(255, 85, 85)
    }
}

local Utils = {
    SafeCall = function(callback, ...)
        local success, result = pcall(callback, ...)
        if not success then
            warn("NebulaX Error: " .. tostring(result))
            return nil
        end
        return result
    end,
    
    AddHoverEffect = function(button, normalTransparency, hoverTransparency)
        local background = button
        button.MouseEnter:Connect(function()
            TweenService:Create(background, TweenInfo.new(0.1), {
                BackgroundTransparency = hoverTransparency or 0.6
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(background, TweenInfo.new(0.1), {
                BackgroundTransparency = normalTransparency or 0.8
            }):Play()
        end)
    end
}

-- Configuración
NebulaX.Config = {
    DefaultTheme = "Dark",
    AnimationSpeed = 0.2,
    MobileBreakpoint = 600
}

-- Variables internas
NebulaX._windows = {}
NebulaX._currentWindow = nil

-- Detección de plataforma
function NebulaX.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Sistema de temas
function NebulaX.SetTheme(themeName)
    local themeData = Themes[themeName] or Themes.Dark
    NebulaX.CurrentTheme = themeData
    return true
end

-- Clase Window CORREGIDA
local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass.new(config)
    local self = setmetatable({}, WindowClass)
    
    self.Config = config or {}
    self.Tabs = {}
    self.Elements = {}
    self.IsOpen = false
    
    self:_createUI()
    return self
end

function WindowClass:_createUI()
    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NebulaXWindow"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999
    
    -- Frame principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Config.Size or UDim2.new(0, 500, 0, 400)
    self.MainFrame.Position = self.Config.Position or UDim2.new(0.5, -250, 0.5, -200)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    
    -- Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    -- Header
    self:_createHeader()
    
    -- Contenido
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -80)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    self.MainFrame.Parent = self.ScreenGui
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self:Toggle(true)
    return self
end

function WindowClass:_createHeader()
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, 40)
    self.Header.Position = UDim2.new(0, 0, 0, 0)
    self.Header.BackgroundTransparency = 1
    self.Header.Parent = self.MainFrame
    
    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Config.Name or "NebulaX UI"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = self.Header
    
    -- Botón cerrar
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
    CloseButton.Parent = self.Header
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)
    
    Utils.AddHoverEffect(CloseButton, 0.8, 0.6)
end

function WindowClass:Toggle(visible)
    self.IsOpen = visible
    self.MainFrame.Visible = visible
end

function WindowClass:CreateTab(config)
    local tabConfig = {
        Name = config.Name or "Nueva Pestaña",
        Icon = config.Icon or "📄"
    }
    
    local newTab = {
        Config = tabConfig,
        ParentWindow = self,
        Sections = {},
        CreateSection = function(tab, sectionConfig)
            return tab:CreateSection(sectionConfig)
        end
    }
    
    -- Implementación simple de sección
    function newTab:CreateSection(sectionConfig)
        local section = {
            Config = sectionConfig or {},
            Elements = {},
            CreateButton = function(section, buttonConfig)
                return section:CreateButton(buttonConfig)
            end,
            CreateSlider = function(section, sliderConfig)
                return section:CreateSlider(sliderConfig)
            end,
            CreateToggle = function(section, toggleConfig)
                return section:CreateToggle(toggleConfig)
            end
        }
        
        -- Implementación de CreateButton
        function section:CreateButton(buttonConfig)
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Size = UDim2.new(1, -20, 0, 35)
            button.Position = UDim2.new(0, 10, 0, #self.Elements * 45 + 10)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            button.BackgroundTransparency = 0.2
            button.Text = buttonConfig.Name or "Button"
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.Parent = self.ParentWindow.ContentContainer
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                Utils.SafeCall(buttonConfig.Callback)
            end)
            
            Utils.AddHoverEffect(button, 0.2, 0.1)
            
            local element = {
                Instance = button,
                Config = buttonConfig
            }
            
            table.insert(self.Elements, element)
            return element
        end
        
        -- Implementación de CreateSlider (simplificada)
        function section:CreateSlider(sliderConfig)
            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = "SliderContainer"
            sliderContainer.Size = UDim2.new(1, -20, 0, 60)
            sliderContainer.Position = UDim2.new(0, 10, 0, #self.Elements * 70 + 10)
            sliderContainer.BackgroundTransparency = 1
            sliderContainer.Parent = self.ParentWindow.ContentContainer
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = sliderConfig.Name or "Slider"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderContainer
            
            -- Track
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
            
            -- Fill
            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new(0.5, 0, 1, 0)
            fill.Position = UDim2.new(0, 0, 0, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            fill.BorderSizePixel = 0
            fill.Parent = track
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill
            
            local element = {
                Instance = sliderContainer,
                Config = sliderConfig,
                SetValue = function(self, value)
                    -- Implementación simplificada
                    local percentage = (value - sliderConfig.Range[1]) / (sliderConfig.Range[2] - sliderConfig.Range[1])
                    fill.Size = UDim2.new(percentage, 0, 1, 0)
                end
            }
            
            -- Valor inicial
            element:SetValue(sliderConfig.Default or sliderConfig.Range[1])
            
            table.insert(self.Elements, element)
            return element
        end
        
        -- Implementación de CreateToggle (simplificada)
        function section:CreateToggle(toggleConfig)
            local toggleContainer = Instance.new("Frame")
            toggleContainer.Name = "ToggleContainer"
            toggleContainer.Size = UDim2.new(1, -20, 0, 35)
            toggleContainer.Position = UDim2.new(0, 10, 0, #self.Elements * 45 + 10)
            toggleContainer.BackgroundTransparency = 1
            toggleContainer.Parent = self.ParentWindow.ContentContainer
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = toggleConfig.Name or "Toggle"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleContainer
            
            -- Toggle button
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            toggleButton.Text = ""
            toggleButton.Parent = toggleContainer
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(1, 0)
            toggleCorner.Parent = toggleButton
            
            local state = toggleConfig.Default or false
            
            local function updateToggle()
                if state then
                    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    toggleButton.Position = UDim2.new(1, -25, 0.5, -10)
                else
                    toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
                    toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
                end
            end
            
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                Utils.SafeCall(toggleConfig.Callback, state)
            end)
            
            updateToggle()
            
            local element = {
                Instance = toggleContainer,
                Config = toggleConfig,
                SetState = function(self, newState)
                    state = newState
                    updateToggle()
                end
            }
            
            table.insert(self.Elements, element)
            return element
        end
        
        table.insert(self.Sections, section)
        return section
    end
    
    table.insert(self.Tabs, newTab)
    return newTab
end

-- Función principal corregida
function NebulaX:CreateWindow(config)
    local windowConfig = {
        Name = config.Name or "NebulaX Window",
        Subtitle = config.Subtitle or "",
        Size = config.Size or UDim2.new(0, 500, 0, 400),
        Position = config.Position or UDim2.new(0.5, -250, 0.5, -200),
        Theme = config.Theme or "Dark",
        AccentColor = config.AccentColor or Color3.fromRGB(0, 150, 255)
    }
    
    local newWindow = WindowClass.new(windowConfig)
    table.insert(NebulaX._windows, newWindow)
    NebulaX._currentWindow = newWindow
    
    return newWindow
end

-- Sistema de notificaciones simple
function NebulaX:Notify(config)
    Utils.SafeCall(function()
        warn(string.format("[%s] %s: %s", 
            config.Type or "INFO", 
            config.Title or "Notification", 
            config.Message or ""))
    end)
end

-- Inicialización segura
function NebulaX.Init()
    NebulaX.SetTheme("Dark")
    print("NebulaX UI Autocontenido cargado correctamente")
    return true
end

-- Inicializar
NebulaX.Init()

return NebulaX
