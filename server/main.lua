local function getFramework()
    if UnixLib and UnixLib.Core then
        return UnixLib.Core.GetFramework()
    end
    return nil
end

local function getPlayer(source)
    local fw = getFramework()
    if not fw then return nil end
    
    if fw == 'ox' then
        return exports.ox_core:GetPlayer(source)
    elseif fw == 'qbx' or fw == 'qb' then
        return exports.qbx_core:GetPlayer(source)
    elseif fw == 'esx' then
        return exports.es_extended:getPlayer(source)
    end
    return nil
end

local function getName(player, fw)
    if not player then return nil end
    if fw == 'ox' then return player.get('name') end
    if fw == 'qbx' or fw == 'qb' then return player.PlayerData.name end
    if fw == 'esx' then return player.getName() end
    return nil
end

RegisterNetEvent('unix_winch:vehicleTowed', function(plate)
    if type(plate) ~= 'string' or #plate > 8 then return end
    if not source or type(source) ~= 'number' or source == 0 then return end
    
    local fw = getFramework()
    local player = getPlayer(source)
    local name = getName(player, fw)
    
    if Config.Debug then
        print(('[Unix-Winch] Towed: %s by %s (owner: %s)'):format(plate, source, name or 'unknown'))
    end
    
    TriggerEvent('unix_winch:vehicleTowed:complete', source, name, plate)
end)

exports('IsVehicleOwned', function() return false end)

if Config.Debug then print('[Unix-Winch] Server initialized') end
