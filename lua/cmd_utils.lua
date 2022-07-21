local api = vim.api

local function println(output)
  if output == nil or output == "" then return end
  local txt = ""
  if type(output) == "table" then
    for _, v in ipairs(table) do
      if v ~= nil then txt = txt .. v end
    end
  elseif type(output) == "string" then
    txt = output
  end

  api.nvim_out_write(txt..'\n')
end

local function get_opt(opt)
  local defaults = {
    ["cmd_switch_to_output_window"]   = "false",
    ["cmd_split"]                     = "vertical",
    ["cmd_env"]                       = "prod",
    ["cmd_cmd"]                       = "",
  }
  local o, err = pcall(function() api.nvim_get_var(opt) end)
  if not o then
    o = defaults[opt]
  else
    o = api.nvim_get_var(opt)
  end
  return tostring(o)
end

return {
  get_opt           = get_opt,
  println           = println,
}
