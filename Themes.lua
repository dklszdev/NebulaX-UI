-- NebulaX Themes Module
local Themes = {}

Themes.Presets = {
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
        ErrorColor = Color3.fromRGB(255, 85, 85),
        BorderColor = Color3.fromRGB(60, 60, 70),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.7
    },
    
    Light = {
        Name = "Light",
        BackgroundColor = Color3.fromRGB(245, 245, 245),
        BackgroundTransparency = 0.05,
        HeaderColor = Color3.fromRGB(230, 230, 235),
        TextColor = Color3.fromRGB(30, 30, 35),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        AccentColor = Color3.fromRGB(0, 120, 215),
        SuccessColor = Color3.fromRGB(45, 200, 45),
        WarningColor = Color3.fromRGB(215, 160, 0),
        ErrorColor = Color3.fromRGB(215, 45, 45),
        BorderColor = Color3.fromRGB(200, 200, 210),
        ShadowColor = Color3.fromRGB(100, 100, 100),
        ShadowTransparency = 0.5
    },
    
    Neon = {
        Name = "Neon",
        BackgroundColor = Color3.fromRGB(15, 15, 25),
        BackgroundTransparency = 0.2,
        HeaderColor = Color3.fromRGB(20, 20, 35),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 255),
        AccentColor = Color3.fromRGB(0, 255, 255),
        SuccessColor = Color3.fromRGB(0, 255, 128),
        WarningColor = Color3.fromRGB(255, 255, 0),
        ErrorColor = Color3.fromRGB(255, 0, 128),
        BorderColor = Color3.fromRGB(80, 60, 140),
        ShadowColor = Color3.fromRGB(0, 30, 60),
        ShadowTransparency = 0.6,
        GlowEffect = true
    },
    
    Gradient = {
        Name = "Gradient",
        BackgroundColor = Color3.fromRGB(40, 40, 50),
        BackgroundTransparency = 0.1,
        HeaderColor = Color3.fromRGB(35, 35, 45),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        AccentColor = Color3.fromRGB(255, 105, 180),
        SuccessColor = Color3.fromRGB(135, 255, 66),
        WarningColor = Color3.fromRGB(255, 193, 7),
        ErrorColor = Color3.fromRGB(255, 69, 58),
        BorderColor = Color3.fromRGB(70, 65, 110),
        ShadowColor = Color3.fromRGB(20, 20, 40),
        ShadowTransparency = 0.7,
        UseGradients = true
    }
}

function Themes.GetTheme(themeName)
    return Themes.Presets[themeName] or Themes.Presets.Dark
end

function Themes.CreateCustomTheme(config)
    local customTheme = table.clone(Themes.Presets.Dark)
    
    for key, value in pairs(config) do
        if customTheme[key] ~= nil then
            if type(value) == "table" and value.R ~= nil then
                customTheme[key] = Color3.new(value.R, value.G, value.B)
            else
                customTheme[key] = value
            end
        end
    end
    
    customTheme.Name = config.Name or "Custom"
    return customTheme
end

function Themes.GetAllThemes()
    local themeNames = {}
    for name, _ in pairs(Themes.Presets) do
        table.insert(themeNames, name)
    end
    return themeNames
end

return Themes
