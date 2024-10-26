local RunService = game:GetService("RunService")
local TrajectoryLength = 100  -- Ajusta esta distancia según lo que necesites
local TrajectoryThickness = 0.1  -- Grosor de la línea de trayectoria
local CueBall = workspace:FindFirstChild("CueBall")  -- Cambia "CueBall" por el nombre exacto de la bola blanca en tu juego

-- Crear línea de trayectoria
local function drawTrajectory(startPos, endPos, color)
    -- Crear una nueva parte para la línea
    local trajectoryPart = Instance.new("Part")
    trajectoryPart.Size = Vector3.new(TrajectoryThickness, TrajectoryThickness, (startPos - endPos).Magnitude)
    trajectoryPart.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -trajectoryPart.Size.Z / 2)
    trajectoryPart.Anchored = true
    trajectoryPart.CanCollide = false
    trajectoryPart.Color = color
    trajectoryPart.Transparency = 0.3
    trajectoryPart.Name = "TrajectoryLine"
    trajectoryPart.Parent = workspace
end

-- Calcular la trayectoria de la bola blanca
local function calculateTrajectory()
    -- Asegurarse de que la bola blanca esté en la escena
    if not CueBall then
        warn("No se encontró la bola blanca en el juego.")
        return
    end

    -- Eliminar trayectorias anteriores
    for _, part in pairs(workspace:GetChildren()) do
        if part.Name == "TrajectoryLine" then
            part:Destroy()
        end
    end

    -- Dirección del rayo basado en la orientación de la bola
    local cueDirection = CueBall.CFrame.LookVector
    local rayOrigin = CueBall.Position
    local rayDirection = cueDirection * TrajectoryLength

    -- Parámetros para el raycast
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {CueBall}  -- Evitar detectar la bola blanca a sí misma
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- Ejecutar el raycast
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    -- Si el rayo colisiona con algo
    if raycastResult then
        -- Dibujar la línea de trayectoria hasta la colisión
        drawTrajectory(rayOrigin, raycastResult.Position, Color3.new(1, 1, 1))  -- Línea blanca

        -- Si la colisión es con otra bola, calcula la dirección reflejada
        if raycastResult.Instance and raycastResult.Instance:IsA("BasePart") then
            local normal = raycastResult.Normal
            local reflectedDirection = rayDirection - 2 * (rayDirection:Dot(normal)) * normal

            -- Ejecutar un segundo raycast para la dirección reflejada
            local secondRaycastResult = workspace:Raycast(raycastResult.Position, reflectedDirection.Unit * TrajectoryLength, raycastParams)

            -- Dibujar la segunda línea de trayectoria (rebote)
            if secondRaycastResult then
                drawTrajectory(raycastResult.Position, secondRaycastResult.Position, Color3.new(1, 0, 0))  -- Línea roja para rebote
            end
        end
    end
end

-- Conectar con el evento RenderStepped para actualizar la trayectoria en tiempo real
RunService.RenderStepped:Connect(function()
    calculateTrajectory()
end)
