local UnixWinch = {}
UnixWinch.__index = UnixWinch

local lib = exports.ox_lib
local Winch, Physics, UI

function UnixWinch:Init()
    self.deployed = false
    self.hookedVehicle = nil
    self.winchEntity = nil
    self.ropeEntity = nil
    self.isLifting = false
    self.liftHeight = 0.0
    
    Winch = require('client.winch')
    Physics = require('client.physics')
    UI = require('client.ui')
    
    Winch:Init(self)
    Physics:Init(self)
    Physics:SetWinchModule(Winch)
    UI:Init(self)
    
    self:RegisterExports()
    self:RegisterEvents()
    
    if Config.Debug then
        print('[Unix-Winch] Initialized')
    end
end

function UnixWinch:RegisterExports()
    exports('HasWinch', function() return self.deployed end)
    exports('IsVehicleHooked', function(vehicle) return self.hookedVehicle == vehicle end)
    exports('GetHookedVehicle', function() return self.hookedVehicle end)
    exports('DeployWinch', function() self:Deploy() end)
    exports('UnhookVehicle', function() self:Release() end)
end

function UnixWinch:RegisterEvents()
    RegisterNetEvent('unix_winch:deploy', function() self:Deploy() end)
    RegisterNetEvent('unix_winch:retract', function() self:Retract() end)
    RegisterNetEvent('unix_winch:hook', function(vehicleNetId)
        if type(vehicleNetId) ~= 'number' then return end
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if vehicle and DoesEntityExist(vehicle) then
            self:HookVehicle(vehicle)
        end
    end)
    RegisterNetEvent('unix_winch:release', function() self:Release() end)
end

function UnixWinch:Deploy()
    if self.deployed then return end
    
    if Config.Item.Required then
        if not lib:hasItem(Config.Item.Required, 1, false) then
            if UnixLib and UnixLib.Notifications then
                UnixLib.Notifications:Error(lib.locale('missing_winch_kit'))
            end
            return
        end
    end
    
    self.deployed = true
    self.winchEntity = Winch:Create()
    
    if Config.UI.ShowRangeIndicator then
        UI:ShowRangeIndicator(true)
    end
    
    TriggerEvent('unix_winch:deployed')
    
    if UnixLib and UnixLib.Notifications then
        UnixLib.Notifications:Success(lib.locale('winch_deployed'))
    end
    
    if Config.Debug then print('[Unix-Winch] Deployed') end
end

function UnixWinch:Retract()
    if not self.deployed then return end
    
    if self.hookedVehicle then
        self:Release()
    end
    
    if self.winchEntity then
        Winch:Delete(self.winchEntity)
        self.winchEntity = nil
    end
    
    self.deployed = false
    
    if Config.UI.ShowRangeIndicator then
        UI:ShowRangeIndicator(false)
    end
    
    TriggerEvent('unix_winch:retracted')
    
    if UnixLib and UnixLib.Notifications then
        UnixLib.Notifications:Info(lib.locale('winch_retracted'))
    end
    
    if Config.Debug then print('[Unix-Winch] Retracted') end
end

function UnixWinch:HookVehicle(vehicle)
    if not self.deployed then return end
    if not vehicle or not DoesEntityExist(vehicle) then
        if UnixLib and UnixLib.Notifications then
            UnixLib.Notifications:Error(lib.locale('no_vehicle_found'))
        end
        return
    end
    
    if self.hookedVehicle then
        if UnixLib and UnixLib.Notifications then
            UnixLib.Notifications:Warning(lib.locale('already_hooked'))
        end
        return
    end
    
    local playerPos = GetEntityCoords(PlayerPedId())
    local vehiclePos = GetEntityCoords(vehicle)
    local distance = #(playerPos - vehiclePos)
    
    if distance > Config.Winch.MaxReach then
        if UnixLib and UnixLib.Notifications then
            UnixLib.Notifications:Warning(lib.locale('vehicle_too_far'))
        end
        return
    end
    
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    if Config.Vehicle.AllowedVehicles and not Config.Vehicle.AllowedVehicles[modelName] then
        if UnixLib and UnixLib.Notifications then
            UnixLib.Notifications:Error(lib.locale('cannot_hook_vehicle'))
        end
        return
    end
    
    for _, blacklisted in ipairs(Config.Vehicle.BlacklistedVehicles) do
        if modelName == blacklisted then
            if UnixLib and UnixLib.Notifications then
                UnixLib.Notifications:Error(lib.locale('cannot_hook_vehicle'))
            end
            return
        end
    end
    
    if Winch:StartHookSequence(vehicle) then
        self.hookedVehicle = vehicle
        self.isLifting = true
        self.liftHeight = 0.0
        self.ropeEntity = Winch:CreateRope(self.winchEntity, vehicle)
        
        Physics:AttachVehicle(vehicle)
        TriggerEvent('unix_winch:hooked', vehicle)
        
        if UnixLib and UnixLib.Notifications then
            UnixLib.Notifications:Success(lib.locale('vehicle_hooked'))
        end
        
        if Config.Debug then print('[Unix-Winch] Vehicle hooked') end
    end
end

function UnixWinch:Release()
    if not self.hookedVehicle then return end
    
    local vehicle = self.hookedVehicle
    
    Physics:DetachVehicle(vehicle)
    
    if self.ropeEntity then
        Winch:DeleteRope(self.ropeEntity)
        self.ropeEntity = nil
    end
    
    self.hookedVehicle = nil
    self.isLifting = false
    self.liftHeight = 0.0
    
    TriggerEvent('unix_winch:released', vehicle)
    
    if UnixLib and UnixLib.Notifications then
        UnixLib.Notifications:Info(lib.locale('vehicle_released'))
    end
    
    if Config.Debug then print('[Unix-Winch] Vehicle released') end
end

function UnixWinch:Tick()
    if not self.deployed then return end
    
    Winch:Tick()
    UI:Tick()
    
    if self.hookedVehicle then
        Physics:Tick()
    end
end

CreateThread(function()
    local timeout = 0
    while not UnixLib do
        Wait(100)
        timeout = timeout + 100
        if timeout > Config.Winch.StartTimeout then
            print('[Unix-Winch] Timeout waiting for UnixLib')
            break
        end
    end
    
    UnixWinch:Init()
    
    while true do
        Wait(Config.Winch.TickInterval)
        UnixWinch:Tick()
    end
end)

return UnixWinch
