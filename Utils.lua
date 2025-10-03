-- NebulaX Utilities Module
local Utils = {}
local TweenService = game:GetService("TweenService")

-- Manejo de errores
function Utils.SafeCall(callback, ...)
    local success, result = pcall(callback, ...)
    if not success then
        warn("NebulaX Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Animaciones
function Utils.Tween(object, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, properties)
    
    tween:Play()
    return tween
end

-- Efectos hover
function Utils.AddHoverEffect(button, normalTransparency, hoverTransparency)
    local background = button:FindFirstChildOfClass("UIGradient") or button
    
    button.MouseEnter:Connect(function()
        Utils.Tween(background, {BackgroundTransparency = hoverTransparency or 0.6}, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Utils.Tween(background, {BackgroundTransparency = normalTransparency or 0.8}, 0.1)
    end)
end

-- Validación de entrada
function Utils.ValidateNumber(input, min, max)
    local number = tonumber(input)
    if not number then return false end
    return number >= min and number <= max
end

function Utils.ValidateText(input, minLength, maxLength)
    return string.len(input) >= minLength and string.len(input) <= maxLength
end

-- Formato de texto
function Utils.FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

-- Detección de colores
function Utils.IsDarkColor(color)
    local brightness = (color.R * 299 + color.G * 587 + color.B * 114) / 1000
    return brightness < 0.5
end

-- Sistema de debounce
Utils.DebounceTable = {}
function Utils.Debounce(key, callback, delay)
    delay = delay or 0.1
    
    if Utils.DebounceTable[key] then
        Utils.DebounceTable[key]:Disconnect()
    end
    
    Utils.DebounceTable[key] = task.delay(delay, function()
        Utils.DebounceTable[key] = nil
        callback()
    end)
end

-- Conversión de colores
function Utils.Color3ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255)
    )
end

function Utils.HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

-- Deep copy de tablas
function Utils.DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = Utils.DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Round numbers
function Utils.Round(number, decimalPlaces)
    decimalPlaces = decimalPlaces or 0
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end

return Utils
