---@class TestACR : AbstractACR
Zeus.TestACR = {
    moduleType = ZeusTypes.ModuleType.ACR,
    moduleName = "Zeus.TestACR", -- Must be the object above
    tab = {
        acrName = "ZeusTestACR",
        name = "TestACR",
        tooltip = "TestACR Settings",
    },
}


local self = Zeus.TestACR -- this is where all our stuff gets stored.

local dispatch = function(...)
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


self.GUI = {
    name = self.moduleName, -- used for ACR persisting settings
    open = false,
}

self.classes = {
    [FFXIV.JOBS.MACHINIST] = true, -- used to differentiate between what classes are supported
}
function self.HotShotCD()
    return ActionList:Get(1,2872).cd
end
function self.Cast()
            if(Zeus.Debug.Console.info ~= nil) then
                Zeus.Debug.Console.info('returning false')
                return false
            end
    --if(Zeus.Debug.Console.info ~= nil) then
    --    Zeus.Debug.Console.info('cd: ' .. self.HotShotCD())
    --end
    -- loop through a table and print the key/value pairs from the table ActionList:Get(1,2872)
    --for k,v in pairs(reference1) do
    --    if(type(v) == 'function') then
    --        if(Zeus.Debug.Console.info ~= nil) then
    --            Zeus.Debug.Console.info(k)
    --        end
    --    else
    --        if(Zeus.Debug.Console.info ~= nil) then
    --            Zeus.Debug.Console.info(k .. ' ' .. tostring(v))
    --            --Zeus.Debug.Console.info('type' .. type(v))
    --        end
    --    end
    --end
end


function self.OnOpen()
    if(Zeus.Interface.open ~= nil) then
        Zeus.Interface.open = not Zeus.Interface.open
    end
end

function self.options() -- example options
    local options = {
        {
            label = "Test Options",
            type = "group",
            items = {
                {
                    type = "row",
                    items = {
                        {
                            label = "Healing",
                            type = "checkbox",
                            id = "thisisatest",
                            default = true
                        },
                        {
                            type = "blank",
                        },
                        {
                            label = "DPS",
                            type = "checkbox",
                            id = "thisisanothertest",
                            default = true
                        },
                    }
                },
                {
                    type = "row",
                    items= {
                        {
                            label = "Test Slider",
                            type = "label",
                        },
                        {
                            type = "slider",
                            id = "testSlider",
                            min = 50,
                            max = 100,
                            default = 90,
                            span = 2,
                        },

                    }
                },
            }
        },
    }
    return options
end

dispatch('Zeus.Events.ACRAvailable', {self.moduleName, self.tab, self.options(), ''}, 'low', true)

return self
