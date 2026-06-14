function Update()
    local manual = SKIN:GetVariable('ManualNote')
    local title = SKIN:GetMeasure('MeasureEventTitle'):GetStringValue()
    local time = SKIN:GetMeasure('MeasureEventTime'):GetStringValue()

    if manual ~= "" and manual ~= "No events today" then
        SKIN:Bang('!SetOption', 'MeterEventLabel', 'Text', manual)
        SKIN:Bang('!SetOption', 'MeterTimeLabel', 'Text', 'Personal Note')
    
    elseif title ~= "" then
        SKIN:Bang('!SetOption', 'MeterEventLabel', 'Text', title)
        SKIN:Bang('!SetOption', 'MeterTimeLabel', 'Text', time)
    
    else
        SKIN:Bang('!SetOption', 'MeterEventLabel', 'Text', 'No events today')
        SKIN:Bang('!SetOption', 'MeterTimeLabel', 'Text', '')
    end
end
