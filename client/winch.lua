local Winch = {}
Winch.__index = Winch

local CONTROL_KEYS = {
    E = 51,
    SPACE = 22,
    CTRL = 36,
    G = 47,
}

function Winch:Init(module)
    self.module = module
    self.lastHighlighted = nil
end

function Winch:Create()
    local playerPed = PlayerPedId()
    local spawnPos = GetEntityCoords(playerPed) + vector3(0, 0, -1)
    
    local winch = CreateObject("prop_winch_01", spawnPos, true, true, false)
    SetEntityHeading(winch, GetEntityHeading(playerPed))
    FreezeEntityPosition(winch, true)
    
    if Config.Debug then print('[Unix-Winch] Created winch:', winch) end
    
    return winch
end

function Winch:Delete(winch)
    if winch and DoesEntityExist(winch) then
        DeleteEntity(winch)
    end
end

function Winch:CreateRope(winch, vehicle)
    if not winch or not vehicle then return false end
    
    local winchPos, vehiclePos = GetEntityCoords(winch), GetEntityCoords(vehicle)
    local midPoint = (winchPos + vehiclePos) / 2
    local rope = CreateObject("h4_p_cs_rope05x", midPoint, true, true, false)
    
    if rope then
        SetEntityCollision(rope, false, true)
        SetEntityAsMissionEntity(rope, true, true)
        
        local distance = #(winchPos - vehiclePos)
        SetEntityScale(rope, 1, distance / 2, 1)
        SetEntityHeading(rope, GetHeadingFromVector_2d(vehiclePos.x - winchPos.x, vehiclePos.y - winchPos.y))
        
        if Config.Debug then print('[Unix-Winch] Rope created:', rope, distance) end
    end
    
    return rope
end

function Winch:UpdateRope(rope, winch, vehicle)
    if not rope or not DoesEntityExist(rope) then return end
    if not winch or not DoesEntityExist(winch) or not vehicle or not DoesEntityExist(vehicle) then return end
    
    local winchPos, vehiclePos = GetEntityCoords(winch), GetEntityCoords(vehicle)
    local midPoint = (winchPos + vehiclePos) / 2
    local distance = #(winchPos - vehiclePos)
    
    SetEntityCoords(rope, midPoint.x, midPoint.y, midPoint.z, false, false, false, false)
    SetEntityScale(rope, 1, distance / 2, 1)
    SetEntityHeading(rope, GetHeadingFromVector_2d(vehiclePos.x - winchPos.x, vehiclePos.y - winchPos.y))
end

function Winch:DeleteRope(rope)
    if rope and DoesEntityExist(rope) then
        DeleteEntity(rope)
    end
end

function Winch:StartHookSequence(vehicle)
    if UnixLib and UnixLib.ProgressBar then
        return UnixLib.ProgressBar:Progress({
            duration = Config.Winch.HookDuration,
            label = 'Attaching winch...',
            useWhileDead = false,
            canCancel = true,
        })
    else
        Wait(Config.Winch.HookDuration)
        return true
    end
end

function Winch:GetNearestVehicle()
    local playerPos = GetEntityCoords(PlayerPedId())
    local vehicles = GetGamePool('CVehicle')
    local nearestVehicle, nearestDistance = nil, Config.Winch.MaxReach
    
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
            local distance = #(playerPos - GetEntityCoords(vehicle))
            if distance < nearestDistance then
                nearestDistance = distance
                nearestVehicle = vehicle
            end
        end
    end
    
    return nearestVehicle, nearestDistance
end

function Winch:HighlightVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    if self.lastHighlighted and self.lastHighlighted ~= vehicle then
        self:RemoveHighlight(self.lastHighlighted)
    end
    
    SetEntityAsMissionEntity(vehicle, true, true)
    
    local r, g, b, a = table.unpack(Config.UI.HighlightColor or {0, 255, 0, 255})
    SetEntityHighlight(vehicle, true, r, g, b, a)
    
    self.lastHighlighted = vehicle
end

function Winch:RemoveHighlight(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        SetEntityHighlight(vehicle, false, 0, 0, 0, 0)
    end
end

function Winch:GetControl(key)
    return CONTROL_KEYS[Config.Keybinds[key]] or 51
end

function Winch:Tick()
    if not self.module.deployed then return end
    
    local nearestVehicle = self:GetNearestVehicle()
    
    if nearestVehicle then
        self:HighlightVehicle(nearestVehicle)
        
        if IsControlJustPressed(0, self:GetControl('Hook')) then
            self.module:HookVehicle(nearestVehicle)
        end
    else
        if self.lastHighlighted then
            self:RemoveHighlight(self.lastHighlighted)
            self.lastHighlighted = nil
        end
    end
    
    if self.module.hookedVehicle then
        local raise, lower, release = self:GetControl('Raise'), self:GetControl('Lower'), self:GetControl('Release')
        
        if IsControlPressed(0, raise) then
            Physics:AdjustHeight(self.module.hookedVehicle, Config.Winch.LiftSpeed * 0.01)
        elseif IsControlPressed(0, lower) then
            Physics:AdjustHeight(self.module.hookedVehicle, -Config.Winch.LowerSpeed * 0.01)
        end
        
        if IsControlJustPressed(0, release) then
            self.module:Release()
        end
    else
        if IsControlJustPressed(0, self:GetControl('Deploy')) then
            self.module:Deploy()
        end
    end
end

return Winch
