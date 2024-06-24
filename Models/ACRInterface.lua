---@class AbstractACR
local AbstractACR = {}

local self = AbstractACR

AbstractACR.classes = {
    --[FFXIV.JOBS.MACHINIST] = true, -- used to differentiate between what classes are supported
}

self.dispatch = function(...)
    local callDispatch
    if(callDispatch == nil) then
        if(Zeus.Events) then
            if(Zeus.Events.dispatch) then
                callDispatch = Zeus.Events.dispatch
            end
        end
    end
    if(callDispatch ~= nil) then
        callDispatch(unpack(arg))
    else
        if(Zeus.Debug.Console.error ~= nil) then
            Zeus.Debug.Console.error('Zeus.Events.dispatch not loaded', self.moduleName)
        end
    end
end

AbstractACR.GUI = {
    name = self.moduleName, -- used for ACR persisting settings
    open = false,
}


---@return boolean
function AbstractACR.Cast()
end

function AbstractACR.OnOpen()
    if(Zeus.Interface.open ~= nil) then
        Zeus.Interface.open = not Zeus.Interface.open
    end
end

function AbstractACR.Options()
    return {
        {
            label = "Options",
            type = "group"
        }
    }

end