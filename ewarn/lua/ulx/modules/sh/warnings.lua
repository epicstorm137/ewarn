local CATEGORY_NAME = "Warnings"

function ulx.warn( calling_ply, target_ply, reason )
		target_ply:AddWarn(reason,calling_ply:Nick(),calling_ply:SteamID())

	ulx.fancyLogAdmin( calling_ply, "#A warned #T for #s", target_ply, reason )
end
local warn = ulx.command( CATEGORY_NAME, "ulx warn", ulx.warn, "!warn" )
warn:addParam{ type=ULib.cmds.PlayerArg }
warn:addParam{ type=ULib.cmds.StringArg, hint="", ULib.cmds.takeRestOfLine }
warn:defaultAccess( ULib.ACCESS_ADMIN )
warn:help( "Warns the target." )