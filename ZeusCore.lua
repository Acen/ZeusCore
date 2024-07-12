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
    lastWrite = nil,
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

---
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

function self.onModuleAvailable(_, ...)
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

    dispatch('Zeus.Events.LoadACR', {'ZeusCore', acrTab, settings, 'onModuleAvailable()'}, 'low', true)
end

function fileExists(filename)
    local file = io.open(filename, "r")
    if(file == nil) then
        return false
    else
        file:close()
        return true
    end
end

function self.lastWriteValueHumanReadable()
    if(Zeus.Core.lastWrite ~= nil) then
        return Zeus.Core.lastWrite
    else return "nil" end
end
function self.lastWriteValue()
    if(Zeus.Core.lastWrite ~= nil) then
        return Zeus.Core.lastWrite
    else return 0 end
end

function self.onUpdate()
    if(self.isInGame()) then

        -- currently dirty. todo package off to modules
        control = GetControl("MKSRecord")
        if(control) then
            log('control available')
            local data = control:GetRawData()
            local encodedData = json.encode(data)

            if(os.difftime(os.time(), self.lastWriteValue()) > 120) then
                log("Last write was over 120 seconds ago, continuing write.")
                local now = os.date("%Y%m%d%H%M")
                -- check if file exists before write
                local filename = "MKSRecord_" .. now .. ".json"
                if(not fileExists(filename)) then
                    log("File doesn't exist, writing record.")
                    local file = io.open("MKSRecord_" .. now .. ".json", "w")
                    file:write(encodedData)
                    file:close()
                    log("Previous lastWrite: " .. self.lastWriteValueHumanReadable())
                    log("Settings lastWrite to " .. os.time())
                    Zeus.Core.lastWrite = os.time()
                else
                    log("File exists, skipping write.")
                end
            else
                log("Last write was less than 120 seconds ago, skipping write.")
                log("os.difftime(os.time(), Zeus.Core.lastWrite): " .. os.difftime(os.time(), self.lastWriteValue()))
            end
        end
    end
end

RegisterEventHandler("Module.Initalize", self.onInitialize, "Zeus.Core.onInitialize")
RegisterEventHandler("Gameloop.Update", self.onUpdate, "Zeus.Core.onUpdate")
RegisterEventHandler("Zeus.Events.ModuleAvailable", self.onModuleAvailable, "Zeus.Core.onModuleAvailable")
