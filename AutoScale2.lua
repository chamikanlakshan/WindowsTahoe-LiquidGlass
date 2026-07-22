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
    local weatherX  = anchorRight(1435)
    local weatherY  = scaleY(138)
    local dispX     = anchorRight(1436)
    local dispY     = scaleY(533)
    local soundX    = anchorRight(1437)
    local soundY    = scaleY(631)
    local sysX      = anchorRight(1470)
    local sysY      = scaleY(730)

    local vizX      = px(100)
    local vizY      = scaleY(719)

    local cdX       = px(55)
    local cdY       = scaleY(214)

    local settingsPath = SKIN:GetVariable('SETTINGSPATH')
    local liveIni = settingsPath .. 'Rainmeter.ini'
    local layoutIni = settingsPath .. 'Layouts\\WinTahoe 2\\Rainmeter.ini'

    local function writePos(iniPath, config, x, y, active)
        SKIN:Bang('!WriteKeyValue', config, 'WindowX', tostring(x), iniPath)
        SKIN:Bang('!WriteKeyValue', config, 'WindowY', tostring(y), iniPath)
        SKIN:Bang('!WriteKeyValue', config, 'AnchorX', '0%', iniPath)
        SKIN:Bang('!WriteKeyValue', config, 'AnchorY', '0%', iniPath)
        if active then
            SKIN:Bang('!WriteKeyValue', config, 'Active', '1', iniPath)
        end
    end

    local base = 'Windows Tahoe - Liquid Glass\\'

    local widgets = {
        { config = base .. 'Clock',                   x = clockX,   y = clockY   },
        { config = base .. 'Battery',                 x = battX,    y = battY    },
        { config = base .. 'Calendar\\Calendar Wide', x = calX,     y = calY     },
        { config = base .. 'Weather',                 x = weatherX, y = weatherY },
        { config = base .. 'Display',                 x = dispX,    y = dispY    },
        { config = base .. 'Sound',                   x = soundX,   y = soundY   },
        { config = base .. 'System',                  x = sysX,     y = sysY     },
        { config = base .. 'Visualizer',              x = vizX,     y = vizY     },
        { config = base .. 'ClockDate',               x = cdX,      y = cdY      },
    }

    -- Mark AutoScale itself as active in layout files so it auto-starts after LoadLayout
    local autoScaleCfg = base .. 'AutoScale\\AutoScale2'
    writePos(layoutIni, autoScaleCfg, 0, 0, true)
    writePos(liveIni,    autoScaleCfg, 0, 0, true)

    for _, w in ipairs(widgets) do
        writePos(liveIni, w.config, w.x, w.y)
        writePos(layoutIni, w.config, w.x, w.y)
        SKIN:Bang('!Move', tostring(w.x), tostring(w.y), w.config)
    end

    -- Refresh widget skins so ScaleDpi sizing updates without manual intervention
    for _, w in ipairs(widgets) do
        SKIN:Bang('!Refresh', w.config)
    end

    SKIN:Bang('!Log "AutoScale2: screenH=' .. screenH .. ' scale=' .. scale .. '"')
end
