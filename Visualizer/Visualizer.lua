
-- LuaCalendar v1.0
-- By Chamika N Lakshan
-- Contact: Chamiknlakshan@gmail.com

local NUM_BANDS = 32
local BAR_WIDTH = 6
local BAR_STEP  = 12     -- BAR_WIDTH + BAR_GAP (6+6)
local MAX_HALF  = 75
local CENTER_Y  = 80
local CORNER_R  = 3
local BAR_COLOR = '255,255,255,200'
local THRESHOLD = 0.005  -- below this = silent

-- Localize hot-path math functions
local floor = math.floor
local max   = math.max
local min   = math.min
local fmt   = string.format

local measures   = {}   -- measures[i] = measure object
local meterNames = {}   -- meterNames[i] = "MeterBar0" .. "MeterBar31"
local prevLevel  = {}   -- prevLevel[i]  = last rendered level (dirty check)

local function makeShape(i, level)
    local half = MAX_HALF * level
    local bx   = i * BAR_STEP
    local by   = floor(CENTER_Y - half)
    local bh   = max(1, floor(half * 2))
    local r    = min(CORNER_R, floor(min(BAR_WIDTH, bh) / 2))
    return fmt('Rectangle %d,%d,%d,%d,%d | Fill Color %s | StrokeWidth 0',
               bx, by, BAR_WIDTH, bh, r, BAR_COLOR)
end

function Initialize()
    for i = 0, NUM_BANDS - 1 do
        meterNames[i] = 'MeterBar' .. i
        measures[i]   = SKIN:GetMeasure('MeasureBand' .. i)
        prevLevel[i]  = -1  -- force first-frame update for all bars
        SKIN:Bang('!HideMeter', meterNames[i])
    end
    SKIN:Bang('!Redraw')
end

function Update()
    local redrawNeeded = false

    for i = 0, NUM_BANDS - 1 do
        local level = measures[i] and measures[i]:GetValue() or 0

        level = floor(level * 1000 + 0.5) / 1000

        if level ~= prevLevel[i] then
            prevLevel[i] = level
            local name = meterNames[i]

            if level < THRESHOLD then
                SKIN:Bang('!HideMeter', name)
            else
                SKIN:Bang('!SetOption', name, 'Shape', makeShape(i, level))
                SKIN:Bang('!UpdateMeter', name)
                SKIN:Bang('!ShowMeter', name)
            end

            redrawNeeded = true
        end
    end

    if redrawNeeded then
        SKIN:Bang('!Redraw')
    end
end
