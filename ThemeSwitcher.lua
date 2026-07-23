
local BASE = 'Windows Tahoe - Liquid Glass\\'

local WIDGETS = {
    { var = 'ShowClock',         path = 'Clock',                   light = 'Clock.ini',           dark = 'ClockDark.ini'           },
    { var = 'ShowClockCalendar', path = 'ClockCalendar',           light = 'ClockCalendar.ini',   dark = 'ClockCalendarDark.ini'   },
    { var = 'ShowBattery',       path = 'Battery',                 light = 'Battery.ini',         dark = 'BatteryDark.ini'         },
    { var = 'ShowCalendar',      path = 'Calendar\\Calendar',      light = 'Calendar.ini',        dark = 'CalendarDark.ini'        },
    { var = 'ShowCalendarWide',  path = 'Calendar\\Calendar Wide', light = 'CalendarWide.ini',    dark = 'CalendarWideDark.ini'    },
    { var = 'ShowDate',          path = 'Calendar\\Date',          light = 'Date.ini',            dark = 'DateDark.ini'            },
    { var = 'ShowDateMonth',     path = 'Calendar\\Date - Month',  light = 'DateMonth.ini',       dark = 'DateMonthDark.ini'       },
    { var = 'ShowDateEvents',    path = 'Calendar\\Date - Events', light = 'DateEvents.ini',      dark = 'DateEventsDark.ini'      },
    { var = 'ShowWeather',       path = 'Weather',                 light = 'Weather.ini',         dark = 'WeatherDark.ini'         },
    { var = 'ShowDisplay',       path = 'Display',                 light = 'Display.ini',         dark = 'DisplayDark.ini'         },
    { var = 'ShowSound',         path = 'Sound',                   light = 'Sound.ini',           dark = 'SoundDark.ini'           },
    { var = 'ShowSystem',        path = 'System',                  light = 'System.ini',          dark = 'SystemDark.ini'          },
    { var = 'ShowClockDate',     path = 'ClockDate',               light = 'ClockDate.ini',       dark = 'ClockDateDark.ini'       },
    { var = 'ShowVisualizer',    path = 'Visualizer',              light = 'Visualizer.ini',      dark = 'Visualizer.ini'          },
}

local THEME_VARS = {
    'Theme', 'ThemeBattery', 'ThemeClock', 'ThemeClockCalendar', 'ThemeCalendar', 'ThemeCalendarWide',
    'ThemeDate', 'ThemeDateMonth', 'ThemeDateEvents', 'ThemeSystem', 'ThemeSound', 'ThemeDisplay',
    'ThemeWeather', 'ThemeClockDate',
}

local GRADIENTS = {
    transparent = {
        light = '180 | 255,255,255,140 ; 0.0 | 255,255,255,140 ; 1.0',
        dark  = '180 | 0,0,0,150 ; 0.0 | 0,0,0,150 ; 1.0',
    },
    solid = {
        light = '180 | 255,255,255,255 ; 0.0 | 255,255,255,255 ; 1.0',
        dark  = '180 | 0,0,0,255 ; 0.0 | 0,0,0,255 ; 1.0',
    },
}


local function normPath(p)
    return p:lower():gsub('\\', '/')
end

local function ReadFileVariables(keys)
    local resourcePath = SKIN:GetVariable('@', '')
    local file = io.open(resourcePath .. 'GlobalSettings.inc', 'r')
    local result = {}
    if not file then
        for _, k in ipairs(keys) do result[k] = '0' end
        return result
    end

    local remaining = #keys
    for line in file:lines() do
        for _, k in ipairs(keys) do
            if not result[k] then
                local val = line:match('^%s*' .. k .. '%s*=(.-)%s*$')
                if val then
                    result[k] = val
                    remaining  = remaining - 1
                end
            end
        end
        if remaining == 0 then break end
    end
    file:close()

    for _, k in ipairs(keys) do
        if not result[k] then result[k] = '0' end
    end
    return result
end

local function ReadFileVariable(varName)
    return ReadFileVariables({ varName })[varName]
end

local function DecodeRainmeterIni()
    local rainmeterIni = SKIN:GetVariable('SETTINGSPATH') .. 'Rainmeter.ini'
    local file = io.open(rainmeterIni, 'rb')
    if not file then return {} end

    local raw = file:read('*all')
    file:close()

    local content = raw:gsub('^\xff\xfe', ''):gsub('%z', '')

    local activeSet = {}
    local currentSection = nil
    for line in content:gmatch('[^\r\n]+') do
        local section = line:match('^%s*%[(.-)%]%s*$')
        if section then
            currentSection = normPath(section)
        elseif currentSection then
            local activeVal = line:match('^%s*Active%s*=%s*(%d+)%s*$')
            if activeVal and tonumber(activeVal) > 0 then
                activeSet[currentSection] = true
            end
        end
    end
    return activeSet
end

local function GetAllActiveConfigs()
    return DecodeRainmeterIni()
end

local function IsConfigActive(configPath)
    local activeSet = DecodeRainmeterIni()
    return activeSet[normPath(BASE .. configPath)] == true
end

local function GetRunningWidgets(activeConfigs)
    local running = {}
    for _, w in ipairs(WIDGETS) do
        if activeConfigs[normPath(BASE .. w.path)] then
            running[#running + 1] = w
        end
    end
    return running
end

local function GetWidgetThemeVar(widget)
    local suffix = widget.var:match('^Show(.+)$')
    if suffix then
        local candidate = 'Theme' .. suffix
        for _, tv in ipairs(THEME_VARS) do
            if tv == candidate then return candidate end
        end
    end
    return 'Theme'
end


local function SwitchTheme(toLight)
    local newTheme = toLight and 'Light' or 'Dark'
    local currentVals = ReadFileVariables(THEME_VARS)
    local bangs    = {}
    local anyChanged = false
    local delayBangs = {}

    for _, v in ipairs(THEME_VARS) do
        if currentVals[v] ~= newTheme then
            bangs[#bangs + 1] = '[!WriteKeyValue Variables ' .. v .. ' ' .. newTheme .. ' "#@#GlobalSettings.inc"]'
            bangs[#bangs + 1] = '[!SetVariable ' .. v .. ' ' .. newTheme .. ']'
            anyChanged = true
        end
    end

    local runningWidgets = GetRunningWidgets(GetAllActiveConfigs())

    for _, w in ipairs(runningWidgets) do
        local tVar = GetWidgetThemeVar(w)
        if currentVals[tVar] ~= newTheme then
            local target = toLight and w.light or w.dark
            local configPath = BASE .. w.path

            -- FIX 1: Explicit deactivate first — prevents the old skin from
            bangs[#bangs + 1] = '[!DeactivateConfig "' .. configPath .. '"]'
            bangs[#bangs + 1] = '[!WriteKeyValue "' .. configPath .. '" "AlphaValue" "0" "#SETTINGSPATH#Rainmeter.ini"]'
            bangs[#bangs + 1] = '[!ActivateConfig "' .. configPath .. '" "' .. target .. '"]'

            delayBangs[#delayBangs + 1] = '[!SetTransparency "255" "' .. configPath .. '"]'
            delayBangs[#delayBangs + 1] = '[!WriteKeyValue "' .. configPath .. '" "AlphaValue" "255" "#SETTINGSPATH#Rainmeter.ini"]'
        end
    end

    if anyChanged then
        bangs[#bangs + 1] = '[!UpdateMeasure MeasureTheme][!UpdateMeasure MeasureActiveTab][!Redraw]'
        if #delayBangs > 0 then
            -- FIX 2: 300ms gives EasyBlur enough time to init across all
            bangs[#bangs + 1] = '[!Delay "300"]'
            for _, db in ipairs(delayBangs) do
                bangs[#bangs + 1] = db
            end
        end
        SKIN:Bang(table.concat(bangs))
    end
end

function SwitchToLight() SwitchTheme(true)  end
function SwitchToDark()  SwitchTheme(false) end


function ToggleTransparency()
    local current = tonumber(ReadFileVariable('TransparencyDisabled')) or 0
    local newVal  = (current == 1) and '0' or '1'
    local g       = (newVal == '1') and GRADIENTS.solid or GRADIENTS.transparent

    local bangs = {
        '[!WriteKeyValue Variables TransparencyDisabled ' .. newVal  .. ' "#@#GlobalSettings.inc"]',
        '[!WriteKeyValue Variables LightGradient "'       .. g.light .. '" "#@#GlobalSettings.inc"]',
        '[!WriteKeyValue Variables DarkGradient "'        .. g.dark  .. '" "#@#GlobalSettings.inc"]',
    }

    local currentVals = ReadFileVariables(THEME_VARS)
    local activeConfigs = GetAllActiveConfigs()

    for _, w in ipairs(WIDGETS) do
        if activeConfigs[normPath(BASE .. w.path)] then
            local tVar = GetWidgetThemeVar(w)
            local isWidgetLight = (currentVals[tVar] == 'Light')
            local grad = isWidgetLight and g.light or g.dark
            bangs[#bangs + 1] = '[!SetOption Shape FillGradient "' .. grad .. '" "' .. BASE .. w.path .. '"]'
            bangs[#bangs + 1] = '[!UpdateMeter Shape "' .. BASE .. w.path .. '"]'
            bangs[#bangs + 1] = '[!Redraw "' .. BASE .. w.path .. '"]'
        end
    end

    bangs[#bangs + 1] = '[!SetVariable TransparencyDisabled ' .. newVal .. ']'
    bangs[#bangs + 1] = '[!UpdateMeasure MeasureTransparencyState]'

    SKIN:Bang(table.concat(bangs))
end


function RefreshActiveWidgets()
    local currentVals = ReadFileVariables(THEME_VARS)
    local activeConfigs = GetAllActiveConfigs()
    local bangs         = {}

    for _, w in ipairs(GetRunningWidgets(activeConfigs)) do
        local tVar = GetWidgetThemeVar(w)
        local isWidgetLight = (currentVals[tVar] == 'Light')
        bangs[#bangs + 1] = '[!Refresh "' .. BASE .. w.path .. '" "' .. (isWidgetLight and w.light or w.dark) .. '"]'
    end

    if #bangs > 0 then
        SKIN:Bang(table.concat(bangs))
    end
end


function ToggleWidgetByVar(varName)
    local widget = nil
    for _, w in ipairs(WIDGETS) do
        if w.var == varName then widget = w; break end
    end
    if not widget then return end

    local themeVar = GetWidgetThemeVar(widget)

    local vals          = ReadFileVariables({ themeVar })
    local activeConfigs = GetAllActiveConfigs()
    local isActive      = activeConfigs[normPath(BASE .. widget.path)] == true
    local newVal        = isActive and 0 or 1
    local toEnable      = (vals[themeVar] == 'Light') and widget.light or widget.dark
    local configPath    = BASE .. widget.path

    local bangs = {
        '[!WriteKeyValue Variables ' .. varName .. ' ' .. newVal .. ' "#@#GlobalSettings.inc"]',
    }

    if newVal == 1 then
        bangs[#bangs + 1] = '[!WriteKeyValue "' .. configPath .. '" "AlphaValue" "0" "#SETTINGSPATH#Rainmeter.ini"]'
        bangs[#bangs + 1] = '[!ActivateConfig "' .. configPath .. '" "' .. toEnable .. '"]'
        bangs[#bangs + 1] = '[!Redraw]'
        -- FIX 2: Consistent 300ms delay here too for EasyBlur init
        bangs[#bangs + 1] = '[!Delay "300"]'
        bangs[#bangs + 1] = '[!SetTransparency "255" "' .. configPath .. '"]'
        bangs[#bangs + 1] = '[!WriteKeyValue "' .. configPath .. '" "AlphaValue" "255" "#SETTINGSPATH#Rainmeter.ini"]'
    else
        bangs[#bangs + 1] = '[!DeactivateConfig "' .. configPath .. '"]'
        bangs[#bangs + 1] = '[!Redraw]'
    end

    SKIN:Bang(table.concat(bangs))
end
