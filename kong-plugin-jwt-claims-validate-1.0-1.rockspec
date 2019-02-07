package = "kong-plugin-jwt-scope-validate"
version = "1.0-1"
source = {
   url = "git+https://github.com/danielfreire1/kong-plugin-jwt-claims-validate.git",
   tag = "v1.0"
}
description = {
   summary = "A Kong plugin to check scope"
   homepage = "https://github.com/danielfreire1/kong-plugin-jwt-claims-validate",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.jwt-scope-validate.handler"] = "handler.lua",
      ["kong.plugins.jwt-scope-validate.schema"] = "schema.lua"
   }
}
