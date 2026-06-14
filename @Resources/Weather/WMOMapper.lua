function Update()
    local theme    = SKIN:GetVariable('ThemeWeather') or 'Light'
    local folder   = (theme == 'Dark') and 'Dark' or 'Light'
    local basePath = SKIN:GetVariable('@') .. 'Weather\\Icons\\' .. folder .. '\\'

    local measure = SKIN:GetMeasure('MeasureWeatherCode')
    if not measure then 
        SKIN:Bang('!SetOption', 'MeterIcon', 'ImageName', basePath .. 'cloudy.png')
        SKIN:Bang('!UpdateMeter', 'MeterIcon')
        SKIN:Bang('!Redraw')
        return
    end

    local wmoCode = measure:GetStringValue()
    if not wmoCode or wmoCode == '' then 
        SKIN:Bang('!SetOption', 'MeterIcon', 'ImageName', basePath .. 'cloudy.png')
        SKIN:Bang('!UpdateMeter', 'MeterIcon')
        SKIN:Bang('!Redraw')
        return
    end

    local hour  = tonumber(os.date('%H'))
    local isDay = (hour >= 6 and hour < 18)
    
    local iconName = GetIconName(wmoCode, isDay)
    SKIN:Bang('!SetOption', 'MeterIcon', 'ImageName', basePath .. iconName .. '.png')
    SKIN:Bang('!UpdateMeter', 'MeterIcon')
    SKIN:Bang('!Redraw')
    return 1
end

function GetIconName(wmoCode, isDay)
    local code = tonumber(wmoCode)
    if not code then return 'cloudy' end

    code = math.floor(code)

    if code == 0 or code == 1 then
        return isDay and 'clear-day' or 'clear-night'
    elseif code == 2 then
        return isDay and 'partly-cloudy-day' or 'partly-cloudy-night'
    elseif code == 3 then
        return 'cloudy'
    end

    if code == 45 or code == 48 then return 'fog' end
    if code == 5 then return 'cloudy' end
    if code == 51 or code == 53 or code == 55 then return isDay and 'drizzle-day' or 'drizzle-night' end
    if code == 56 or code == 57 or code == 66 or code == 67 then return 'sleet' end
    if code == 61 or code == 63 or code == 80 or code == 81 then return 'rain' end
    if code == 65 or code == 82 then return 'heavy-rain' end
    if code == 71 or code == 73 or code == 77 or code == 85 then return 'snow' end
    if code == 75 or code == 86 then return 'heavy-snow' end
    if code == 95 or code == 96 or code == 99 then return 'thunderstorm' end

    return 'cloudy'
end