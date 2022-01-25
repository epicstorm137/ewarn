net.Receive("ewarn_open",function()
    ewarn.OpenWarns()
end)

net.Receive("ewarn_plymsg",function()
    chat.AddText(ewarn.red,ewarn.Config.ChatPrefix,ewarn.white,net.ReadString())
end)

local function getply(name)
    for k,v in ipairs(player.GetAll()) do
        if v:Nick() == name then
            return v
        end
    end
end

function ewarn.OpenWarns()
    local scrw,scrh = ScrW(),ScrH()

    local frame = vgui.Create("DFrame")
	frame:SetSize(0,0)
	frame:Center()
	frame:MakePopup()
	frame:SetVisible(true)
	frame:DockPadding(10,30,10,10)
	ewarn.MakeFrame(frame,"EWarn Menu",scrw*.7,scrh*.6)

    local bpannel = vgui.Create("DPanel",frame)
    bpannel:Dock(BOTTOM)
    bpannel:SetTall(scrw*.015)
    bpannel:DockMargin(0,10,0,0)
    bpannel.Paint = function() end

    local lookup = vgui.Create("DTextEntry",bpannel)
    lookup:Dock(LEFT)
    lookup:SetWide(scrw*.075)
    ewarn.MakeInput(lookup,"Search Player")

    local stat = vgui.Create("DPanel",bpannel)
    stat:Dock(FILL)
    stat:DockMargin(5,0,0,0)
    stat.Warn = "Select a Warning !"
    stat.Paint = function(s,w,h)
        surface.SetDrawColor(ewarn.bglight)
		surface.DrawRect(0,0,w,h)
        draw.SimpleText(stat.Warn,"WLFontUI",w/2,h/2,rainbow,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local players = vgui.Create("DListView",frame)
    players:Dock(LEFT)
    players:SetMultiSelect(false)
    players:SetWide(scrw*.075)
    players:AddColumn("Players",1)
    players:SortByColumn(1,true)
    ewarn.MakeList(players)
    for k,v in ipairs(player.GetAll(),false) do
        local pline = players:AddLine(v:Nick())
    end

    local warns = vgui.Create("DListView",frame)
    warns:Dock(FILL)
    warns:SetMultiSelect(false)
    warns:DockMargin(5,0,0,0)
    warns:AddColumn("Index",1)
    warns:AddColumn("Date",2)
    warns:AddColumn("Reason",3)
    warns:AddColumn("Admin Name",4)
    warns:AddColumn("Admin SteamID",5)
    ewarn.MakeList(warns)

    players.OnRowSelected = function( panel, index, row )
        local plyname = row:GetValue(1)
        local target = getply(plyname)
        if !ewarn.Config.AllowedRanks[LocalPlayer():GetUserGroup()] then
            if target != LocalPlayer() then warns:Clear() return end
        end
        net.Start("ewarn_get")
        net.WriteEntity(target)
        net.SendToServer()
        net.Receive("ewarn_send",function()
            local data = util.JSONToTable(util.Decompress(net.ReadData(1048000)))
            warns:Clear()
            for k,v in ipairs(data) do
                local line = warns:AddLine(v.id, v.Date, v.Reason, v.AdminName, v.AdminID)
                line.OnSelect = function()
                    stat.Warn = "Reason: "..line:GetColumnText(4)
                end
                line.OnRightClick = function()
                    local rightclick = DermaMenu()
                    rightclick:AddOption("Copy Reason",function() SetClipboardText(line:GetColumnText(3)) end)
                    rightclick:AddOption("Copy Admin's SteamID",function() SetClipboardText(line:GetColumnText(5)) end)

                    if ewarn.Config.AllowedRanks[LocalPlayer():GetUserGroup()] then
                        rightclick:AddOption("Remove Warning",function()
                            net.Start("ewarn_delete")
                            net.WriteInt(line:GetColumnText(1),32)
                            net.WriteEntity(target)
                            net.SendToServer()
                        end)
                        rightclick:AddOption("Edit Warning",function()
                            Derma_StringRequest("EWarn - Edit","Enter the new reason:",v.Reason,function(text)
                                net.Start("ewarn_edit")
                                net.WriteInt(line:GetColumnText(1),32)
                                net.WriteEntity(target)
                                net.WriteString(text)
                                net.SendToServer()
                            end)
                        end)
                    end
                    rightclick:Open(gui.MouseX(),gui.MouseY())
                end
            end
        end)
        warns:SortByColumn(1,true)
    end
end