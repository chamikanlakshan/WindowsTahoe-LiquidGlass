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

    local override = tonumber(SKIN:GetVariable('OverrideAutoScale')) or 0
    if override == 1 then
        scale = tonumber(SKIN:GetVariable('ScaleDpi')) or 1
    else
        local globalPath = SKIN:GetVariable('@') .. 'GlobalSettings.inc'
        SKIN:Bang('!WriteKeyValue', 'Variables', 'ScaleDpi', tostring(scale), globalPath)
    end

    local function px(val) return math.floor(val + 0.5) end

    local cdX = px((screenW - (500 * scale)) / 2)
    local cdY = px(102 * scale)

    local vizX = px((screenW - 380) / 2)
    local vizY = px(677 * scale)

    local settingsPath = SKIN:GetVariable('SETTINGSPATH')
    local liveIni = settingsPath .. 'Rainmeter.ini'
    local layout1Ini = settingsPath .. 'Layouts\\WinTahoe 1\\Rainmeter.ini'
    local layout2Ini = settingsPath .. 'Layouts\\WinTahoe 2\\Rainmeter.ini'

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
    local autoScaleCfg = base .. 'AutoScale\\AutoScale1'

    -- Mark AutoScale itself as active so it starts after LoadLayout
    writePos(layout1Ini, autoScaleCfg, 0, 0, true)
    writePos(layout2Ini, autoScaleCfg, 0, 0, true)
    writePos(liveIni,    autoScaleCfg, 0, 0, true)

    -- Widgets for Layout 1
    local widgets = {
        { config = base .. 'ClockDate',  x = cdX,  y = cdY  },
        { config = base .. 'Visualizer', x = vizX, y = vizY },
    }
    for _, w in ipairs(widgets) do
        writePos(liveIni,    w.config, w.x, w.y)
        writePos(layout1Ini, w.config, w.x, w.y)
        writePos(layout2Ini, w.config, w.x, w.y)
        SKIN:Bang('!Move', tostring(w.x), tostring(w.y), w.config)
    end

    for _, w in ipairs(widgets) do
        SKIN:Bang('!Refresh', w.config)
    end

    SKIN:Bang('!Log "AutoScale1: screenH=' .. screenH .. ' scale=' .. scale .. '"')
end
