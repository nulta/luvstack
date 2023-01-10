--- @type RouteFile
local page = {}

function page:get(req, res)
    res.code = 200
    res.body = "Hello?!???"
end


return page