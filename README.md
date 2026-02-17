# Unix-Winch

A vehicle winch system for FiveM that allows players to deploy a winch, hook nearby vehicles, and lift/lower them.

## Features

- **Deployable Winch** - Deploy a winch near your vehicle with a keybind
- **Vehicle Hooking** - Hook vehicles within range using E key
- **Lift/Lower Control** - Raise or lower hooked vehicles using SPACE and CTRL
- **Visual Rope** - Dynamic rope rendering between winch and vehicle
- **Vehicle Highlighting** - Highlight nearest vehicle within range
- **Towing System** - Physics-based vehicle suspension for towing
- **Framework Support** - Compatible with ox_core, qbx_core, qb-core, and ESX

## Requirements

- [ox_lib]([[https://github.com/overextended/ox_lib](https://github.com/communityox/ox_lib)](https://github.com/communityox/ox_lib)
- [UnixLib](https://github.com/sudorest/Unix-Lib)

## Installation

1. Download the latest release
2. Extract to your resources folder
3. Add `ensure unix_winch` to your server.cfg
4. Configure `config.lua` as needed

## Configuration

All settings are in `config.lua`:

```lua
Config.Winch = {
    MaxReach = 15,          -- Maximum distance to hook vehicles
    LiftSpeed = 2,          -- Speed when raising
    LowerSpeed = 2,         -- Speed when lowering
    HookDuration = 2000,    -- Time to attach hook (ms)
    MaxHeight = 5,          -- Maximum lift height
    StartTimeout = 10000,   -- Wait time for UnixLib
    TickInterval = 100,     -- Tick rate (ms)
}

Config.Towing = {
    TowMaxSpeed = 60,       -- Max speed while towing
    FollowDistance = 6,     -- Distance to follow
    SmoothFactor = 0.1,     -- Smooth following
    SyncThreshold = 0.5,    -- Sync threshold
}

Config.Item = {
    Required = 'winch_kit', -- Item required to use winch (nil to disable)
    RemoveOnUse = false,    -- Remove item on use
}

Config.Vehicle = {
    AllowedVehicles = nil,  -- Whitelist specific vehicles
    BlacklistedVehicles = {}, -- Blacklist vehicles
}

Config.Keybinds = {
    Deploy = 'E',   -- Deploy/retract winch
    Hook = 'E',     -- Hook vehicle
    Release = 'G', -- Release vehicle
    Raise = 'SPACE',
    Lower = 'CTRL',
}

Config.UI = {
    ShowRangeIndicator = true,
    RangeColor = {255, 255, 255, 150},
    HighlightColor = {0, 255, 0, 255},
}
```

## Usage

1. Press `E` near a vehicle to deploy the winch
2. Aim at a highlighted vehicle within range and press `E` to hook
3. Hold `SPACE` to raise or `CTRL` to lower the vehicle
4. Press `G` to release the vehicle
5. Press `E` again to retract the winch

## Exports

```lua
-- Check if player has winch deployed
local hasWinch = exports.unix_winch:HasWinch()

-- Check if a vehicle is hooked
local isHooked = exports.unix_winch:IsVehicleHooked(vehicle)

-- Get currently hooked vehicle
local hookedVehicle = exports.unix_winch:GetHookedVehicle()

-- Programmatically deploy winch
exports.unix_winch:DeployWinch()

-- Programmatically unhook vehicle
exports.unix_winch:UnhookVehicle()
```

## Events

```lua
-- Winch deployed/retracted
RegisterEvent('unix_winch:deployed', function() end)
RegisterEvent('unix_winch:retracted', function() end)

-- Vehicle hooked/released
RegisterEvent('unix_winch:hooked', function(vehicle) end)
RegisterEvent('unix_winch:released', function(vehicle) end)

-- Vehicle towed (server-side)
RegisterEvent('unix_winch:vehicleTowed:complete', function(source, name, plate) end)
```

## License

See LICENSE file for details.
