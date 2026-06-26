
local function sync_theme()
    local path = vim.fn.stdpath("config") .. "/lua/theme-sync.lua"
    -- 'dofile' ignores the cache and runs the script fresh every time
    local status, err = pcall(dofile, path)
    if not status then
        -- Silent fail if file doesn't exist yet
    end
end

-- Signal listener for Matugen
local signal = vim.loop.new_signal()
if signal then
    vim.loop.signal_start(signal, "sigusr1", function()
        vim.schedule(function()
            sync_theme()
        end)
    end)
end



require("core.options")
require("core.keymaps")
require("core.autocmds")


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  import = "plugins" },  {
  lockfile = vim.fn.stdpath("data") .. "/lazy_lock.json", 
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('html', {
    capabilities = capabilities,
})

vim.lsp.enable({
    'clangd',
    'qmlls', 
    'lua_ls', 
    'pyright', 
    'html', 
    'nixd',
})

sync_theme()
