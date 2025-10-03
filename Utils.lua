--[[
    NebulaX UI - Utils Module
    Utilidades avanzadas para la librería
]]

local Utils = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ==========================================
-- ANIMACIONES Y TWEENING
-- ==========================================

function Utils.Tween(obj, props, duration, style, direction, callback)
    local info = TweenInfo.new(
        duration or 0.3,
        Enum.EasingStyle[style or "Quint"],
        Enum.EasingDirection[direction or "Out"]
    )
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

function Utils.Spring(obj, props, dampingRatio, frequency)
    local info = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

function Utils.Ripple(button, x, y, color)
    local circle = Instance.new("ImageLabel")
    circle.Name = "Ripple"
    circle.Parent = button
    circle.BackgroundTransparency = 1
    circle.ZIndex = 10
    circle.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    circle.ImageColor3 = color or Color3.new(1, 1, 1)
    circle.ImageTransparency = 0.5
    
    circle.Position = UDim2.new(0, x, 0, y)
    circle.Size = UDim2.new(0, 0, 0, 0)
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    
    Utils.Tween(circle, {
        Size = UDim2.new(0, size, 0, size),
        ImageTransparency = 1
    }, 0.6, "Linear", "Out", function()
        circle:Destroy()
    end)
end

function Utils.Shake(obj, intensity, duration)
    local originalPos = obj.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if tick() - startTime >= (duration or 0.5) then
            obj.Position = originalPos
            connection:Disconnect()
            return
        end
        
        local shake = intensity or 5
        local offsetX = math.random(-shake, shake)
        local offsetY = math.random(-shake, shake)
        
        obj.Position = originalPos + UDim2.new(0, offsetX, 0, offsetY)
    end)
end

function Utils.Pulse(obj, scale, duration)
    local originalSize = obj.Size
    
    Utils.Tween(obj, {
        Size = originalSize * (scale or 1.1)
    }, (duration or 0.2) / 2, "Quad", "Out")
    
    task.delay((duration or 0.2) / 2, function()
        Utils.Tween(obj, {
            Size = originalSize
        }, (duration or 0.2) / 2, "Quad", "In")
    end)
end

-- ==========================================
-- DETECCIÓN DE PLATAFORMA
-- ==========================================

function Utils.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils.IsConsole()
    return UserInputService.GamepadEnabled
end

function Utils.GetPlatform()
    if Utils.IsMobile() then
        return "Mobile"
    elseif Utils.IsConsole() then
        return "Console"
    else
        return "Desktop"
    end
end

-- ==========================================
-- COLORES Y GRADIENTES
-- ==========================================

function Utils.CreateGradient(colorStart, colorEnd, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorStart),
        ColorSequenceKeypoint.new(1, colorEnd)
    })
    gradient.Rotation = rotation or 45
    return gradient
end

function Utils.LerpColor(color1, color2, alpha)
    return Color3.new(
        color1.R + (color2.R - color1.R) * alpha,
        color1.G + (color2.G - color1.G) * alpha,
        color1.B + (color2.B - color1.B) * alpha
    )
end

function Utils.RGBToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utils.HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

function Utils.GetContrastColor(color)
    local luminance = (0.299 * color.R + 0.587 * color.G + 0.114 * color.B)
    return luminance > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
end

-- ==========================================
-- CONFIGURACIÓN Y ALMACENAMIENTO
-- ==========================================

function Utils.SaveConfig(name, data)
    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(data)
        writefile(name .. ".json", encoded)
    end)
    return success, err
end

function Utils.LoadConfig(name)
    local success, result = pcall(function()
        if isfile(name .. ".json") then
            local content = readfile(name .. ".json")
            return HttpService:JSONDecode(content)
        end
        return nil
    end)
    
    if success then
        return result
    else
        return nil, result
    end
end

function Utils.DeleteConfig(name)
    local success, err = pcall(function()
        if isfile(name .. ".json") then
            delfile(name .. ".json")
        end
    end)
    return success, err
end

function Utils.ListConfigs()
    local configs = {}
    local success, files = pcall(function()
        return listfiles(".")
    end)
    
    if success then
        for _, file in ipairs(files) do
            if file:match("%.json$") then
                table.insert(configs, file:match("([^/\\]+)%.json$"))
            end
        end
    end
    
    return configs
end

-- ==========================================
-- STRINGS Y FORMATEO
-- ==========================================

function Utils.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

function Utils.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function Utils.Truncate(str, maxLength)
    if #str <= maxLength then
        return str
    else
        return str:sub(1, maxLength - 3) .. "..."
    end
end

function Utils.Capitalize(str)
    return str:gsub("^%l", string.upper)
end

function Utils.CamelToTitle(str)
    return str:gsub("(%l)(%u)", "%1 %2"):gsub("^%l", string.upper)
end

-- ==========================================
-- MATEMÁTICAS Y UTILIDADES
-- ==========================================

function Utils.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.RandomColor()
    return Color3.fromRGB(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

function Utils.Distance(point1, point2)
    return (point1 - point2).Magnitude
end

-- ==========================================
-- DRAG Y DROP
-- ==========================================

function Utils.MakeDraggable(frame, dragHandle)
    local dragToggle = nil
    local dragSpeed = 0
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        Utils.Tween(frame, {Position = position}, 0.1, "Linear")
    end
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- ==========================================
-- VALIDACIÓN
-- ==========================================

function Utils.IsValidNumber(str)
    return tonumber(str) ~= nil
end

function Utils.IsValidColor(color)
    return typeof(color) == "Color3"
end

function Utils.IsValidVector(vec)
    return typeof(vec) == "Vector3" or typeof(vec) == "Vector2"
end

function Utils.Sanitize(str)
    return str:gsub("[^%w%s%-_]", "")
end

-- ==========================================
-- PERFORMANCE Y OPTIMIZACIÓN
-- ==========================================

function Utils.Debounce(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            func(...)
        end
    end
end

function Utils.Throttle(func, limit)
    local lastRun = 0
    local timeout
    
    return function(...)
        local now = tick()
        if now - lastRun >= limit then
            lastRun = now
            func(...)
        else
            if timeout then
                timeout:Disconnect()
            end
            timeout = task.delay(limit - (now - lastRun), function()
                lastRun = tick()
                func(...)
            end)
        end
    end
end

function Utils.Memoize(func)
    local cache = {}
    return function(...)
        local key = table.concat({...}, "_")
        if cache[key] == nil then
            cache[key] = func(...)
        end
        return cache[key]
    end
end

-- ==========================================
-- NOTIFICACIONES Y SONIDOS
-- ==========================================

function Utils.PlaySound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or 0.5
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    return sound
end

-- IDs de sonidos comunes
Utils.Sounds = {
    Click = 421058925,
    Hover = 421058925,
    Success = 6026984224,
    Error = 5043539486,
    Notification = 4590662766
}

-- ==========================================
-- DETECCIÓN DE EJECUTOR
-- ==========================================

function Utils.GetExecutor()
    if identifyexecutor then
        return identifyexecutor()
    elseif KRNL_LOADED then
        return "Krnl"
    elseif syn then
        return "Synapse X"
    elseif SCRIPT_WARE_LOADED then
        return "Script-Ware"
    elseif fluxus then
        return "Fluxus"
    else
        return "Unknown"
    end
end

function Utils.HasFunction(funcName)
    return _G[funcName] ~= nil or getgenv()[funcName] ~= nil
end

-- ==========================================
-- CLIPBOARD
-- ==========================================

function Utils.SetClipboard(text)
    if setclipboard then
        setclipboard(tostring(text))
        return true
    end
    return false
end

function Utils.GetClipboard()
    if getclipboard then
        return getclipboard()
    end
    return nil
end

-- ==========================================
-- INSTANCIA Y UI
-- ==========================================

function Utils.FindFirstChild(parent, name, recursive)
    if recursive then
        return parent:FindFirstChild(name, true)
    else
        return parent:FindFirstChild(name)
    end
end

function Utils.GetChildren(parent, className)
    local children = {}
    for _, child in ipairs(parent:GetChildren()) do
        if not className or child:IsA(className) then
            table.insert(children, child)
        end
    end
    return children
end

function Utils.DestroyChildren(parent, className)
    for _, child in ipairs(parent:GetChildren()) do
        if not className or child:IsA(className) then
            child:Destroy()
        end
    end
end

function Utils.CloneInstance(instance, parent)
    local clone = instance:Clone()
    if parent then
        clone.Parent = parent
    end
    return clone
end

-- ==========================================
-- MATH AVANZADO
-- ==========================================

function Utils.Map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function Utils.Normalize(value, min, max)
    return (value - min) / (max - min)
end

function Utils.SmoothStep(edge0, edge1, x)
    local t = Utils.Clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

-- ==========================================
-- TABLAS Y ARRAYS
-- ==========================================

function Utils.TableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function Utils.TableCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Utils.TableCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            Utils.TableMerge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

function Utils.TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function Utils.TableFind(tbl, predicate)
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            return v, k
        end
    end
    return nil
end

function Utils.TableFilter(tbl, predicate)
    local filtered = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

function Utils.TableMap(tbl, callback)
    local mapped = {}
    for k, v in pairs(tbl) do
        mapped[k] = callback(v, k)
    end
    return mapped
end

-- ==========================================
-- LOGGING Y DEBUG
-- ==========================================

Utils.DebugMode = false

function Utils.Log(message, level)
    if not Utils.DebugMode then return end
    
    local prefix = {
        info = "[INFO]",
        warn = "[WARN]",
        error = "[ERROR]",
        debug = "[DEBUG]"
    }
    
    local color = {
        info = "\27[32m",    -- Verde
        warn = "\27[33m",    -- Amarillo
        error = "\27[31m",   -- Rojo
        debug = "\27[36m"    -- Cyan
    }
    
    local reset = "\27[0m"
    local levelStr = level or "info"
    
    print(color[levelStr] .. prefix[levelStr] .. " " .. tostring(message) .. reset)
end

function Utils.Benchmark(name, func)
    local start = tick()
    local result = func()
    local elapsed = tick() - start
    
    Utils.Log(string.format("%s took %.4f seconds", name, elapsed), "debug")
    return result, elapsed
end

-- ==========================================
-- PROTECCIÓN Y SEGURIDAD
-- ==========================================

function Utils.ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

function Utils.IsProtected()
    return (syn and syn.protect_gui ~= nil) or gethui ~= nil
end

-- ==========================================
-- EXPORTAR MÓDULO
-- ==========================================

return Utils
