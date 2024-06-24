--- GENERAL

---@module d
---@param message string|table
---@return void
--- https://wiki.mmominion.com/doku.php?id=minionlib#general
function d(message) end

---@module stacktrace
---@return void
--- Prints out the current call stack into the console.
function stacktrace()  end

---@module Exit
---@return void
--- Closes the current game instance
function Exit() end

---@module ml_debug
---@return void
--- Prints our the passed variable or the result of a function into the console when gEnableLog == “1”.
function ml_debug(message)  end

---@module ml_error
---@return void
--- Prints our the passed variable or the result of a function into the console.
function ml_error(message)  end

---@module ml_log
---@return void
--- Adds the string to the statusbar-line which gets shown on each pulse.
function ml_log(message)  end

---@module Now
---@return number
--- Returns tickcount from ml_global_information.Now
function Now() end

---@module RegisterEventHandler
---@return void
--- Registers a local handler to an event
function RegisterEventHandler(eventName, handler, idenfitier)  end

---@module Reload
---@return boolean
--- Returns boolean, reloads all lua modules
function Reload() end

---@module TimeSince
---@return number
--- Returns integer `ml_global_information.Now` - `previousTime`
function TimeSince(time)  end

---@module Unload
---@return boolean
--- Returns boolean, unloads all lua modules
function Unload() end


---@module QueueEvent
---@return void
---@param eventName string
---@param argument1 string
---@param argument2 string|void
---@param argument3 string|void
---@param argument4 string|void
---Queues and Fires the Event with 1-n arguments. eventName and arguments must be strings.
function QueueEvent(eventName, argument1, argument2, argument3, argument4)  end