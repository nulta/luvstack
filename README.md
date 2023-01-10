# luvstack

## Requirements
- [Luvit runtime](https://luvit.io/install.html)

## Features
- Simple and intuitive to use
- File-based routing
    - See the ./root directory
- Lua file auto-reload on update of root directory

### Example
```lua
-- root/api/hello.lua
local page = {}

function page:precheck(req, res)
    -- you can use res:checkXXX() to assert the conditions
    res:check400(req.query.name, "name parameter is required")
    res:check400(#req.query.name >= 3, "name should be longer than 3 characters")

    -- page:get() will not be called if we return false
    return res:isCheckPassed()
end

function page:get(req, res)
    return res:text("Hello, " .. req.query.name .. "!")
end

return page
```
```
$ curl http://127.0.0.1/api/hello
name parameter is required

$ curl http://127.0.0.1/api/hello?name=world
Hello, world!
```

## Run
```
$ luvit src/main.lua
Loading routers from root
Load routefile: /index.html
Load routefile: /api/hello.lua
Weblit server listening at:
    http://127.0.0.1:8080/
    http://127.0.0.1:8080/
```
