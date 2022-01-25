ewarn = ewarn or {}
ewarn.Config = ewarn.Config or {}

-- Prefix for chat messages, make sure to leave a space after
ewarn.Config.ChatPrefix = "[EWarn] "

-- If enabled, players will be able to see their own warnings
ewarn.Config.PlayersCanSee = true

-- If enabled, warns will be added when you get kicked
ewarn.Config.LogKick = true -- Feature not available yet

-- If enabled, warns will be added when you get kicked
ewarn.Config.LogBan = true -- Feature not available yet

-- Allowed ranks to open the warning menu and edit/remove warnings
ewarn.Config.AllowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
}

-- Commands that will open the menu
ewarn.Config.Commands = {
    ["/warns"] = true,
    ["/warnings"] = true,
}