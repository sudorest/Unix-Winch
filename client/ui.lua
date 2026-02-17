local UI = {}
UI.__index = UI

local KEY_NAMES = { E = 'E', SPACE = 'SPACE', CTRL = 'CTRL', G = 'G' }

function UI:Init(module)
    self.module = module
    self.rangeBlip = nil
    self.highlighted = nil
end

function UI:ShowRangeIndicator(show)
    if not Config.UI.ShowRangeIndicator then return end
    
    if show then
        self:CreateRangeIndicator()
    else
        self:DeleteRangeIndicator()
    end
end

function UI:CreateRangeIndicator()
    local pos = GetEntityCoords(PlayerPedId())
    self.rangeBlip = AddBlipForRadius(pos.x, pos.y, pos.z, Config.Winch.MaxReach)
    
    SetBlipAlpha(self.rangeBlip, Config.UI.RangeColor[4])
    SetBlipColour(self.rangeBlip, 3)
    SetBlipAsShortRange(self.rangeBlip, true)
    
    if Config.Debug then print('[Unix-Winch] Range indicator created') end
end

function UI:DeleteRangeIndicator()
    if self.rangeBlip and self.rangeBlip ~= 0 then
        RemoveBlip(self.rangeBlip)
        self.rangeBlip = nil
    end
end

function UI:ShowStatus(text)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.15, 0.85, 0.4, 0, 255, 0, 255)
end

function UI:ShowHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function UI:GetKeyName(name)
    local key = Config.Keybinds[name]
    return KEY_NAMES[key] or key or '??'
end

function UI:Tick()
    if not self.module.deployed then return end
    
    local hookKey, releaseKey, retractKey = self:GetKeyName('Hook'), self:GetKeyName('Release'), self:GetKeyName('Deploy')
    
    if self.module.hookedVehicle then
        self:ShowStatus('HOOKED')
        self:ShowHelp(('%s Hook Vehicle  %s Release'):format(hookKey, releaseKey))
    else
        self:ShowStatus('READY')
        self:ShowHelp(('%s Hook Vehicle  %s Retract Winch'):format(hookKey, retractKey))
    end
    
    self:UpdateRangePosition()
end

function UI:UpdateRangePosition()
    if not self.rangeBlip then return end
    local pos = GetEntityCoords(PlayerPedId())
    SetBlipCoords(self.rangeBlip, pos.x, pos.y, pos.z)
end

function UI:HighlightVehicle(vehicle)
    if self.highlighted and DoesEntityExist(self.highlighted) then
        SetEntityHighlight(self.highlighted, false, 0, 0, 0, 0)
    end
    
    if vehicle and DoesEntityExist(vehicle) then
        SetEntityHighlight(vehicle, true, 0, 255, 0, 255)
        self.highlighted = vehicle
    end
end

function UI:RemoveHighlight()
    if self.highlighted and DoesEntityExist(self.highlighted) then
        SetEntityHighlight(self.highlighted, false, 0, 0, 0, 0)
        self.highlighted = nil
    end
end

return UI
