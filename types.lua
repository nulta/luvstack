--- @meta
--- @class Request
--- @field socket unknown
--- @field method "GET"|"POST"|"PUT"|"PATCH"|"DELETE"
--- @field path string
--- @field headers {[string]: string}
--- @field version number
--- @field keepAlive boolean
--- @field body string?
--- @field params {[string]: string, [number]: string}
--- @field query {[string]: string}
--- @field auth Auth?

--- @class Response
--- @field headers {[string]: string}
--- @field code number
--- @field body string

--- @alias RouteHandler fun(self: RouteFile, req: Request, res: Response): nil
--- @alias PrecheckHandler fun(self: RouteFile, req: Request, res: Response): boolean
--- @alias RawRouteHandler fun(req: Request, res: Response): nil
--- @alias RawPrecheckHandler fun(req: Request, res: Response): boolean

--- @class RouteFile
--- @field precheck PrecheckHandler?
--- @field get RouteHandler?
--- @field post RouteHandler?
--- @field put RouteHandler?
--- @field patch RouteHandler?
--- @field delete RouteHandler?

--- @class RawRouteFile
--- @field precheck RawPrecheckHandler?
--- @field get RawRouteHandler?
--- @field post RawRouteHandler?
--- @field put RawRouteHandler?
--- @field patch RawRouteHandler?
--- @field delete RawRouteHandler?