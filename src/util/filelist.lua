local fs = require("fs")

local function fileStructure(from)
    local objList = fs.readdirSync(from)
    local recList = {}

    for k, v in pairs(objList) do
        local objType = fs.statSync(from .. "/" .. v).type
        if objType == "file" then
            recList[v] = true
        else
            recList[v] = fileStructure(from .. "/" .. v)
        end
    end

    return recList
end

local function merge(tbl1, tbl2)
    for k, v in pairs(tbl2) do
        table.insert(tbl1, v)
    end
end

local function flatten(tbl, dir)
    dir = dir or ""
    local result = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            merge(result, flatten(v, dir .. k .. "/"))
        else
            table.insert(result, dir .. k)
        end
    end

    return result
end

--- Given a directory name, Return the list of file recursively.
---@param from string
---@return string[]
local function filelist(from)
    return flatten(fileStructure(from))
end

return filelist