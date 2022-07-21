local api = vim.api
local windows = require("cmd_windows")
local parser = require("cmd_parser")

local function execute_command()
  local cmd = parser.get_command()
  local resp = vim.fn.systemlist(cmd)
  windows.print_out(resp)
end

return {
    execute_command             = execute_command,
}
