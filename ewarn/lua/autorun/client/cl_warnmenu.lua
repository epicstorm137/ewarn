ewarn.bgdark     = Color(69,81,97)
ewarn.bglight    = Color(118,134,165)
ewarn.grey       = Color(150,150,150)
ewarn.hghlight   = Color(141,141,190)
ewarn.white      = Color(255,255,255)
ewarn.blackhud   = Color(20,20,20,253)
ewarn.green      = Color(94,214,94)
ewarn.red        = Color(204,117,117)
ewarn.blue       = Color(110,117,212)
ewarn.wfgreen    = Color(0,255,0)
ewarn.rfgreen    = Color(0,255,0,50)

local PNL = FindMetaTable("Panel")

surface.CreateFont("EWarnFont",{font = "Roboto",size = 255, antialias = true})
surface.CreateFont("EWarnFontUI",{font = "Roboto",size = 20, antialias = true})
surface.CreateFont("EWarnFontUISmall",{font = "Roboto",size = 15, antialias = true})

function ewarn.MakeFrame(pnl,txt,width,height)
    pnl:SetTitle("")
    pnl.IsMoving = true
    pnl:SizeTo(width,height,1,0,.1,function()
        pnl.IsMoving = false
    end)
    pnl.Paint = function(s,w,h)
        if pnl.IsMoving == true then
            pnl:Center()
        end
        surface.SetDrawColor(ewarn.bgdark)
        surface.DrawRect(0,0,w,h)
        draw.SimpleText(txt,"EWarnFontUISmall",10,7,ewarn.white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
    end
end

function ewarn.MakeButton(pnl,txt,col)
    pnl:SetText("")
    local speed,barstatus = 4,0
    pnl.Paint = function(s,w,h)
        if pnl:IsHovered() then
            barstatus = math.Clamp(barstatus + speed * FrameTime(), 0, 1)
        else
            barstatus = math.Clamp(barstatus - speed * FrameTime(), 0, 1)
        end
        surface.SetDrawColor(ewarn.bglight)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(col)
        surface.DrawRect(0,h * .9,w * barstatus,h * .1)
        draw.SimpleText(txt,"EWarnFontUI",w/2,h/2,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end
    
function ewarn.MakeInput(pnl,txt)
    pnl:SetFont("EWarnFontUISmall")
    pnl.Paint = function(s,w,h)
        surface.SetDrawColor(ewarn.bglight)
        surface.DrawRect(0,0,w,h)
        if pnl:GetText() == "" then
            draw.SimpleText(txt,"EWarnFontUISmall",5,h/2,ewarn.white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end
        pnl:DrawTextEntryText(ewarn.white,ewarn.hghlight,ewarn.white)
    end
end
    
function ewarn.MakeCombo(pnl,txt)
    pnl:SetFont("EWarnFontUISmall")
    pnl:SetColor(ewarn.white)
    pnl.Paint = function(s,w,h)
        surface.SetDrawColor(ewarn.bglight)
        surface.DrawRect(0,0,w,h)
        if pnl:GetSelected() == nil and pnl:GetText() == "" then
            draw.SimpleText(txt,"EWarnFontUISmall",5,h/2,ewarn.grey,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end
    end
end

function ewarn.MakeList(pnl)
    pnl.Paint = function(s,w,h)
        surface.SetDrawColor(ewarn.bglight)
        surface.DrawRect(0,0,w,h)
    end
end