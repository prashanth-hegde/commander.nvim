local api = vim.api
local json = require("cmd_json")
local util = require("cmd_utils")

local function get_type()
  return api.nvim_buf_get_option(0, "filetype")
end

local function extract_relevant_lines()
  local linenum = api.nvim_win_get_cursor(0)[1]
  local linebreak = "###"
  local start_line, end_line = linenum, linenum
  -- find start of block
  repeat
    local currline = api.nvim_buf_get_lines(0, linenum-1, linenum, false)[1]
    linenum = linenum - 1
  until linenum == 0 or currline == nil or string.find(currline, linebreak) ~= nil
  start_line = linenum + 1
  -- find end of block
  linenum = end_line
  repeat
    local currline = api.nvim_buf_get_lines(0, linenum-1, linenum, false)[1]
    linenum = linenum + 1
  until linenum == api.nvim_buf_line_count(0) or currline == nil or string.find(currline, linebreak) ~= nil
  end_line = linenum - 1

  local buflines = api.nvim_buf_get_lines(0, start_line, end_line, false)
  return buflines
end

local function create_usable_cmd(block)
  if block == nil then return "" end
  local url = ""
  local headers = {}
  for _, v in ipairs(block) do
    if string.find(v, "#") == nil and string.find(v, ":") == nil then
      url = url .. v
    elseif string.find(v, "#") == nil and string.find(v, ":") ~= nil then
      table.insert(headers, v)
    end
  end

  url = string.gsub(url, "%s+", " ")
  return url
end

local function lines_from(file)
  local function file_exists(file)
    local f = io.open(file, "rb")
	if f then f:close() end
  	return f ~= nil
  end
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

local function hydrate_config(url)
  local function get_config()
    local working_file = api.nvim_buf_get_name(0)
    local path = string.gsub(working_file, "(.*/)(.*)", "%1")
    local conf_file =  path .. "env.json"
    if conf_file == nil then return nil end

    local currenv = util.get_opt("cmd_env")
    local conf_lines = lines_from(conf_file)
    local conf = json.parse_table(conf_lines)
    if conf == nil then
      api.nvim_out_write("No config found. Ensure you have env.json defined in directory\n")
      return nil
    end
    return conf[currenv]
  end

  if string.match(url, "{{%S+}}") == nil then return url end
  local conf = get_config()
  if conf == nil then return end

  local var = string.match(url, "{{%S+}}")
  while var ~= nil do
    local v = string.match(var, "[0-9a-zA-Z_-]+")
    if conf[v] == nil then
      api.nvim_out_write(string.format("No config found for %s, aborting.\n", var))
      return
    end
    url = string.gsub(url, "%b{}", conf[v], 1)
    var = string.match(url, "{{%S+}}")
  end
  return url
end

local function get_command()
  local currfiletype, _ = pcall(get_type)
  if currfiletype == false or (get_type() ~= "cmd" and get_type() ~= "dosbatch") then
    api.nvim_out_write("File is not cmd, cannot execute. :set ft=cmd and try again\n")
    return
  end

  local rel_lines = extract_relevant_lines()
  local url = create_usable_cmd(rel_lines)
  return url
end

return {
  get_command = get_command
}

