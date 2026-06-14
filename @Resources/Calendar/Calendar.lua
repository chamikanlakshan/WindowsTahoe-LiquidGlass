-- LuaCalendar v1.0
-- By Chamika N Lakshan
-- Contact: Chamiknlakshan@gmail.com

local _monthOffset = 0

local _scrollAccum = 0

local _isInitialized = false

function Initialize()
    Update()
    _isInitialized = true
end

function Update()
    local t = os.date("*t")
    local todayDay   = t.day
    local todayMonth = t.month
    local todayYear  = t.year

    local displayTime = os.time{year = todayYear, month = todayMonth + _monthOffset, day = 1}
    local dt = os.date("*t", displayTime)
    local currentDay   = todayDay      -- today's day number (for the highlight circle)
    local currentMonth = dt.month      -- month being displayed
    local currentYear  = dt.year       -- year being displayed
    local isCurrentMonth = (currentMonth == todayMonth and currentYear == todayYear)

    SKIN:Bang("!SetOption", "TodayCircle", "Hidden", "1")

    local months = {"JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"}
    SKIN:Bang("!SetOption", "mLabel", "Text", months[currentMonth] .. "  " .. tostring(currentYear))

    if _monthOffset == 0 then
        -- Triggers Rainmeter's built-in !Delay, followed by calling HideYear() in Lua
        SKIN:Bang("[!Delay 20000][!CommandMeasure Lua \"HideYear()\"]")
    end

    local firstDay = os.time{year=currentYear, month=currentMonth, day=1}
    local firstWeekday = tonumber(os.date("%w", firstDay)) 

    local daysInMonth = os.date("*t", os.time{year=currentYear, month=currentMonth+1, day=0}).day
    local daysInPrevMonth = os.date("*t", os.time{year=currentYear, month=currentMonth, day=0}).day

    local scale = SKIN:ParseFormula(SKIN:GetVariable("ScaleDpi", "1"))
    local Cw = SKIN:ParseFormula(SKIN:GetVariable("C.w", "0")) * scale
    local Ch = SKIN:ParseFormula(SKIN:GetVariable("C.h", "0")) * scale
    local Sx = SKIN:ParseFormula(SKIN:GetVariable("Space.x", "0")) * scale
    local Sy = SKIN:ParseFormula(SKIN:GetVariable("Space.y", "0")) * scale
    local CalSize = SKIN:ParseFormula(SKIN:GetVariable("CalSize", "500")) * scale
    local CalOffsetX = SKIN:ParseFormula(SKIN:GetVariable("CalOffsetX", "0")) * scale
    local CalW = SKIN:ParseFormula(SKIN:GetVariable("Cal.W", "0")) * scale
    local CalH = SKIN:ParseFormula(SKIN:GetVariable("Cal.H", "0")) * scale
    local CalFontSize = math.floor(SKIN:ParseFormula(SKIN:GetVariable("Cal.FontSize", "12")) * scale)

    local contentW = Cw * 7 + Sx * 6
    local contentH = Ch * 7 + Sy * 6
    local startX = math.floor((CalW - contentW) / 2)
    local startY = math.floor((CalH - contentH) / 2 + CalSize * 37 / 500)

    SKIN:Bang("!SetOption", "mLabel", "X", tostring(startX + 6 + CalOffsetX))
    SKIN:Bang("!SetOption", "mLabel", "Y", tostring(startY))
    SKIN:Bang("!SetOption", "mLabel", "W", tostring(contentW))
    SKIN:Bang("!SetOption", "mLabel", "H", tostring(Ch))
    SKIN:Bang("!SetOption", "mLabel", "FontSize", tostring(CalFontSize))

    local labels = {"S", "M", "T", "W", "T", "F", "S"}
    local lblY = startY + Ch + Sy
    for i = 0, 6 do
        local lx = startX + i * (Cw + Sx) + Cw / 2
        SKIN:Bang("!SetOption", "l" .. i, "Text", labels[i+1])
        SKIN:Bang("!SetOption", "l" .. i, "MeterStyle", "LblTxtSty")
        SKIN:Bang("!SetOption", "l" .. i, "X", tostring(math.floor(lx + CalOffsetX)))
        SKIN:Bang("!SetOption", "l" .. i, "Y", tostring(math.floor(lblY)))
        SKIN:Bang("!SetOption", "l" .. i, "FontSize", tostring(CalFontSize))
    end

    local cellStartX = startX
    local cellStartY = startY + Ch * 2 + Sy * 2
    local totalWeeks = math.ceil((firstWeekday + daysInMonth) / 7)

    for cell = 1, 42 do
        local col = (cell -1) % 7
        local row = math.floor((cell - 1) / 7)
        local dayNumber = cell - firstWeekday

        if totalWeeks == 6 and row == 5 then
            if dayNumber > 0 and dayNumber <= daysInMonth then
                row = 0
            end
        end

        local x = cellStartX + col * (Cw + Sx) + Cw / 2
        local y = cellStartY + row * (Ch + Sy)

        SKIN:Bang("!SetOption", "mDay" .. cell, "X", tostring(math.floor(x + CalOffsetX)))
        SKIN:Bang("!SetOption", "mDay" .. cell, "Y", tostring(math.floor(y)))
        SKIN:Bang("!SetOption", "mDay" .. cell, "FontSize", tostring(CalFontSize))

        if dayNumber < 1 then
            local prevDay = daysInPrevMonth + dayNumber
            SKIN:Bang("!SetOption", "mDay" .. cell, "Text", tostring(prevDay))
            SKIN:Bang("!SetOption", "mDay" .. cell, "MeterStyle", "TextStyle|PreviousMonth")
        elseif dayNumber > daysInMonth then
            local nextDay = dayNumber - daysInMonth
            SKIN:Bang("!SetOption", "mDay" .. cell, "Text", tostring(nextDay))
            SKIN:Bang("!SetOption", "mDay" .. cell, "MeterStyle", "TextStyle|NextMonth")
        else
            SKIN:Bang("!SetOption", "mDay" .. cell, "Text", tostring(dayNumber))
            
            if dayNumber == currentDay and isCurrentMonth then
                SKIN:Bang("!SetOption", "mDay" .. cell, "MeterStyle", "TextStyle|CurrentDay")
                
                local radius = math.min(Cw, Ch) / 1.85
                local todayColor = SKIN:GetVariable("Cal.Color.Today", "255,56,60,255")
                
                local circleYOffset = -(CalSize / 300)
                local circleXOffset = 0.3
                
                -- Helper to force decimal dots (fixes Rainmeter bug where some regions use commas, breaking the shape)
                local function safeDec(val) return string.gsub(tostring(val), ",", ".") end
                
                local shapeStr = "Ellipse " .. safeDec(circleXOffset) .. "," .. safeDec(circleYOffset) .. "," .. safeDec(radius) .. " | Fill Color " .. todayColor .. " | StrokeWidth 0"
                
                SKIN:Bang("!SetOption", "TodayCircle", "Shape", shapeStr)
                SKIN:Bang("!SetOption", "TodayCircle", "X", tostring(math.floor(x + CalOffsetX)))
                SKIN:Bang("!SetOption", "TodayCircle", "Y", tostring(math.floor(y)))
                SKIN:Bang("!SetOption", "TodayCircle", "W", "0")
                SKIN:Bang("!SetOption", "TodayCircle", "H", "0")
                SKIN:Bang("!SetOption", "TodayCircle", "Hidden", "0")
            elseif col == 0 or col == 6 then
                SKIN:Bang("!SetOption", "mDay" .. cell, "MeterStyle", "TextStyle|WeekendStyle")
            else
                SKIN:Bang("!SetOption", "mDay" .. cell, "MeterStyle", "TextStyle")
            end
        end
    end
    -- Instantly update all meters and redraw the skin to make scrolling/clicking feel lightning fast!
    if _isInitialized then
        SKIN:Bang("[!UpdateMeter *][!Redraw]")
    end
end

function Move(amount)
    if amount == nil or amount == 0 then
        _monthOffset = 0
    else
        _monthOffset = _monthOffset + amount
    end
    Update()
end

function CombineScroll(amount)
    if amount == nil then return end
    _scrollAccum = _scrollAccum + amount
    if math.abs(_scrollAccum) >= 1 then
        local direction = _scrollAccum > 0 and 1 or -1
        _scrollAccum = 0
        Move(direction)
    end
end

function HideYear()
    if _monthOffset == 0 then
        local t = os.date("*t")
        local currentMonth = t.month
        local months = {"JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"}
        SKIN:Bang("!SetOption", "mLabel", "Text", months[currentMonth])
        SKIN:Bang("!UpdateMeter", "mLabel")
        SKIN:Bang("!Redraw")
    end
end
