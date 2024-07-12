Zeus.Settings = {
    moduleName = "Zeus.Settings",
}
local self = Zeus.Settings
local store = {}
local options = {}

local function log (...)
    local message = Zeus.Debug.Console.parse(arg)
    if (Zeus.Debug ~= nil) then
        if (Zeus.Debug.Console.log ~= nil) then
            Zeus.Debug.Console.log(message, self.moduleName)
        end
    end
end
local function logWarning(...)
    local message = Zeus.Debug.Console.parse(arg)
    if (Zeus.Debug ~= nil) then
        if (Zeus.Debug.Console.warning ~= nil) then
            Zeus.Debug.Console.warning(message, self.moduleName)
        end
    end
end
local function logError(...)
    local message = Zeus.Debug.Console.parse(arg)
    if (Zeus.Debug ~= nil) then
        if (Zeus.Debug.Console.error ~= nil) then
            Zeus.Debug.Console.error(message, self.moduleName)
        end
    end
end


function self.hashedKey(module, key)
    log('hashedKey: ' .. module .. '.' .. key)
    return module .. '.' .. key
end

function self.getSetting(module, key, default)
    if (store[module] == nil) then
        log("module didn't exist")
        store[module] = {}
    end
    if (store[module][key] == nil) then
        if(module.type ~= nil) then
            if(module.type == ZeusType.ModuleType.ACR) then
                log('module is ACR')
                store[module][key] = ACR.GetSetting(self.hashedKey(module, key), default)
                return store[module][key]
            end
        end
        log("value didn't exist, using default")
        --- Get settings from DB
        log('getSetting: ' .. module .. '.' .. key)
        local value = Zeus.Database.readOne('zeus_' .. module, key)
        store[module][key] = value or default
    end
    return store[module][key]
end

function self.setSetting(module, key, value, persist)
    if (store[module] == nil) then
        store[module] = {}
    end
    store[module][key] = value
    if(persist == true) then
        self.toDB(module, key, value)
    end

    ACR.SetGUIVar(value, self.hashedKey(module, key))
end

function self.toDB(hashedKey, value)
    --- @type Zeus.Database
    local database = Zeus.Database
    if(database == nil) then
        logWarning('database module not available')
        return
    end
    --database.
    --- Insert or replace the value into the database
    local query = [[INSERT OR REPLACE INTO settings (hashed_key, value) VALUES (']] .. hashedKey .. [[', ']] .. value .. [[');]]
    database:exec(query)




    --database:exec(query)
end



function self.onSaveSetting(_, module, key, value)
    module = json.decode(module)
    key = json.decode(key)
    value = json.decode(value)
    if(string.sub(module, 1, 1 ) == '"') then
        module = json.decode(module)
    end

    self.setSetting(module, key, value)
end

function self.loadOptions(moduleName)
    if (options[moduleName] ~= nil) then
        local moduleOptions = options[moduleName]
        return self.parseOptions(moduleOptions)
    else
        logWarning('Module options not available to be loaded. [moduleName' .. moduleName .. ']')
    end
end

function self.onInitialize(_, ...)
    --log('onInitialize - load sqlite3')
    --if(Zeus.paths.database ~= nil) then
    --    local path = Zeus.paths.database
    --    sqlite3 = _G["sqlite3"]
    --    database = sqlite3.open(path)
    --else
    --    logWarning('database path not available')
    --end
    --
    --if(database ~= nil) then
    --
    --else
    --    logWarning('database not loaded -- unable to pull settings')
    --end
end

function self.persist()
    log('persist')
    for module, moduleSettings in pairs(store) do
        for key, value in pairs(moduleSettings) do
            self.toDB(module, key, value)
        end
    end
end

function self.onACROptions(_, acrModuleName, acrOptions)
    options[acrModuleName] = json.decode(acrOptions)
end

function self.addACR(_, transmitterModule, encodedTab, encodedOptions)
    --if(sqlite3 == nil) then
    --    logWarning('sqlite3 module not available')
    --    return
    --end
    --if(database == nil) then
    --    logWarning('database not available')
    --    return
    --end
    --local decodedTab = json.decode(encodedTab)
    --decodedTab.options = json.decode(encodedOptions)
    --if(decodedTab.moduleName ~= nil) then
        -- sql
        --local sql = [[INSERT INTO acr (acr_name,active,usable,created_at) VALUES (
        --    ']] .. decodedTab.moduleName .. [[', 0, 0, DateTime('now'));]]
        --if(sqlite3.complete(sql)) then
        --    if(database:isopen()) then
        --        log('database is open')
        --        local result = database:exec(sql)
        --        d('dbchanges', database:changes())
        --        log('result: ' .. tostring(result))
        --        local closeResult = database:close()
        --        log('closeResult: ' .. tostring(closeResult))
        --    else
        --        log('database is not open')
        --    end
        --
        --    log('result: ' .. tostring(result))
        --end
        --d('sql valid', sqlite3.complete(sql))
        --log('addACR: ' .. decodedTab.moduleName)
        --log('sql valid: ' .. tostring(sqlite3.complete(sql)))
    --end
end

RegisterEventHandler("Module.Initalize", self.onInitialize, "Zeus.Settings.onInitialize")

-- Custom Events
RegisterEventHandler("Zeus.Events.ACROptions", self.onACROptions, "Zeus.Settings.onACROptions")
RegisterEventHandler("Zeus.Settings.SaveSetting", self.onSaveSetting, "Zeus.Settings.onSaveSetting")
RegisterEventHandler("Zeus.Events.LoadACR", self.addACR, "Zeus.Settings.addACR")
