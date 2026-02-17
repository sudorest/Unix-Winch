local Physics = {}
Physics.__index = Physics

function Physics:Init(module)
    self.module = module
    self.attached = {}
    self.Winch = nil
    self.threshold = Config.Towing.SyncThreshold
end

function Physics:SetWinchModule(winch)
    self.Winch = winch
end

function Physics:AttachVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return false end
    
    self.attached[vehicle] = { heightOffset = 0, targetHeight = 2 }
    FreezeEntityPosition(vehicle, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if playerVehicle and playerVehicle ~= 0 then
        SetEntityAsMissionEntity(playerVehicle, true, true)
    end
    
    if Config.Debug then print('[Unix-Winch] Attached:', vehicle) end
    return true
end

function Physics:DetachVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    self.attached[vehicle] = nil
    FreezeEntityPosition(vehicle, false)
    SetEntityAsMissionEntity(vehicle, false, true)
    
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate and plate ~= '' then
        TriggerServerEvent('unix_winch:vehicleTowed', plate)
    end
    
    if Config.Debug then print('[Unix-Winch] Detached:', vehicle) end
end

function Physics:Tick()
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not playerVehicle or playerVehicle == 0 then return end
    
    local speed = GetEntitySpeed(playerVehicle)
    if speed > Config.Towing.TowMaxSpeed then
        SetVehicleForwardSpeed(playerVehicle, Config.Towing.TowMaxSpeed)
    end
    
    local vehiclesToRemove = {}
    for vehicle, data in pairs(self.attached) do
        if DoesEntityExist(vehicle) then
            self:UpdateVehicle(vehicle, playerVehicle, data)
            
            if self.Winch and self.module.ropeEntity then
                self.Winch:UpdateRope(self.module.ropeEntity, self.module.winchEntity, vehicle)
            end
        else
            table.insert(vehiclesToRemove, vehicle)
        end
    end
    
    for _, vehicle in ipairs(vehiclesToRemove) do
        self.attached[vehicle] = nil
    end
end

function Physics:UpdateVehicle(vehicle, towVehicle, data)
    local towPos = GetEntityCoords(towVehicle)
    local vehiclePos = GetEntityCoords(vehicle)
    local forward = GetEntityForwardVector(towVehicle)
    local targetPos = towPos + (forward * -Config.Towing.FollowDistance) + vector3(0, 0, data.heightOffset)
    
    local distance = #(vehiclePos - targetPos)
    
    if distance > self.threshold then
        local direction = targetPos - vehiclePos
        local newPos = vehiclePos + (direction * Config.Towing.SmoothFactor)
        SetEntityCoords(vehicle, newPos.x, newPos.y, newPos.z, false, false, false, false)
    end
    
    SetEntityHeading(vehicle, GetEntityHeading(towVehicle))
    SetEntityVelocity(vehicle, 0, 0, 0)
    FreezeEntityPosition(vehicle, true)
end

function Physics:AdjustHeight(vehicle, delta)
    if not self.attached[vehicle] then return end
    local data = self.attached[vehicle]
    data.heightOffset = math.max(0, math.min(Config.Winch.MaxHeight, data.heightOffset + delta))
end

return Physics
