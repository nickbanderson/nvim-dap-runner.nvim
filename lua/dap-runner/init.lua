local M = {}

local dap = require("dap")

local options = {
  debug = false,
  specific_confs = {},
}

function M.setup(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})

  -- TODO verify confs against dap-specific keys?
  for _, conf in pairs(options.specific_confs)  do
    if type(conf.condition) ~= "function" then
      error("specific_confs must have function condition()")
    end
  end
end

function M.run()
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  local generic_conf = dap.configurations[filetype][1] or {}

  local specific_conf = {}
  for name, conf in pairs(options.specific_confs) do
    if conf.condition() == true then
      if options.debug then _P("specific_conf matched: " .. name) end
      specific_conf = type(conf.gen_conf) == "function" and conf.gen_conf()
                                                         or conf
      break
    end
  end

  if generic_conf == {} and specific_conf == {} then
    error("no suitable dap debuggee conf")
  else
    local end_conf = vim.tbl_deep_extend("force", generic_conf, specific_conf)
    end_conf.confition = nil
    end_conf.gen_conf = nil
    if options.debug then _P({"end_conf: ", end_conf}) end
    dap.run(end_conf)
  end
end

return M
