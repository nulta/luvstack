_G.require = require
local weblit = require('weblit')
local RouterLoader = require("src.routerloader")
local config = require("config")
local watchRoot = require("src.watcher")

local app = weblit.app
    .use(weblit.logger)
    .use(weblit.autoHeaders)
    .use(weblit.etagCache)

for _, b in ipairs(config.binds) do
    app.bind(b)
end

local loader = RouterLoader.new()
loader:loadRouters(app, config.rootPath)

app.start()

watchRoot(config.rootPath, function(filepath)
    local rootPath = config.rootPath
    filepath = filepath:gsub("\\", "/") -- on windows
    loader:reloadRouter(app, rootPath, filepath)

    collectgarbage("collect")
end)