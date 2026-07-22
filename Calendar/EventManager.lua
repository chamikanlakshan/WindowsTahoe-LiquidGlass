-- this script shifts events up so there are no empty gaps between events.

function Initialize()
end

function Update()
    return ''
end

-- Reads all 5 notes from the file, removes empty slots, writes compacted
function CompactEvents()
    local varsPath = SKIN:GetVariable('@') .. 'Calendar\\Variables.inc'

    local keys = { 'ManualNote', 'ManualNote2', 'ManualNote3', 'ManualNote4', 'ManualNote5' }
    local keyIndex = {}
    for i, k in ipairs(keys) do
        keyIndex[k] = i
    end

    -- the user's latest input there before this function was called)
    local notes = { '', '', '', '', '' }
    local f = io.open(varsPath, 'r')
    if f then
        for line in f:lines() do
            local key, val = line:match('^%s*(%w+)%s*=%s*(.-)%s*$')
            if key and keyIndex[key] then
                notes[keyIndex[key]] = val
            end
        end
        f:close()
    end

    local compacted = {}
    for _, v in ipairs(notes) do
        if v ~= '' then
            compacted[#compacted + 1] = v
        end
    end

    for i, key in ipairs(keys) do
        local val = compacted[i] or ''
        SKIN:Bang('!WriteKeyValue', 'Variables', key, val, varsPath)
    end
end
