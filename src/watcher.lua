local uv = require("uv")
local fs = require("fs")
local path = require("path")

--- Start watching the root directory
---@param rootPath string
---@param onChange fun(filename)
local function watchRoot(rootPath, onChange)
    local event = uv.new_fs_event()
    event:start(rootPath, {recursive = true}, function(err, filename)
        if err then return p("[FSEvent Watcher Error]", err) end

        local realFilePath = path.join(rootPath, filename)
        if fs.statSync(realFilePath).type == "directory" then
            return
        end

        onChange(filename)
    end)
end

return watchRoot