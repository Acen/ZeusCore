---@class Zeus
Zeus = {
    moduleName = "Zeus.Core",
    paths = {
        mods = GetLuaModsPath(),
        module = GetLuaModsPath() .. [[ZeusCore\]],
        database = GetLuaModsPath() .. [[ZeusCore\]] .. [[ZeusCore.db]],
        image = GetLuaModsPath() .. [[ZeusCore\]] .. [[Images\]],
    },
}
---@class Zeus.Core
Zeus.Core = {
    availableACR = {},
    classAbilities = {},
}
local self = Zeus.Core
local dispatch = function(...)
    local callDispatch = nil
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

function self.onInitialize(_)
    log('onInitialize')
end

function self.isInGame()
    return FFXIV.GAMESTATE.INGAME == GetGameState()
end

--- todo: cleanup some inside-core ref (move to helpers?)
function self.filterTable(rawTable, filter)
    local filteredTable = {}
    for key, value in pairs(rawTable) do
        if(filter(value)) then
            filteredTable[key] = value
        end
    end
    return filteredTable
end

function self._filterUnusableAction(action)
    return action.usable
end

function self._getUsableClassAbilities(playerClassID)
    -- 1 = Actions
    -- @todo filter to only the classes we have ACRs for.
    local actionTypeID = 1
    local rawActionList = ActionList:Get(actionTypeID)
    local filteredActionList = {}
    for _, action in pairs(rawActionList) do
        if(action.name ~= nil and action.name ~= "") then
            if(action.usable and action.job == playerClassID) then
                filteredActionList[action.id] = {
                    id = action.id,
                    name = action.name,
                    type = action.type,
                    range = action.range,
                    usable = action.usable,
                    cost = action.cost,
                    castTime = action.casttime,
                    recastTime = action.recasttime,
                    costType = action.primarycosttype
                }
            end
        end
        -- note to self, userdata being used (C memory) so we just have to know the variables.
        --if(action.name ~= nil and action.name ~= "") then
        --    if(action.usable and action.job == FFXIV.JOBS.SAGE) then
        --        d(getmetatable(action))
        --    end
        --    --filteredActionList[action.id] = {
        --    --    id = action.id,
        --    --    name = action.name,
        --    --    type = action.type,
        --    --    range = action.range,
        --    --    usable = action.usable,
        --    --
        --    --}
        --end
    end
    return filteredActionList
end

function self.loadClassAbilities(force)
    log('loadClassAbilities force: ' .. tostring(force))
    if(force == nil) then
        force = false
    end
    local currentClassID = Player.job
    if(currentClassID == nil) then
        log('currentClassID is nil.')
        return
    end
    if(#self.classAbilities[currentClassID] > 0) then
        if(force) then
            log('Reloading class abilities [classID: ' .. currentClassID .. ']')
            self.classAbilities[currentClassID] = self._getUsableClassAbilities(currentClassID)
        else
            log('Class abilities already loaded [classID: ' .. currentClassID .. ']')
        end
    else
        self.classAbilities[currentClassID] = self._getUsableClassAbilities(currentClassID)
    end
end

function self.onACRAvailable(_, ...)
    local acrModuleName = arg[1]
    local tab = json.decode(arg[2])
    local settings = json.decode(arg[3])
    local acrTab = {
        ['moduleName'] = acrModuleName,
        acrName = tab.acrName,
        name = tab.name,
        tooltip = tab.tooltip,
    }

    table.insert(self.availableACR, acrModuleName)

    dispatch('Zeus.Events.LoadACR', {'ZeusCore', acrTab, settings, 'onACRAvailable()'}, 'low', true)
end

RegisterEventHandler("Module.Initalize", self.onInitialize, "Zeus.Core.onInitialize")
RegisterEventHandler("Gameloop.Update", self.onUpdate, "Zeus.Core.onUpdate")
RegisterEventHandler("Zeus.Events.ACRAvailable", self.onACRAvailable, "Zeus.Core.onACRAvailable")
