--
-- FLAGS
--
require('singh')
vim.o.tabstop = 2
vim.o.syntax = enable
vim.g.vimtex_view_method = 'zathura'
vim.o.softtabstop = 2
vim.o.ignorecase = true
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.wo.cc = '80'
vim.go.ttyfast = true
vim.wo.number = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.updatetime = 50
vim.opt.scrolloff = 8
vim.o.foldlevel = 20
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
--
-- LAZY NVIM
--
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'folke/tokyonight.nvim' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  -- LSP Support
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
    }
  },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'L3MON4D3/LuaSnip' }
    },
  },
  {
    'hrsh7th/cmp-buffer'
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  {
    'lervag/vimtex',
    lazy = false
  },
  {
    "catppuccin/nvim",
  },
  {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.4',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' }
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  {
    "ThePrimeagen/harpoon"
  },
  {
    "mbbill/undotree"
  },
  {
    'numToStr/Comment.nvim',
    lazy = false,
  },
  -- Wrapping
  {
    "andrewferrier/wrapping.nvim",
    config = function()
      require("wrapping").setup()
    end
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<20>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- Everything in opts will be passed to setup()
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  }
})

--
-- TELESCOPE
--
require('telescope').setup({
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  },
  defaults = {
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        anchor = 'E',
        width = 0.6,
        height = 0.95,
        preview_width = 0.7,
      },
      cursor = {
        width = 0.6,
        preview_width = 0.7,
        height = 0.4,
      },
      -- other layout configuration here
    },
  }
})
require('telescope').load_extension('fzf')

--
-- LSP ZERO
--
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({ buffer = bufnr })
end)

lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

local lspconfig = require('lspconfig')
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

lspconfig.dartls.setup({})
lspconfig.sourcekit.setup({})


--
-- CMP
--
local cmp = require('cmp')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

vim.opt.termguicolors = true
local ok_status, NeoSolarized = pcall(require, "NeoSolarized")

require("tokyonight").setup({
  style = "night",
  transparent = true,
})
require("catppuccin").setup({
  transparent_background = true,
  show_end_of_buffer = true
})
vim.cmd.colorscheme('tokyonight')
require("flutter-tools").setup {}

require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,


  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
})
require('Comment').setup()

local ft = require('Comment.ft')
ft.objc = { '//%s', '/* %s */' }

diagnostic_state = 0
vim.api.nvim_create_user_command("DiagnosticToggle", function()
  diagnostic_state = diagnostic_state + 1
  if diagnostic_state > 3 then
    diagnostic_state = 0
  end
  local config = vim.diagnostic.config
  config {
    virtual_text = diagnostic_state < 1,
    signs = diagnostic_state < 2,
    underline = diagnostic_state < 3,
  }
end, { desc = "toggle diagnostic" })

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>d", vim.cmd.DiagnosticToggle)

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>e", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
vim.keymap.set("n", "<leader>5", function() ui.nav_file(5) end)
vim.keymap.set("n", "<leader>6", function() ui.nav_file(6) end)
vim.keymap.set("n", "<leader>7", function() ui.nav_file(7) end)
vim.keymap.set("n", "<leader>8", function() ui.nav_file(8) end)
vim.keymap.set("n", "<leader>9", function() ui.nav_file(9) end)
vim.keymap.set("n", "<leader>0", function() ui.nav_file(10) end)

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])


vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldtext =
[[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']]
vim.opt.fillchars = "fold:\\"
vim.opt.foldnestmax = 3
vim.opt.foldminlines = 1


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<C-p>', builtin.git_files)
vim.keymap.set('n', '<leader>tt', vim.cmd.Telescope)
vim.keymap.set('n', '<leader>gr', function() builtin.lsp_references({ layout_strategy = 'cursor' }) end)
vim.keymap.set('n', '<leader>gp', function() builtin.lsp_incoming_calls({ layout_strategy = 'cursor' }) end)
vim.keymap.set('n', '<leader>gn', function() builtin.lsp_outgoing_calls({ layout_strategy = 'cursor' }) end)
vim.keymap.set('n', '<leader>gi', function() builtin.lsp_implementations({ layout_strategy = 'cursor' }) end)
vim.keymap.set('n', '<leader>gd', function() builtin.lsp_definitions({ layout_strategy = 'cursor' }) end)
vim.keymap.set('n', '<leader>gD', function() builtin.lsp_type_definitions({ layout_strategy = 'cursor' }) end)
