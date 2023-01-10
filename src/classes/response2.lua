local json = require("json")
local mime = require("mime")
-- local fs = require("fs")
local coroFs = require("coro-fs")

--- Wrapped Response class for convenient use.
--- @class Response
local resMeta = {}

--- @private
resMeta._fail = false


--- Set the text response
--- @param txt string
--- @param code integer?
function resMeta:text(txt, code)
    self.headers["Content-Type"] = "text/plain"
    self.code = code or 200
    self.body = txt
end

--- Set the JSON response
--- @param tbl table
--- @param code integer?
function resMeta:json(tbl, code)
    self.headers["Content-Type"] = "application/json"
    self.code = code or 200
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.body = json.stringify(tbl)
end

--- Serve the specified file
---@param path string
function resMeta:serveFile(path)
    local body = coroFs.readFile(path)

    -- require("uv").sleep(5000)
    if not body then
        return self:text("File Not Found", 404)
    end

    self.headers["Content-Type"] = mime.getType(path)
    self.body = body
end


--- Check the condition. See res:checkFailed()
---@param assertion any
---@param message string?
function resMeta:check400(assertion, message)
    if self._fail then return end
    if not assertion then
        self._fail = true
        self.code = 400
        self.body = message or "Bad Request"
    end
end

--- Check the condition. See res:checkFailed()
---@param assertion any
---@param message string?
function resMeta:check401(assertion, message)
    if self._fail then return end
    if not assertion then
        self._fail = true
        self.code = 401
        self.body = message or "Unauthorized"
    end
end

--- Check the condition. See res:checkFailed()
---@param assertion any
---@param message string?
function resMeta:check403(assertion, message)
    if self._fail then return end
    if not assertion then
        self._fail = true
        self.code = 403
        self.body = message or "Forbidden"
    end
end

--- Return true if all checks(res:check400(), ...) are passed.\
--- ```lua
--- res:check401(req.auth)
--- res:check400(req.param.name, "name is required")
--- if res:checkFailed() then return end
--- ```
---@return boolean
function resMeta:isCheckPassed()
    return not self._fail
end

return { __index = resMeta }