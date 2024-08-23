vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader= " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
local plugins = {
    { "shaunsingh/nord.nvim", name = "nord", priority = 1000 },
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {"nvim-treesitter/nvim-treesitter", build= ":TSUpdate"}
}

require("lazy").setup(plugins, opts)
vim.g.nord_contrast = true                   -- Make sidebars and popup menus like nvim-tree and telescope have a different background
vim.g.nord_borders = true                   -- Enable the border between verticaly split windows visable
vim.g.nord_disable_background = false         -- Disable the setting of background color so that NeoVim can use your terminal background
vim.g.set_cursorline_transparent = false     -- Set the cursorline transparent/visible
vim.g.nord_italic = true                    -- enables/disables italics
vim.g.nord_enable_sidebar_background = false -- Re-enables the background of the sidebar if you disabled the background of everything
vim.g.nord_uniform_diff_background = true    -- enables/disables colorful backgrounds when used in diff mode
vim.g.nord_bold = false
require("nord").set()

vim.cmd.colorscheme "nord"

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"lua", "javascript"},
  highlight = { enable = true },
  indent = { enable = true }
})
