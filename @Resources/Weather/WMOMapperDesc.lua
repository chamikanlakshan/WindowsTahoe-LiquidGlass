function Update()
    local measure = SKIN:GetMeasure('MeasureWeatherCode')
    if not measure then 
        SKIN:Bang('!SetOption', 'MeterSummary', 'Text', 'Missing Measure')
        SKIN:Bang('!UpdateMeter', 'MeterSummary')
        SKIN:Bang('!Redraw')
        return
    end

    local wmoCode = measure:GetStringValue()
    if not wmoCode or wmoCode == '' then 
        SKIN:Bang('!SetOption', 'MeterSummary', 'Text', 'Fetching...')
        SKIN:Bang('!UpdateMeter', 'MeterSummary')
        SKIN:Bang('!Redraw')
        return
    end

    local hour  = tonumber(os.date('%H'))
    local isDay = (hour >= 6 and hour < 18)

    local description = GetDescription(wmoCode, isDay)
    SKIN:Bang('!SetOption', 'MeterSummary', 'Text', description)
    SKIN:Bang('!UpdateMeter', 'MeterSummary')
    SKIN:Bang('!Redraw')
    return 1
end

function GetDescription(wmoCode, isDay)
    local code = tonumber(wmoCode)
    if not code then return 'Format Error' end

    code = math.floor(code)

    if code == 0 then return isDay and 'Sunny' or 'Clear' end
    if code == 1 then return isDay and 'Mostly Sunny' or 'Mostly Clear' end
    if code == 2 then return 'Partly Cloudy' end
    if code == 3 then return 'Cloudy' end
    if code == 5 then return 'Cloudy' end

    if code == 45 or code == 48 then return 'Fog' end
    if code == 51 or code == 53 or code == 55 then return 'Drizzle' end
    if code == 56 or code == 57 or code == 66 or code == 67 then return 'Sleet' end
    if code == 61 or code == 63 or code == 80 or code == 81 then return 'Rain' end
    if code == 65 or code == 82 then return 'Heavy Rain' end
    if code == 71 or code == 73 or code == 77 or code == 85 then return 'Snow' end
    if code == 75 or code == 86 then return 'Heavy Snow' end
    if code == 95 or code == 96 or code == 99 then return 'Thunderstorm' end

    return 'Code: ' .. code
endfunction Update()
    local measure = SKIN:GetMeasure('MeasureWeatherCode')
    if not measure then 
        SKIN:Bang('!SetOption', 'MeterSummary', 'Text', 'Missing Measure')
        SKIN:Bang('!UpdateMeter', 'MeterSummary')
        SKIN:Bang('!Redraw')
        return
    end

    local wmoCode = measure:GetStringValue()
    if not wmoCode or wmoCode == '' then 
        SKIN:Bang('!SetOption', 'MeterSummary', 'Text', 'Fetching...')
        SKIN:Bang('!UpdateMeter', 'MeterSummary')
        SKIN:Bang('!Redraw')
        return
    end

    local hour  = tonumber(os.date('%H'))
    local isDay = (hour >= 6 and hour < 18)

    local description = GetDescription(wmoCode, isDay)
    SKIN:Bang('!SetOption', 'MeterSummary', 'Text', description)
    SKIN:Bang('!UpdateMeter', 'MeterSummary')
    SKIN:Bang('!Redraw')
    return 1
end

function GetDescription(wmoCode, isDay)
    local code = tonumber(wmoCode)
    if not code then return 'Format Error' end

    code = math.floor(code)

    if code == 0 then return isDay and 'Sunny' or 'Clear' end
    if code == 1 then return isDay and 'Mostly Sunny' or 'Mostly Clear' end
    if code == 2 then return 'Partly Cloudy' end
    if code == 3 then return 'Cloudy' end
    if code == 5 then return 'Cloudy' end

    if code == 45 or code == 48 then return 'Fog' end
    if code == 51 or code == 53 or code == 55 then return 'Drizzle' end
    if code == 56 or code == 57 or code == 66 or code == 67 then return 'Sleet' end
    if code == 61 or code == 63 or code == 80 or code == 81 then return 'Rain' end
    if code == 65 or code == 82 then return 'Heavy Rain' end
    if code == 71 or code == 73 or code == 77 or code == 85 then return 'Snow' end
    if code == 75 or code == 86 then return 'Heavy Snow' end
    if code == 95 or code == 96 or code == 99 then return 'Thunderstorm' end

    return 'Code: ' .. code
end
