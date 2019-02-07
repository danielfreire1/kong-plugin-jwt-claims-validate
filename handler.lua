local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local req_set_header = ngx.req.set_header
local ngx_re_gmatch = ngx.re.gmatch

local JwtClaimsValidateHandler = BasePlugin:extend()

local function retrieve_token(request, conf)

  local authorization_header = request.get_headers()["authorization"]
  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, iter_err
    end

    local m, err = iterator()
    if err then
      return nil, err
    end

    if m and #m > 0 then
      return m[1]
    end
  end

end

function JwtClaimsValidateHandler:new()
  JwtClaimsValidateHandler.super.new(self, "jwt-claims-headers")
end

function mysplit(inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

function JwtClaimsValidateHandler:access(conf)
  JwtClaimsValidateHandler.super.access(self)
  local continue_on_error = conf.continue_on_error

  local token, err = retrieve_token(ngx.req, conf)
  if err and not continue_on_error then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  if not token and not continue_on_error then
    return responses.send_HTTP_UNAUTHORIZED()
  end

  local jwt, err = jwt_decoder:new(token)
  if err and not continue_on_error then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR()
  end

  local scopes_token = mysplit(jwt.claims["scope"], " ")
  local scopes = mysplit(conf.scope, ",")

  local exists = false
  for i, value in pairs(scopes) do
    exists = false
    for i2, value_scope_token in pairs(scopes_token) do
      if value_scope_token == value then
        exists = true
        break
      end
    end
    if not exists then
      break
    end
  end
  if not exists then
    return responses.send_HTTP_UNAUTHORIZED("Unautorhized, scope invalid")
  end
end

return JwtClaimsValidateHandler