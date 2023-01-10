---@type RouteFile
local page = {}

function page:get(req, res)
    res:json({
        hello = "world",
        num = 1234,
    })
end

return page