
local BASE_H = 1080

function Initialize()
    ApplyScale()
end

function Update()
end

function ApplyScale()
    local screenW = tonumber(SKIN:GetVariable('SCREENAREAWIDTH'))  or 1920
    local screenH = tonumber(SKIN:GetVariable('SCREENAREAHEIGHT')) or 1080

    local scale = screenH / BASE_H
    if scale < 0.5 then scale = 0.5 end
    if scale > 2.0 then scale = 2.0 end
    scale = math.floor(scale * 10000 + 0.5) / 10000

    -- 1. Write ScaleDpi using native Rainmeter bang
    local globalPath = SKIN:GetVariable('@') .. 'GlobalSettings.inc'
    SKIN:Bang('!WriteKeyValue', 'Variables', 'ScaleDpi', tostring(scale), globalPath)

    local function px(val) return math.floor(val + 0.5) end
    
    local cdX = px((screenW - (500 * scale)) / 2)
    local cdY = px(102 * scale)

    local vizX = px((screenW - 380) / 2)
    local vizY = px(677 * scale)

    local layoutPath = 'C:\\Users\\Chamika N Lakshan\\AppData\\Roaming\\Rainmeter\\Layouts\\WinTahoe 1\\Rainmeter.ini'
    
    local cmds = {}
    local function addBang(bang) table.insert(cmds, bang) end



    SKIN:Bang(table.concat(cmds, ""))
    SKIN:Bang('!Log "AutoScale1: Optimized scaling applied."')
end
