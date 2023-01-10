local filelist = require("src.util.filelist")
local request2 = require("src.classes.request2")
local response2 = require("src.classes.response2")
local pretty = require("pretty-print")
local fs = require("fs")

--- @param handler RouteHandler?
--- @param precheck RouteHandler?
--- @return RawRouteHandler?
local function wrapRouteHandler(self, handler, precheck)
    if not handler then return nil end

    return function(req, res)
        setmetatable(req, request2)
        setmetatable(res, response2)
        req.query = req.query or {}

        -- Drop on precheck failure
        if precheck and not precheck(self, req, res) then return end

        -- Handle the request
        return handler(self, req, res)
    end
end

--- @param routeFile RouteFile?
--- @return RawRouteFile
local function wrapRouteFile(routeFile)
    if not routeFile then return {} end

    local precheck = routeFile.precheck

    routeFile.get = wrapRouteHandler(routeFile, routeFile.get, precheck)
    routeFile.post = wrapRouteHandler(routeFile, routeFile.post, precheck)
    routeFile.put = wrapRouteHandler(routeFile, routeFile.put, precheck)
    routeFile.delete = wrapRouteHandler(routeFile, routeFile.delete, precheck)
    routeFile.patch = wrapRouteHandler(routeFile, routeFile.patch, precheck)

    ---@diagnostic disable-next-line: return-type-mismatch
    return routeFile
end

local function getStaticRouteFile(realFilepath)
    return {
        get = function(self, req, res)
            res:serveFile(realFilepath)
        end
    }
end

--- @param filepath string
--- @return string
local function parseRoutePath(filepath)
    local parsed = filepath
        :gsub("%.lua$", "")
        :gsub("%[(.+)%]", ":%1")
    parsed = "/" .. parsed
    return parsed
end


--- Get the handler(RawRouteFile) from filepath.
local function getHandler(rootPath, filepath)
    local realFilePath = rootPath .. "/" .. filepath

    -- No longer exists
    if not fs.existsSync(realFilePath) then
        pretty.print("Could not find routefile: " .. pretty.colorize("userdata", "/" .. filepath))
        return nil
    end

    local routeFile
    if filepath:match("%.lua$") then
        -- Lua file
        routeFile = dofile(realFilePath)
    else
        -- Static file
        routeFile = getStaticRouteFile(realFilePath)
    end

    local rawRouteFile = wrapRouteFile(routeFile)
    return rawRouteFile
end

--- @param rootPath string
--- @return table<string, RawRouteFile>
local function getHandlers(rootPath)
    local list = filelist(rootPath)
    local handlers = {}

    for _, filepath in ipairs(list) do
        -- Skip the dotfile
        if ("/" .. filepath):match("/%.[^/]+$") then goto CONTINUE end

        pretty.print("Load routefile: " .. pretty.colorize("userdata", "/" .. filepath))
        local routePath = parseRoutePath(filepath)
        handlers[routePath] = getHandler(rootPath, filepath)
        ::CONTINUE::
    end

    return handlers
end


local function attachRoute(app, path, route)
    local availableMethods = {"get", "post", "put", "patch", "delete"}

    for _, method in ipairs(availableMethods) do
        if route[method] then
            app.route({
                method = method:upper(),
                path = path,
            }, route[method])
        end
    end
end

--- @param app unknown
--- @param handlers table<string, RawRouteFile>
local function makeRoutes(app, handlers)
    for routePath, route in pairs(handlers) do
        attachRoute(app, routePath, route)

        if routePath:match("index%.html$") or routePath:match("index$") then
            attachRoute(app, routePath:gsub("%.html$", ""):gsub("index$", ""), route)
        end
    end
end

local function emptyTable(tbl)
    for k, _ in pairs(tbl) do
        tbl[k] = nil
    end
end


local loaderMeta = {}

--- Load the routers.
---@param app unknown
---@param rootPath string
function loaderMeta:loadRouters(app, rootPath)
    pretty.print("Loading routers from " .. pretty.colorize("userdata", rootPath))

    self.routeIndexTable = getHandlers(rootPath)
    makeRoutes(app, self.routeIndexTable)
end

function loaderMeta:reloadRouter(app, rootPath, filepath)
    pretty.print("Reloading routefile: " .. pretty.colorize("userdata", "/" .. filepath))

    local handler = getHandler(rootPath, filepath)
    local routePath = parseRoutePath(filepath)

    self.routeIndexTable[routePath] = handler
    local appHandlers = app.getHandlers()
    emptyTable(appHandlers)

    makeRoutes(app, self.routeIndexTable)
end

function loaderMeta.new()
    local loader = setmetatable({}, { __index = loaderMeta })

    loader.routeIndexTable = {}

    return loader
end

return loaderMeta