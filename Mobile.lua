-- NebulaX Mobile Module
local Mobile = {}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

Mobile.IsMobile = UserInputService.TouchEnabled
Mobile.TouchGestures = {}
Mobile.OptimizedElements = {}

-- Configuración móvil
Mobile.Config = {
    TouchButtonSize = UDim2.new(0, 60, 0, 60),
    TouchPadding = 10,
    SwipeThreshold = 50,
    LongPressDuration = 0.5,
    DoubleTapInterval = 0.3
}

function Mobile.ApplyTouchOptimizations()
    if not Mobile.IsMobile then return end
    
    -- Aumentar tamaño de botones para touch
    for _, element in pairs(Mobile.OptimizedElements) do
        if element:IsA("TextButton") or element:IsA("ImageButton") then
            element.Size = Mobile.Config.TouchButtonSize
        end
    end
    
    -- Ajustar espaciado
    GuiService:SetGlobalGuiInset(
        Mobile.Config.TouchPadding,
        Mobile.Config.TouchPadding,
        Mobile.Config.TouchPadding,
        Mobile.Config.TouchPadding
    )
end

-- Gestos táctiles
function Mobile.AddSwipeGesture(object, callback)
    if not Mobile.IsMobile then return end
    
    local touchStart = nil
    local touchStartTime = 0
    
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = input.Position
            touchStartTime = os.clock()
        end
    end)
    
    object.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and touchStart then
            local touchEnd = input.Position
            local delta = touchEnd - touchStart
            local duration = os.clock() - touchStartTime
            
            -- Detectar dirección del swipe
            if delta.Magnitude > Mobile.Config.SwipeThreshold then
                local direction = "Unknown"
                
                if math.abs(delta.X) > math.abs(delta.Y) then
                    direction = delta.X > 0 and "Right" or "Left"
                else
                    direction = delta.Y > 0 and "Down" or "Up"
                end
                
                callback(direction, delta, duration)
            end
        end
    end)
end

function Mobile.AddLongPress(object, callback)
    if not Mobile.IsMobile then return end
    
    local pressStart = 0
    local pressActive = false
    
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            pressStart = os.clock()
            pressActive = true
            
            task.delay(Mobile.Config.LongPressDuration, function()
                if pressActive then
                    callback()
                    pressActive = false
                end
            end)
        end
    end)
    
    object.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            pressActive = false
        end
    end)
end

-- Detección de orientación
function Mobile.GetOrientation()
    local camera = workspace.CurrentCamera
    if not camera then return "Portrait" end
    
    local viewportSize = camera.ViewportSize
    return viewportSize.X > viewportSize.Y and "Landscape" or "Portrait"
end

-- Optimización de rendimiento para móvil
function Mobile.EnablePerformanceMode()
    if not Mobile.IsMobile then return end
    
    -- Reducir calidad de gráficos
    settings().Rendering.QualityLevel = 1
    
    -- Limitar FPS para ahorro de batería
    if setfpscap then
        setfpscap(30)
    end
end

-- Sistema de vibración (si está disponible)
function Mobile.Vibrate(duration)
    if not Mobile.IsMobile then return end
    
    -- Intentar usar la API de vibración si está disponible
    local success = pcall(function()
        if UserInputService.Vibrate then
            UserInputService:Vibrate(duration or 100)
        end
    end)
end

return Mobile
