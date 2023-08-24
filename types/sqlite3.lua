--- @class sqlite3
local sqlite3 = {}

--------------------------------------------------------------------------------
--- @class sqlite3_Statement
local Statement = {}

--- Binds the given values to statement parameters. The function returns
--- sqlite3.OK on success or else a numerical error code
--- (see Numerical error and result codes).
--- @vararg any
--- @return number
function Statement:bind_values(...) end

--- This function frees prepared statement stmt. If the statement was executed
--- successfully, or not executed at all, then sqlite3.OK is returned.
--- If execution of the statement failed then an error code is returned.
function Statement:finalize() end

--------------------------------------------------------------------------------
--- @class sqlite3_Database
local Database = {}

--- @param sql string Sql query
--- @return sqlite3_Statement
function Database:prepare(sql) end

--- Compiles and executes the SQL statement(s) given in string sql.
--- The statements are simply executed one after the other and not stored.
--- The function returns sqlite3.OK on success or else a numerical error code
--- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki#numerical_error_and_result_codes
--- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki#db_exec
--- @param sql string Sql query
--- @param func function(udata,cols,values,names) | nil -- ensure function returns 0 each loop or will abort exec
--- @param udata any | nil
function Database:exec(sql, func, udata) end

--- Creates an iterator that returns the successive rows selected by the
--- SQL statement given in string sql. Each call to the iterator returns
--- the values that correspond to the columns in the currently selected row.
--- @param sql string Sql query
--- @return fun():any
function Database:urows(sql) end

--- Creates an iterator that returns the successive rows selected by the SQL
--- statement given in string sql. Each call to the iterator returns a table
--- in which the named fields correspond to the columns in the database.
------ @param sql string Sql query
----- @return fun():any
function Database:nrows(sql) end

--- Returns true if database db is open, false otherwise.
--- @return boolean
function Database:isopen() end

--------------------------------------------------------------------------------
--- Returns true if the string sql comprises one or more
--- complete SQL statements and false otherwise.
--- @param sql string
--- @return boolean
function sqlite3.complete(sql) end

--- Opens (or creates if it does not exist) an SQLite database with
--- name filename and returns its handle as userdata (the returned object
--- should be used for all further method calls in connection with this
--- specific database, see Database methods).
--- @param filename string Filename
--- @return sqlite3_Database
function sqlite3.open(filename) end

--- Returns a string with SQLite version information, in the form 'x.y[.z[.p]]'.
--- @return string
function sqlite3.version() end


return sqlite3
