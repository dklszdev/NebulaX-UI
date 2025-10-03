--[[
    NebulaX UI Library v1.0
    Premium UI Library for Roblox Executors
    Compatible with: Synapse X, Krnl, ScriptWare, Fluxus, etc.
]]

local NebulaX = {}
NebulaX.__index = NebulaX
NebulaX.Version = "1.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Variables globales
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Utilidades básicas
local Utils = {
    Tween = function(obj, props, duration, style, direction)
        local info = TweenInfo.new(
            duration or 0.3,
            Enum.EasingStyle[style or "Quint"],
            Enum.EasingDirection[direction or "Out"]
        )
        local tween = TweenService:Create(obj, info, props)
        tween:Play()
        return tween
    end,
    
    IsMobile = function()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end,
    
    CreateGradient = function(colorStart, colorEnd)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorStart),
            ColorSequenceKeypoint.new(1, colorEnd)
        })
        gradient.Rotation = 45
        return gradient
    end,
    
    Ripple = function(button, x, y)
        local circle = Instance.new("ImageLabel")
        circle.Name = "Ripple"
        circle.Parent = button
        circle.BackgroundTransparency = 1
        circle.ZIndex = 10
        circle.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        circle.ImageColor3 = Color3.new(1, 1, 1)
        circle.ImageTransparency = 0.5
        
        circle.Position = UDim2.new(0, x, 0, y)
        circle.Size = UDim2.new(0, 0, 0, 0)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        
        Utils.Tween(circle, {
            Size = UDim2.new(0, size, 0, size),
            ImageTransparency = 1
        }, 0.5, "Linear", "Out")
        
        task.delay(0.5, function()
            circle:Destroy()
        end)
    end
}

-- Temas predefinidos
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Tertiary = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 55),
        Success = Color3.fromRGB(50, 200, 100),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(235, 235, 240),
        Tertiary = Color3.fromRGB(225, 225, 230),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(20, 20, 25),
        TextDark = Color3.fromRGB(100, 100, 105),
        Border = Color3.fromRGB(200, 200, 205),
        Success = Color3.fromRGB(40, 180, 90),
        Warning = Color3.fromRGB(255, 180, 40),
        Error = Color3.fromRGB(255, 70, 70)
    },
    Neon = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(20, 20, 30),
        Tertiary = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(255, 0, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 200, 255),
        Border = Color3.fromRGB(100, 0, 200),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 100)
    }
}

-- Iconos Material Design
local Icons = {
    home = "rbxassetid://3926305904",
    settings = "rbxassetid://3926307971",
    user = "rbxassetid://3926305904",
    search = "rbxassetid://3926305904",
    check = "rbxassetid://3926305904",
    close = "rbxassetid://3926307971"
}

-- Crear instancia principal de NebulaX
function NebulaX.new(config)
    local self = setmetatable({}, NebulaX)
    
    self.Config = config or {}
    self.Windows = {}
    self.Notifications = {}
    self.IsMobileDevice = Utils.IsMobile()
    
    -- Crear contenedor principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NebulaXUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    -- Protección contra detección
    if gethui then
        self.ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    else
        self.ScreenGui.Parent = CoreGui
    end
    
    return self
end

-- Crear ventana
function NebulaX:CreateWindow(config)
    local Window = {
        Name = config.Name or "NebulaX UI",
        Subtitle = config.Subtitle or "Premium UI Library",
        Theme = Themes[config.Theme or "Dark"],
        AccentColor = config.AccentColor or Color3.fromRGB(0, 150, 255),
        MobileSupport = config.MobileSupport ~= false,
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = self.IsMobileDevice and UDim2.new(0.95, 0, 0.85, 0) or UDim2.new(0, 600, 0, 450)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Window.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = self.ScreenGui
    MainFrame.Active = true
    MainFrame.Draggable = not self.IsMobileDevice
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Window.Theme.Secondary
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header
    
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 12)
    HeaderFix.Position = UDim2.new(0, 0, 1, -12)
    HeaderFix.BackgroundColor3 = Window.Theme.Secondary
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Parent = Header
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = Window.Name
    Title.TextColor3 = Window.Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -100, 0.4, 0)
    Subtitle.Position = UDim2.new(0, 15, 0.6, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = Window.Subtitle
    Subtitle.TextColor3 = Window.Theme.TextDark
    Subtitle.TextSize = 12
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    -- Botón cerrar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0, 5)
    CloseBtn.BackgroundColor3 = Window.Theme.Tertiary
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Window.Theme.Text
    CloseBtn.TextSize = 24
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        Utils.Ripple(CloseBtn, CloseBtn.AbsoluteSize.X/2, CloseBtn.AbsoluteSize.Y/2)
        Utils.Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, "Back", "In")
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Contenedor de pestañas
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -100)
    TabContainer.Position = UDim2.new(0, 10, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    -- Contenedor de contenido
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -180, 1, -110)
    ContentContainer.Position = UDim2.new(0, 170, 0, 60)
    ContentContainer.BackgroundColor3 = Window.Theme.Secondary
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = ContentContainer
    
    -- Footer
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 30)
    Footer.Position = UDim2.new(0, 0, 1, -30)
    Footer.BackgroundColor3 = Window.Theme.Secondary
    Footer.BorderSizePixel = 0
    Footer.Parent = MainFrame
    
    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 12)
    FooterCorner.Parent = Footer
    
    local FooterFix = Instance.new("Frame")
    FooterFix.Size = UDim2.new(1, 0, 0, 12)
    FooterFix.BackgroundColor3 = Window.Theme.Secondary
    FooterFix.BorderSizePixel = 0
    FooterFix.Parent = Footer
    
    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, -20, 1, 0)
    FooterText.Position = UDim2.new(0, 10, 0, 0)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = "NebulaX UI v" .. NebulaX.Version .. " | " .. (self.IsMobileDevice and "📱 Mobile" or "🖥️ Desktop")
    FooterText.TextColor3 = Window.Theme.TextDark
    FooterText.TextSize = 11
    FooterText.Font = Enum.Font.Gotham
    FooterText.TextXAlignment = Enum.TextXAlignment.Left
    FooterText.Parent = Footer
    
    -- Animación de entrada
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Utils.Tween(MainFrame, {Size = self.IsMobileDevice and UDim2.new(0.95, 0, 0.85, 0) or UDim2.new(0, 600, 0, 450)}, 0.4, "Back", "Out")
    
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentContainer = ContentContainer
    
    -- Función para crear pestañas
    function Window:CreateTab(tabConfig)
        local Tab = {
            Name = tabConfig.Name or "Tab",
            Icon = tabConfig.Icon or "home",
            Sections = {},
            IsActive = false
        }
        
        -- Botón de pestaña
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = Window.Theme.Tertiary
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -15, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = Tab.Name
        TabLabel.TextColor3 = Window.Theme.TextDark
        TabLabel.TextSize = 14
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Contenido de la pestaña
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = Tab.Name .. "Content"
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Window.AccentColor
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 8)
        ContentList.Parent = TabContent
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Función de activación
        local function ActivateTab()
            for _, t in pairs(Window.Tabs) do
                t.IsActive = false
                t.Content.Visible = false
                Utils.Tween(t.Button, {BackgroundColor3 = Window.Theme.Tertiary}, 0.2)
                local label = t.Button:FindFirstChildOfClass("TextLabel")
                if label then
                    Utils.Tween(label, {TextColor3 = Window.Theme.TextDark}, 0.2)
                end
            end
            
            Tab.IsActive = true
            Tab.Content.Visible = true
            Utils.Tween(TabButton, {BackgroundColor3 = Window.AccentColor}, 0.2)
            Utils.Tween(TabLabel, {TextColor3 = Window.Theme.Text}, 0.2)
            Window.CurrentTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Utils.Ripple(TabButton, TabButton.AbsoluteSize.X/2, TabButton.AbsoluteSize.Y/2)
            ActivateTab()
        end)
        
        -- Activar primera pestaña
        if #Window.Tabs == 0 then
            ActivateTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Función para crear sección
        function Tab:CreateSection(name)
            local Section = {
                Name = name or "Section",
                Elements = {}
            }
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = Section.Name
            SectionFrame.Size = UDim2.new(1, 0, 0, 35)
            SectionFrame.BackgroundColor3 = Window.Theme.Tertiary
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = SectionFrame
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = Section.Name
            SectionLabel.TextColor3 = Window.Theme.Text
            SectionLabel.TextSize = 15
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionFrame
            
            local ElementContainer = Instance.new("Frame")
            ElementContainer.Name = "Elements"
            ElementContainer.Size = UDim2.new(1, 0, 0, 0)
            ElementContainer.Position = UDim2.new(0, 0, 0, 35)
            ElementContainer.BackgroundTransparency = 1
            ElementContainer.Parent = SectionFrame
            
            local ElementList = Instance.new("UIListLayout")
            ElementList.SortOrder = Enum.SortOrder.LayoutOrder
            ElementList.Padding = UDim.new(0, 5)
            ElementList.Parent = ElementContainer
            
            ElementList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ElementContainer.Size = UDim2.new(1, 0, 0, ElementList.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, 35 + ElementList.AbsoluteContentSize.Y + 5)
            end)
            
            Section.Frame = SectionFrame
            Section.Container = ElementContainer
            
            -- BUTTON
            function Section:CreateButton(config)
                local btnConfig = config or {}
                local Button = Instance.new("TextButton")
                Button.Name = btnConfig.Name or "Button"
                Button.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 50 or 40)
                Button.BackgroundColor3 = Window.Theme.Background
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = ElementContainer
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Button
                
                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, -20, 1, 0)
                BtnLabel.Position = UDim2.new(0, 10, 0, 0)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = btnConfig.Name or "Button"
                BtnLabel.TextColor3 = Window.Theme.Text
                BtnLabel.TextSize = 13
                BtnLabel.Font = Enum.Font.Gotham
                BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
                BtnLabel.Parent = Button
                
                Button.MouseButton1Click:Connect(function()
                    Utils.Ripple(Button, Mouse.X - Button.AbsolutePosition.X, Mouse.Y - Button.AbsolutePosition.Y)
                    if btnConfig.Callback then
                        btnConfig.Callback()
                    end
                end)
                
                Button.MouseEnter:Connect(function()
                    Utils.Tween(Button, {BackgroundColor3 = Window.AccentColor}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Utils.Tween(Button, {BackgroundColor3 = Window.Theme.Background}, 0.2)
                end)
                
                return Button
            end
            
            -- TOGGLE
            function Section:CreateToggle(config)
                local togConfig = config or {}
                local Toggle = {
                    Value = togConfig.Default or false
                }
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = togConfig.Name or "Toggle"
                ToggleFrame.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 50 or 40)
                ToggleFrame.BackgroundColor3 = Window.Theme.Background
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = ElementContainer
                
                local TogCorner = Instance.new("UICorner")
                TogCorner.CornerRadius = UDim.new(0, 6)
                TogCorner.Parent = ToggleFrame
                
                local TogLabel = Instance.new("TextLabel")
                TogLabel.Size = UDim2.new(1, -70, 1, 0)
                TogLabel.Position = UDim2.new(0, 10, 0, 0)
                TogLabel.BackgroundTransparency = 1
                TogLabel.Text = togConfig.Name or "Toggle"
                TogLabel.TextColor3 = Window.Theme.Text
                TogLabel.TextSize = 13
                TogLabel.Font = Enum.Font.Gotham
                TogLabel.TextXAlignment = Enum.TextXAlignment.Left
                TogLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 45, 0, 22)
                ToggleButton.Position = UDim2.new(1, -55, 0.5, -11)
                ToggleButton.BackgroundColor3 = Toggle.Value and Window.AccentColor or Window.Theme.Tertiary
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                local TogBtnCorner = Instance.new("UICorner")
                TogBtnCorner.CornerRadius = UDim.new(1, 0)
                TogBtnCorner.Parent = ToggleButton
                
                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 18, 0, 18)
                Indicator.Position = Toggle.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
                Indicator.BorderSizePixel = 0
                Indicator.Parent = ToggleButton
                
                local IndCorner = Instance.new("UICorner")
                IndCorner.CornerRadius = UDim.new(1, 0)
                IndCorner.Parent = Indicator
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    Utils.Tween(ToggleButton, {BackgroundColor3 = value and Window.AccentColor or Window.Theme.Tertiary}, 0.2)
                    Utils.Tween(Indicator, {Position = value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2, "Back")
                    
                    if togConfig.Callback then
                        togConfig.Callback(value)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle:Set(not Toggle.Value)
                end)
                
                return Toggle
            end
            
            -- SLIDER
            function Section:CreateSlider(config)
                local sldConfig = config or {}
                local Slider = {
                    Value = sldConfig.Default or sldConfig.Range[1],
                    Min = sldConfig.Range[1],
                    Max = sldConfig.Range[2]
                }
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = sldConfig.Name or "Slider"
                SliderFrame.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 60 or 50)
                SliderFrame.BackgroundColor3 = Window.Theme.Background
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = ElementContainer
                
                local SldCorner = Instance.new("UICorner")
                SldCorner.CornerRadius = UDim.new(0, 6)
                SldCorner.Parent = SliderFrame
                
                local SldLabel = Instance.new("TextLabel")
                SldLabel.Size = UDim2.new(0.6, 0, 0, 20)
                SldLabel.Position = UDim2.new(0, 10, 0, 5)
                SldLabel.BackgroundTransparency = 1
                SldLabel.Text = sldConfig.Name or "Slider"
                SldLabel.TextColor3 = Window.Theme.Text
                SldLabel.TextSize = 13
                SldLabel.Font = Enum.Font.Gotham
                SldLabel.TextXAlignment = Enum.TextXAlignment.Left
                SldLabel.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
                ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Slider.Value) .. (sldConfig.Suffix or "")
                ValueLabel.TextColor3 = Window.AccentColor
                ValueLabel.TextSize = 13
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -20, 0, 6)
                SliderBar.Position = UDim2.new(0, 10, 1, -15)
                SliderBar.BackgroundColor3 = Window.Theme.Tertiary
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                
                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.BackgroundColor3 = Window.AccentColor
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(1, -20, 0, 6)
                SliderButton.Position = UDim2.new(0, 10, 1, -15)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderFrame
                
                function Slider:Set(value)
                    Slider.Value = math.clamp(value, Slider.Min, Slider.Max)
                    local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                    
                    Utils.Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    ValueLabel.Text = tostring(math.floor(Slider.Value)) .. (sldConfig.Suffix or "")
                    
                    if sldConfig.Callback then
                        sldConfig.Callback(Slider.Value)
                    end
                end
                
                local dragging = false
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                SliderButton.MouseButton1Click:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    local value = Slider.Min + (Slider.Max - Slider.Min) * percent
                    Slider:Set(value)
                end)
                
                RunService.RenderStepped:Connect(function()
                    if dragging then
                        local mousePos = UserInputService:GetMouseLocation().X
                        local barPos = SliderBar.AbsolutePosition.X
                        local barSize = SliderBar.AbsoluteSize.X
                        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                        local value = Slider.Min + (Slider.Max - Slider.Min) * percent
                        Slider:Set(value)
                    end
                end)
                
                Slider:Set(Slider.Value)
                return Slider
            end
            
            -- DROPDOWN
            function Section:CreateDropdown(config)
                local ddConfig = config or {}
                local Dropdown = {
                    Value = ddConfig.Default or ddConfig.Options[1],
                    Options = ddConfig.Options or {},
                    IsOpen = false
                }
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = ddConfig.Name or "Dropdown"
                DropdownFrame.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 50 or 40)
                DropdownFrame.BackgroundColor3 = Window.Theme.Background
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Parent = ElementContainer
                DropdownFrame.ClipsDescendants = true
                
                local DdCorner = Instance.new("UICorner")
                DdCorner.CornerRadius = UDim.new(0, 6)
                DdCorner.Parent = DropdownFrame
                
                local DdButton = Instance.new("TextButton")
                DdButton.Size = UDim2.new(1, 0, 0, self.IsMobileDevice and 50 or 40)
                DdButton.BackgroundTransparency = 1
                DdButton.Text = ""
                DdButton.Parent = DropdownFrame
                
                local DdLabel = Instance.new("TextLabel")
                DdLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DdLabel.Position = UDim2.new(0, 10, 0, 0)
                DdLabel.BackgroundTransparency = 1
                DdLabel.Text = ddConfig.Name or "Dropdown"
                DdLabel.TextColor3 = Window.Theme.Text
                DdLabel.TextSize = 13
                DdLabel.Font = Enum.Font.Gotham
                DdLabel.TextXAlignment = Enum.TextXAlignment.Left
                DdLabel.Parent = DdButton
                
                local DdValue = Instance.new("TextLabel")
                DdValue.Size = UDim2.new(0.5, -30, 1, 0)
                DdValue.Position = UDim2.new(0.5, 0, 0, 0)
                DdValue.BackgroundTransparency = 1
                DdValue.Text = Dropdown.Value
                DdValue.TextColor3 = Window.AccentColor
                DdValue.TextSize = 12
                DdValue.Font = Enum.Font.GothamMedium
                DdValue.TextXAlignment = Enum.TextXAlignment.Right
                DdValue.Parent = DdButton
                
                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Position = UDim2.new(1, -25, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "▼"
                Arrow.TextColor3 = Window.Theme.TextDark
                Arrow.TextSize = 10
                Arrow.Font = Enum.Font.Gotham
                Arrow.Parent = DdButton
                
                local OptionsList = Instance.new("Frame")
                OptionsList.Name = "Options"
                OptionsList.Size = UDim2.new(1, 0, 0, 0)
                OptionsList.Position = UDim2.new(0, 0, 0, self.IsMobileDevice and 50 or 40)
                OptionsList.BackgroundTransparency = 1
                OptionsList.Parent = DropdownFrame
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Padding = UDim.new(0, 2)
                OptionsLayout.Parent = OptionsList
                
                function Dropdown:Refresh()
                    for _, child in pairs(OptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, option in ipairs(Dropdown.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, -10, 0, 30)
                        OptionButton.BackgroundColor3 = Window.Theme.Tertiary
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Window.Theme.Text
                        OptionButton.TextSize = 12
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.AutoButtonColor = false
                        OptionButton.Parent = OptionsList
                        
                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 4)
                        OptCorner.Parent = OptionButton
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = option
                            DdValue.Text = option
                            Dropdown:Toggle()
                            
                            if ddConfig.Callback then
                                ddConfig.Callback(option)
                            end
                        end)
                        
                        OptionButton.MouseEnter:Connect(function()
                            Utils.Tween(OptionButton, {BackgroundColor3 = Window.AccentColor}, 0.1)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Utils.Tween(OptionButton, {BackgroundColor3 = Window.Theme.Tertiary}, 0.1)
                        end)
                    end
                end
                
                function Dropdown:Toggle()
                    Dropdown.IsOpen = not Dropdown.IsOpen
                    
                    if Dropdown.IsOpen then
                        local optionsHeight = #Dropdown.Options * 32
                        Utils.Tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, (self.IsMobileDevice and 50 or 40) + optionsHeight + 5)}, 0.2)
                        Utils.Tween(Arrow, {Rotation = 180}, 0.2)
                    else
                        Utils.Tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 50 or 40)}, 0.2)
                        Utils.Tween(Arrow, {Rotation = 0}, 0.2)
                    end
                end
                
                DdButton.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                Dropdown:Refresh()
                return Dropdown
            end
            
            -- TEXTBOX
            function Section:CreateTextbox(config)
                local tbConfig = config or {}
                local Textbox = {
                    Value = tbConfig.Default or ""
                }
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = tbConfig.Name or "Textbox"
                TextboxFrame.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 70 or 60)
                TextboxFrame.BackgroundColor3 = Window.Theme.Background
                TextboxFrame.BorderSizePixel = 0
                TextboxFrame.Parent = ElementContainer
                
                local TbCorner = Instance.new("UICorner")
                TbCorner.CornerRadius = UDim.new(0, 6)
                TbCorner.Parent = TextboxFrame
                
                local TbLabel = Instance.new("TextLabel")
                TbLabel.Size = UDim2.new(1, -20, 0, 20)
                TbLabel.Position = UDim2.new(0, 10, 0, 5)
                TbLabel.BackgroundTransparency = 1
                TbLabel.Text = tbConfig.Name or "Textbox"
                TbLabel.TextColor3 = Window.Theme.Text
                TbLabel.TextSize = 13
                TbLabel.Font = Enum.Font.Gotham
                TbLabel.TextXAlignment = Enum.TextXAlignment.Left
                TbLabel.Parent = TextboxFrame
                
                local TbInput = Instance.new("TextBox")
                TbInput.Size = UDim2.new(1, -20, 0, 28)
                TbInput.Position = UDim2.new(0, 10, 1, -33)
                TbInput.BackgroundColor3 = Window.Theme.Tertiary
                TbInput.BorderSizePixel = 0
                TbInput.Text = Textbox.Value
                TbInput.PlaceholderText = tbConfig.Placeholder or "Enter text..."
                TbInput.PlaceholderColor3 = Window.Theme.TextDark
                TbInput.TextColor3 = Window.Theme.Text
                TbInput.TextSize = 12
                TbInput.Font = Enum.Font.Gotham
                TbInput.ClearTextOnFocus = false
                TbInput.Parent = TextboxFrame
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = TbInput
                
                local InputPadding = Instance.new("UIPadding")
                InputPadding.PaddingLeft = UDim.new(0, 8)
                InputPadding.PaddingRight = UDim.new(0, 8)
                InputPadding.Parent = TbInput
                
                TbInput.FocusLost:Connect(function(enterPressed)
                    Textbox.Value = TbInput.Text
                    if tbConfig.Callback then
                        tbConfig.Callback(TbInput.Text)
                    end
                end)
                
                TbInput.Focused:Connect(function()
                    Utils.Tween(TbInput, {BackgroundColor3 = Window.AccentColor}, 0.2)
                end)
                
                TbInput.FocusLost:Connect(function()
                    Utils.Tween(TbInput, {BackgroundColor3 = Window.Theme.Tertiary}, 0.2)
                end)
                
                return Textbox
            end
            
            -- LABEL
            function Section:CreateLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 0, 30)
                Label.BackgroundColor3 = Window.Theme.Background
                Label.BorderSizePixel = 0
                Label.Text = text or "Label"
                Label.TextColor3 = Window.Theme.TextDark
                Label.TextSize = 12
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.Parent = ElementContainer
                
                local LblCorner = Instance.new("UICorner")
                LblCorner.CornerRadius = UDim.new(0, 6)
                LblCorner.Parent = Label
                
                local LblPadding = Instance.new("UIPadding")
                LblPadding.PaddingLeft = UDim.new(0, 10)
                LblPadding.PaddingRight = UDim.new(0, 10)
                LblPadding.Parent = Label
                
                return Label
            end
            
            -- COLOR PICKER
            function Section:CreateColorPicker(config)
                local cpConfig = config or {}
                local ColorPicker = {
                    Value = cpConfig.Default or Color3.fromRGB(255, 255, 255)
                }
                
                local CPFrame = Instance.new("Frame")
                CPFrame.Name = cpConfig.Name or "ColorPicker"
                CPFrame.Size = UDim2.new(1, -20, 0, self.IsMobileDevice and 50 or 40)
                CPFrame.BackgroundColor3 = Window.Theme.Background
                CPFrame.BorderSizePixel = 0
                CPFrame.Parent = ElementContainer
                
                local CPCorner = Instance.new("UICorner")
                CPCorner.CornerRadius = UDim.new(0, 6)
                CPCorner.Parent = CPFrame
                
                local CPLabel = Instance.new("TextLabel")
                CPLabel.Size = UDim2.new(0.7, 0, 1, 0)
                CPLabel.Position = UDim2.new(0, 10, 0, 0)
                CPLabel.BackgroundTransparency = 1
                CPLabel.Text = cpConfig.Name or "Color Picker"
                CPLabel.TextColor3 = Window.Theme.Text
                CPLabel.TextSize = 13
                CPLabel.Font = Enum.Font.Gotham
                CPLabel.TextXAlignment = Enum.TextXAlignment.Left
                CPLabel.Parent = CPFrame
                
                local ColorPreview = Instance.new("Frame")
                ColorPreview.Size = UDim2.new(0, 60, 0, 25)
                ColorPreview.Position = UDim2.new(1, -70, 0.5, -12.5)
                ColorPreview.BackgroundColor3 = ColorPicker.Value
                ColorPreview.BorderSizePixel = 0
                ColorPreview.Parent = CPFrame
                
                local PreviewCorner = Instance.new("UICorner")
                PreviewCorner.CornerRadius = UDim.new(0, 4)
                PreviewCorner.Parent = ColorPreview
                
                local ColorButton = Instance.new("TextButton")
                ColorButton.Size = UDim2.new(0, 60, 0, 25)
                ColorButton.Position = UDim2.new(1, -70, 0.5, -12.5)
                ColorButton.BackgroundTransparency = 1
                ColorButton.Text = ""
                ColorButton.Parent = CPFrame
                
                function ColorPicker:Set(color)
                    ColorPicker.Value = color
                    ColorPreview.BackgroundColor3 = color
                    
                    if cpConfig.Callback then
                        cpConfig.Callback(color)
                    end
                end
                
                ColorButton.MouseButton1Click:Connect(function()
                    -- Aquí iría la implementación del picker completo
                    -- Por simplicidad, cicla entre colores predefinidos
                    local colors = {
                        Color3.fromRGB(255, 0, 0),
                        Color3.fromRGB(0, 255, 0),
                        Color3.fromRGB(0, 0, 255),
                        Color3.fromRGB(255, 255, 0),
                        Color3.fromRGB(255, 0, 255),
                        Color3.fromRGB(0, 255, 255),
                        Color3.fromRGB(255, 255, 255)
                    }
                    
                    local currentIndex = 1
                    for i, c in ipairs(colors) do
                        if c == ColorPicker.Value then
                            currentIndex = i
                            break
                        end
                    end
                    
                    local nextColor = colors[(currentIndex % #colors) + 1]
                    ColorPicker:Set(nextColor)
                end)
                
                return ColorPicker
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        return Tab
    end
    
    table.insert(self.Windows, Window)
    return Window
end

-- Función de notificaciones
function NebulaX:Notify(config)
    local notifConfig = config or {}
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifFrame.Position = UDim2.new(1, 320, 0, 20 + (#self.Notifications * 90))
    NotifFrame.BackgroundColor3 = Themes.Dark.Secondary
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = self.ScreenGui
    NotifFrame.ZIndex = 100
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotifFrame
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 25)
    NotifTitle.Position = UDim2.new(0, 10, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = notifConfig.Title or "Notification"
    NotifTitle.TextColor3 = Themes.Dark.Text
    NotifTitle.TextSize = 14
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotifFrame
    
    local NotifDesc = Instance.new("TextLabel")
    NotifDesc.Size = UDim2.new(1, -20, 0, 40)
    NotifDesc.Position = UDim2.new(0, 10, 0, 35)
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = notifConfig.Description or "Description"
    NotifDesc.TextColor3 = Themes.Dark.TextDark
    NotifDesc.TextSize = 12
    NotifDesc.Font = Enum.Font.Gotham
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left
    NotifDesc.TextWrapped = true
    NotifDesc.Parent = NotifFrame
    
    -- Animación de entrada
    Utils.Tween(NotifFrame, {Position = UDim2.new(1, -310, 0, 20 + (#self.Notifications * 90))}, 0.4, "Back", "Out")
    
    table.insert(self.Notifications, NotifFrame)
    
    -- Auto-cerrar
    task.delay(notifConfig.Duration or 5, function()
        Utils.Tween(NotifFrame, {Position = UDim2.new(1, 320, 0, NotifFrame.Position.Y.Offset)}, 0.3, "Back", "In")
        task.wait(0.3)
        NotifFrame:Destroy()
        
        for i, notif in ipairs(self.Notifications) do
            if notif == NotifFrame then
                table.remove(self.Notifications, i)
                break
            end
        end
    end)
end

-- Función de carga
function NebulaX:Init()
    return self
end

return NebulaX.new()
