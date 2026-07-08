
-- LuaBatteryRIng v1.0
-- By Chamika N Lakshan
-- Contact: Chamiknlakshan@gmail.com

local TWO_PI = math.pi * 2

local timeHit100 = 0
local FULL_CHARGE_WAIT_SEC = 300

local lastState = {
    pct = -1,
    saver = "",
    ac = -1,
    color = "",
    showChargingIcon = nil,
    useGreenIcon = nil,
    theme = ""
}

function Initialize()
end

function Update()

    local pct   = SKIN:GetMeasure('MeasureBattery'):GetValue()
    local saver = SKIN:GetMeasure('MeasureBatterySaver'):GetStringValue()

    saver = saver:match("^%s*(.-)%s*$")
    local ac = SKIN:GetMeasure('MeasureACStatus'):GetValue()
    local theme = SKIN:GetVariable('ThemeBattery')

    local color = '50,215,75,255'
    if saver == '1' then
        color = '255,204,0,255'
    elseif pct <= 20 then
        color = '255,59,48,255'
    else
        color = '50,215,75,255'
    end

    local showChargingIcon = false
    local useGreenIcon = false

    if ac == 1 then
        if pct >= 100 then
            if timeHit100 == 0 then
                timeHit100 = os.time()
            end
            local elapsed = os.time() - timeHit100
            if elapsed < FULL_CHARGE_WAIT_SEC then
                showChargingIcon = true
                useGreenIcon = true
            else
                showChargingIcon = false
                useGreenIcon = false
            end
        else
            timeHit100 = 0
            showChargingIcon = true
            useGreenIcon = false
        end
    else
        timeHit100 = 0
        showChargingIcon = false
        useGreenIcon = false
    end

    if pct ~= lastState.pct or saver ~= lastState.saver or ac ~= lastState.ac or color ~= lastState.color or showChargingIcon ~= lastState.showChargingIcon or useGreenIcon ~= lastState.useGreenIcon or theme ~= lastState.theme then

        if showChargingIcon then
            SKIN:Bang('!ShowMeter', 'ChargingIcon')
            if saver == '1' then
                SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageName', '#@#Images/Battery/Dark/Charging.png')
                SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageTint', '255,204,0')
            elseif useGreenIcon then
                SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageName', '#@#Images/Battery/Dark/Charging.png')
                SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageTint', '50,215,75')
            else
                SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageName', '#@#Images/Battery/#ThemeBattery#/Charging.png')
                if theme == 'Dark' then
                    SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageTint', '255,255,255')
                else
                    SKIN:Bang('!SetOption', 'ChargingIcon', 'ImageTint', '')
                end
            end
        else
            SKIN:Bang('!HideMeter', 'ChargingIcon')
        end

        SKIN:Bang('!UpdateMeter', 'ChargingIcon')
        
        DrawRing(color, showChargingIcon)

        lastState.pct = pct
        lastState.saver = saver
        lastState.ac = ac
        lastState.color = color
        lastState.showChargingIcon = showChargingIcon
        lastState.useGreenIcon = useGreenIcon
        lastState.theme = theme
    end

    return ''
end

function DrawRing(color, showGap)
    local pct   = SKIN:GetMeasure('MeasureBattery'):GetValue()
    local h     = tonumber(SKIN:GetVariable('Bat.Height')) or 200
    local scale = tonumber(SKIN:GetVariable('ScaleDpi'))   or 1

    local rRatio = tonumber(SKIN:GetVariable('RingRadiusRatio')) or (20 / 100)
    local tRatio = tonumber(SKIN:GetVariable('RingThicknessRatio')) or 0.037
    local bgTRatio = tonumber(SKIN:GetVariable('RingBGThicknessRatio')) or 0.037

    local size = h * scale
    local cx   = size / 2
    local cy   = size * 0.40
    local r    = size * (rRatio - tRatio / 2)
    local bgR  = size * (rRatio - bgTRatio / 2)
    local sw   = size * tRatio
    local bgSw = size * bgTRatio

    local startAngleDeg = -88
    local maxSweep = 359.5
    local bgStartDeg = -90
    local bgSweep = 359.5
    
    if showGap then
        startAngleDeg = -68
        maxSweep = 320
        bgStartDeg = -68
        bgSweep = 320
    end

    local sweepDeg = math.min(pct / 100 * maxSweep, maxSweep)
    sweepDeg = math.max(1, sweepDeg)

    local startRad = math.rad(startAngleDeg)
    local endRad   = startRad + math.rad(sweepDeg)

    local sx = cx + r * math.cos(startRad)
    local sy = cy + r * math.sin(startRad)
    local ex = cx + r * math.cos(endRad)
    local ey = cy + r * math.sin(endRad)

    local arcSize = sweepDeg > 180 and 1 or 0

    local shape = string.format(
        'Arc %.3f,%.3f,%.3f,%.3f,%.3f,%.3f,0,0,%d | StrokeWidth %.3f | Stroke Color %s | StrokeStartCap round | StrokeEndCap round | Fill Color 0,0,0,0',
        sx, sy, ex, ey, r, r, arcSize, sw, color
    )
    
    local bgStartRad = math.rad(bgStartDeg)
    local bgEndRad   = bgStartRad + math.rad(bgSweep)
    local bgSx = cx + bgR * math.cos(bgStartRad)
    local bgSy = cy + bgR * math.sin(bgStartRad)
    local bgEx = cx + bgR * math.cos(bgEndRad)
    local bgEy = cy + bgR * math.sin(bgEndRad)
    local bgArcSize = bgSweep > 180 and 1 or 0
    
    local bgColor = SKIN:GetMeter('MeterBatteryRingBG'):GetOption('LineColor')
    if not bgColor or bgColor == '' then bgColor = '174,174,178,160' end

    local bgShape = string.format(
        'Arc %.3f,%.3f,%.3f,%.3f,%.3f,%.3f,0,0,%d | StrokeWidth %.3f | Stroke Color %s | StrokeStartCap round | StrokeEndCap round | Fill Color 0,0,0,0',
        bgSx, bgSy, bgEx, bgEy, bgR, bgR, bgArcSize, bgSw, bgColor
    )

    SKIN:Bang('!SetOption', 'MeterBatteryRingBG', 'Shape', bgShape)
    SKIN:Bang('!SetOption', 'MeterBatteryRing', 'Shape', shape)
    SKIN:Bang('!UpdateMeter', 'MeterBatteryRingBG')
    SKIN:Bang('!UpdateMeter', 'MeterBatteryRing')
    SKIN:Bang('!Redraw')
end
