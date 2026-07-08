
local BASE_W = 1920
local BASE_H = 1080
local RIGHT_MARGIN = 137

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

    local override = tonumber(SKIN:GetVariable('OverrideAutoScale')) or 0
    if override == 1 then
        scale = tonumber(SKIN:GetVariable('ScaleDpi')) or 1
    else
        local globalPath = SKIN:GetVariable('@') .. 'GlobalSettings.inc'
        SKIN:Bang('!WriteKeyValue', 'Variables', 'ScaleDpi', tostring(scale), globalPath)
    end

    local function px(val) return math.floor(val + 0.5) end
    
    local function anchorRight(baseX)
        local offsetAt1080 = BASE_W - baseX - RIGHT_MARGIN
        return px(screenW - RIGHT_MARGIN - (offsetAt1080 * scale))
    end
    
    local function scaleY(baseY) return px(baseY * scale) end

    local clockX    = anchorRight(1442)
    local clockY    = scaleY(140)
    local battX     = anchorRight(1623)
    local battY     = scaleY(138)
    local calX      = anchorRight(1433)
    local calY      = scaleY(321)
    local dispX     = anchorRight(1436)
    local dispY     = scaleY(533)
    local soundX    = anchorRight(1437)
    local soundY    = scaleY(631)
    local sysX      = anchorRight(1470)
    local sysY      = scaleY(730)
    
    local vizX      = px(100)     -- fixed left margin (same as layout)
    local vizY      = scaleY(719)
    
    local cdX       = px(55)      -- fixed left margin (same as layout)
    local cdY       = scaleY(214)

    local layoutPath = 'C:\\Users\\Chamika N Lakshan\\AppData\\Roaming\\Rainmeter\\Layouts\\WinTahoe 2\\Rainmeter.ini'
    
    local cmds = {}
    local function addBang(bang) table.insert(cmds, bang) end
    local function setPos(config, x, y)
    end

    setPos('Windows Tahoe - Liquid Glass\\Clock', clockX, clockY)
    setPos('Windows Tahoe - Liquid Glass\\Battery', battX, battY)
    setPos('Windows Tahoe - Liquid Glass\\Calendar\\Calendar Wide', calX, calY)
    setPos('Windows Tahoe - Liquid Glass\\Display', dispX, dispY)
    setPos('Windows Tahoe - Liquid Glass\\Sound', soundX, soundY)
    setPos('Windows Tahoe - Liquid Glass\\System', sysX, sysY)
    setPos('Windows Tahoe - Liquid Glass\\Visualizer', vizX, vizY)
    setPos('Windows Tahoe - Liquid Glass\\ClockDate', cdX, cdY)

    SKIN:Bang(table.concat(cmds, ""))
    SKIN:Bang('!Log "AutoScale2: Optimized scaling applied."')
end
