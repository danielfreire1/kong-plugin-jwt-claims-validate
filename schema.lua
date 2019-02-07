local cjson = require "cjson"

return {
  no_consumer = true,
  fields = {
    scope = { type = "string", required = true }
  }
}