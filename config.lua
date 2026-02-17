Config = Config or {}

Config.Winch = {
    MaxReach = 15,
    LiftSpeed = 2,
    LowerSpeed = 2,
    HookDuration = 2000,
    MaxHeight = 5,
    StartTimeout = 10000,
    TickInterval = 100,
}

Config.Towing = {
    TowMaxSpeed = 60,
    FollowDistance = 6,
    SmoothFactor = 0.1,
    SyncThreshold = 0.5,
}

Config.Item = {
    Required = 'winch_kit',
    RemoveOnUse = false,
}

Config.Vehicle = {
    AllowedVehicles = nil,
    BlacklistedVehicles = {},
}

Config.Keybinds = {
    Deploy = 'E',
    Hook = 'E',
    Release = 'G',
    Raise = 'SPACE',
    Lower = 'CTRL',
}

Config.UI = {
    ShowRangeIndicator = true,
    RangeColor = {255, 255, 255, 150},
    HighlightColor = {0, 255, 0, 255},
}

Config.Debug = false
