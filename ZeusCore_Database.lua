--- @class Zeus.Database
Zeus.Database = {
    moduleName = "Zeus.Database",
}

local self = Zeus.Database

---@type sqlite3 | nil
local sqlite3
---@type sqlite3_Database | nil
local database

local function log(...)
    local message = Zeus.Debug.Console.parse(arg)
    if (Zeus.Debug ~= nil) then
        if (Zeus.Debug.Console.info ~= nil) then
            Zeus.Debug.Console.info(message, self.moduleName)
        end
    end
end

local function logSuccess(...)
    local message = Zeus.Debug.Console.parse(arg)
    if (Zeus.Debug ~= nil) then
        if (Zeus.Debug.Console.success ~= nil) then
            Zeus.Debug.Console.success(message, self.moduleName)
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

local function openDatabase()
    if (sqlite3 == nil) then
        sqlite3 = _G["sqlite3"]
    end
    if(Zeus.paths.database == nil) then
        logError('database path not set')
        return
    end
    if (database == nil) then
        database, code, message = sqlite3.open(Zeus.paths.database)
    end
    if(database == nil) then
        logError('database open failed: ' .. message)
        logError('code: ' .. code)
    end
end

local function closeDatabase()
    if(database:isopen()) then
        database:close()
    end
end

--- @param query string
--- @param callback function(udata, cols, values, names)
--- @param validation string
local function executeWithCallback(query, callback, validation)
    openDatabase()
    local result
    if(validation == nil) then
        validation = "execute_with_callback"
    end
    if (database ~= nil) then
        result = database:exec(query, callback, validation)
    end
    if(result == 0) then
        logSuccess('exec for query "' .. query .. '" was successful')
    end
    database:close()
end

local function execute(query)
    openDatabase()
    return database:nrows(query), database:close()
    --local result
    --if (database ~= nil) then
    --    result = database:exec(query)
    --    log('execute result: ' .. result)
    --end
    --if(result == 0) then
    --    logSuccess('exec for query "' .. query .. '" was successful')
    --end
    --database:close()
end

--- @param table string
--- @param key string
function self.readAll(table, key)
    local query = "SELECT value FROM " .. table .. " WHERE key = '" .. key .. "'"
    local values = {}
    openDatabase()
    if (database ~= nil) then
        for row in database:nrows(query) do
            table.insert(values, row.value)
        end
    end
    database:close()
    return values
end

function self.readOne(table, key)
    openDatabase()
    local query = [[SELECT value FROM ]] .. table .. [[ WHERE key = ']] .. key .. [[' LIMIT 1]]
    local result
    -- @todo make pcall usage consistent
    local protectedCall, response = pcall(function()
        for row in database.nrows(query) do
            result = row.value
        end
        database:close()
    end)
    return result
end

local function transposeIntToBoolean(input)
    if(input == nil) then
        -- Proper exceptions!
        error('input is nil - expected 1 or 0')
    end
    if(input == 1) then
        return true
    else
        return false
    end
end

function self.exists(table, columnKey, columnValue)
    local query = 'SELECT EXISTS(SELECT 1 FROM ' .. table .. ' WHERE ' .. columnKey .. ' = "' .. columnValue .. '") as "exists"'
    local result
    local protectedCall, response = pcall(function()
        for row in database:nrows(query) do
            result = transposeIntToBoolean(row.exists)
        end
        closeDatabase()
        return result
    end)
    if not protectedCall then
        closeDatabase()
        logError('error: ' .. tostring(response))
        -- tbc handle gracefully
        return nil
    end
    return response
end

function self.updateValue(table, column, key, value)
    local query = "UPDATE " .. table .. " SET value = '" .. value .. "' WHERE " .. column .. " = '" .. key .. "'"
    execute(query)
end

function self.insertValue(table, column, key, value)
    local query = "INSERT OR REPLACE INTO " .. table .. " (" .. column ..", value) VALUES ('" .. key .. "', '" .. value .. "')"
    execute(query)
end

function self.insertOrIgnore(table, column, key, value)
    local query = "INSERT OR IGNORE INTO " .. table .. " (" .. column ..", value) VALUES ('" .. key .. "', '" .. value .. "')"
    execute(query)
end

--function self.updateOrInsert(table,column,key,value)
--    if()
--
--end

function self.rawQuery(query)
    execute(query)
end

function self.onInitialize(_)
    --database:close()
    openDatabase()
    local exists = self.exists("acr", "name", "test")
    log('exists: ' .. tostring(exists))
    if(database:isopen()) then
        database:close()
    end
end

RegisterEventHandler("Module.Initalize", self.onInitialize, "Zeus.Core.onInitialize")
