Zeus.Events = {
    moduleName = "Zeus.Events",
}
local self = Zeus.Events
self.currentACR = "None"

self.options = {
    priorities = {
        low = {
            minimumTickLength = 1000,
        },
        medium = {
            minimumTickLength = 500,
        },
        high = {
            minimumTickLength = 250,
        },
    }
}

self.eventCache = {}

local function log (...)
    local message = Zeus.Debug.Console.parse(arg)
    if(message ~= nil) then
        if(message ~= nil and Zeus.Debug ~= nil) then
            if(Zeus.Debug.Console.log ~= nil) then
                Zeus.Debug.Console.log(message, self.moduleName)
            end
        end
    end
end

local function logError(...)
    local message = Zeus.Debug.Console.parse(arg)
    if(#message > 0) then
        if(message ~= nil and Zeus.Debug ~= nil) then
            if(Zeus.Debug.Console.error ~= nil) then
                Zeus.Debug.Console.error(message, self.moduleName)
            end
        end
    end
end

local function fire(eventName, eventArguments)
    if(eventArguments ~= nil and #eventArguments > 0) then
        QueueEvent(eventName, unpack(eventArguments))
    else
        QueueEvent(eventName, "")
    end
end


local function validateEventArguments(eventArguments)
    -- check event arguments table values are strings
    local argVal = {}
    for k, v in pairs(eventArguments) do
        if(type(v) == 'string' or type(v) == 'table' or type(v) == "number") then
            argVal[k] = true
        else
            logError('Event arguments must be strings or tables. ' .. type(v) .. ' given.')
            argVal[k] = false
        end
    end
    for _, boolean in pairs(argVal) do
        if(boolean == false) then
            return false
        end
    end
    return true
end

local function transposeToStrings(eventArguments)
    local args = {}
    for k, v in pairs(eventArguments) do
        --if(type(v) == 'table') then
            args[k] = json.encode(v)
        --else
        --    args[k] = v
        --end
    end
    args[#args + 1] = ''
    return args
end

function self.dispatch(eventName, eventArguments, priority, ignoreCache)
    if(not validateEventArguments(eventArguments)) then
        return
    end
    local transposedArguments = transposeToStrings(eventArguments)

    if(priority == nil) then
        priority = 'low'
    end
    if(ignoreCache == nil) then
        ignoreCache = false
    end

    local priorityTickLength = self.options.priorities[priority].minimumTickLength
    local currentTick = Now()

    if(not ignoreCache) then
        self.eventCache[eventName] = {
            lastTick = currentTick,
        }

        fire(eventName, transposedArguments)
    elseif(self.eventCache[eventName] == nil) then
        self.eventCache[eventName] = {
            lastTick = currentTick,
        }

        fire(eventName, transposedArguments)
    else
        local eventCache = self.eventCache[eventName]
        -- Last time this event was fired, was more than the minimum tick length ago
        if(eventCache.lastTick + priorityTickLength < currentTick) then
            eventCache.lastTick = currentTick
            fire(eventName, transposedArguments)
        end
    end
end

function self.onInitialize(_, ...)
    log('onInitialize')
end

function checkCurrentACR()
    local activeACR = gACRSelectedProfiles[Player.job]
    if(self.currentACR ~= activeACR) then
        self.dispatch('Zeus.Events.ACRChanged', {self.currentACR, activeACR, 'checkCurrentACR()'}, 'low')
    end
    self.currentACR = activeACR
end

function self.onUpdate(_, ...)
    checkCurrentACR()
end

RegisterEventHandler("Module.Initalize", self.onInitialize, "Zeus.Events.onInitialize")
RegisterEventHandler("Gameloop.Update", self.onUpdate, "Zeus.Events.onUpdate")
