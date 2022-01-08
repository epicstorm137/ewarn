util.AddNetworkString("ewarn_open")
util.AddNetworkString("ewarn_get")
util.AddNetworkString("ewarn_send")
util.AddNetworkString("ewarn_delete")
util.AddNetworkString("ewarn_edit")
util.AddNetworkString("ewarn_plymsg")

local plymeta = FindMetaTable("Player")

function ewarn.CreateTable()
    sql.Query("CREATE TABLE IF NOT EXISTS ewarn ('id' INTEGER NOT NULL, 'SteamID' TEXT NOT NULL, 'data' TEXT NOT NULL, PRIMARY KEY('id'));")
end

ewarn.CreateTable()

function plymeta:EWarnMessage(str)
    net.Start("ewarn_plymsg")
    net.WriteString(str)
    net.Send(self)
end

function plymeta:AddWarn(reason,adminname,adminid)
    local tbl = {
        ["Date"] = os.date("%H:%M:%S - %d/%m/%Y"),
        ["Name"] = self:Nick(),
        ["Reason"] = reason,
        ["AdminName"] = adminname,
        ["AdminID"] = adminid,
    }

    sql.Query("INSERT INTO ewarn (id, SteamID, data) VALUES(NULL, "..sql.SQLStr(self:SteamID())..", "..sql.SQLStr(util.TableToJSON(tbl)) ..");")
end

function plymeta:EditWarn(id,reason)
    if !isnumber(id) then print("ewarn,notanmuber") return end
    local query = sql.QueryValue("SELECT * FROM ewarn WHERE id = "..SQLStr(id)..";")

    if (query) then
        query = util.JSONToTable(query)
        query.Reason = reason
        sql.Query("UPDATE ewarn SET data = "..sql.SQLStr( util.TableToJSON(query) ).." WHERE id = "..sql.SQLStr( id )..";")
    end
end

function plymeta:RemoveWarn(id)
    if !isnumber(id) then print("ewarn,notanmuber") return end
    local query = sql.Query("SELECT * FROM ewarn WHERE SteamID = "..SQLStr(self:SteamID())..";")

    if (query) then
        sql.Query("DELETE FROM ewarn WHERE id = ".. SQLStr(id) ..";")
    end
end

function plymeta:GetWarns()
    local query = sql.Query("SELECT * FROM ewarn WHERE SteamID = "..SQLStr(self:SteamID())..";")

    if (query) then
        return query
    else
        return {}
    end
end

net.Receive("ewarn_get",function(len,ply)
    if !ewarn.Config.PlayersCanSee and !ewarn.Config.AllowedRanks[ply:GetUserGroup()] then return end

    local target = net.ReadEntity()
    if !IsValid(target) then return end
    net.Start("ewarn_send")
    net.WriteData(util.Compress(util.TableToJSON(target:GetWarns())))
    net.Send(ply)
end)

net.Receive("ewarn_delete",function(len,ply)
    if !ewarn.Config.AllowedRanks[ply:GetUserGroup()] then return end

    local int = net.ReadInt(32)
    local target = net.ReadEntity()
    if !IsValid(target) then return end
    target:RemoveWarn(int)
    net.Start("ewarn_send")
    net.WriteData(util.Compress(util.TableToJSON(target:GetWarns())))
    net.Send(ply)

    ply:EWarnMessage("Warning removed for "..target:Nick().."!")
end)

net.Receive("ewarn_edit",function(len,ply)
    if !ewarn.Config.AllowedRanks[ply:GetUserGroup()] then return end

    local int = net.ReadInt(32)
    local target = net.ReadEntity()
    local reason = net.ReadString()
    if !IsValid(target) then return end
    target:EditWarn(int,reason)
    net.Start("ewarn_send")
    net.WriteData(util.Compress(util.TableToJSON(target:GetWarns())))
    net.Send(ply)

    ply:EWarnMessage("Warning edited for "..target:Nick().."!")
end)

hook.Add("PlayerSay","ewarn:openmenu",function(ply,txt,bool)
    if !ewarn.Config.Commands[string.lower(string.Trim(txt))] then return end
    if ewarn.Config.AllowedRanks[ply:GetUserGroup()] or ewarn.Config.PlayersCanSee then
        net.Start("ewarn_open")
        net.Send(ply)
        return ""
    end
end)

local function getname(ply) if IsValid(ply) then return ply:Nick() else return "(Console)" end end
local function getid(ply) if IsValid(ply) then return ply:SteamID() else return "SERVER_ID" end end

hook.Add("ULibPlayerKicked","ewarn:logkicks",function(sid, reason, caller)
    if !ewarn.Config.LogKick then return end

    local tbl = {
        ["Date"] = os.date("%H:%M:%S - %d/%m/%Y"),
        ["Name"] = "Offline Player",
        ["Reason"] = "[KICK] Reason: "..reason,
        ["AdminName"] = getname(caller),
        ["AdminID"] = getid(caller),
    }

    sql.Query("INSERT INTO ewarn (id, SteamID, data) VALUES(NULL, "..sql.SQLStr(sid)..", "..sql.SQLStr(util.TableToJSON(tbl)) ..");")
end)

hook.Add("ULibPlayerBanned","ewarn:logbans",function(sid, bandata)
    if !ewarn.Config.LogKick then return end

    bandata.reason = bandata.reason or "No Reason Given."

    local tbl = {
        ["Date"] = os.date("%H:%M:%S - %d/%m/%Y"),
        ["Name"] = "Offline Player",
        ["Reason"] = "[BAN] Reason: "..bandata.reason,
        ["AdminName"] = bandata.admin,
        ["AdminID"] = "",
    }

    sql.Query("INSERT INTO ewarn (id, SteamID, data) VALUES(NULL, "..sql.SQLStr(sid)..", "..sql.SQLStr(util.TableToJSON(tbl)) ..");")
end)