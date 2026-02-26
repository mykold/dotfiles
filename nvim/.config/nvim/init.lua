local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣",
}
vim.opt.colorcolumn = "80,120"
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.termguicolors = true
vim.opt.whichwrap:append("<,>,h,l")
vim.opt.virtualedit = "block"
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.completeopt = { "menuone", "noselect" }

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "[W]indow focus left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "[W]indow focus down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "[W]indow focus up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "[W]indow focus right" })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal exit to normal mode" })
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal window left" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal window down" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal window up" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal window right" })

local term = { buf = nil, win = nil, job = nil }

local function open_term(cmd)
    vim.cmd(cmd)
    term.win = vim.api.nvim_get_current_win()

    if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
        vim.api.nvim_win_set_buf(term.win, term.buf)
    else
        vim.cmd("terminal")
        term.buf = vim.api.nvim_get_current_buf()
        term.job = vim.b.terminal_job_id
        vim.bo.buflisted = false
    end

    vim.cmd("startinsert")
end

local function toggle_term(cmd)
    if term.win and vim.api.nvim_win_is_valid(term.win) then
        vim.api.nvim_win_close(term.win, true)
        term.win = nil
    else
        open_term(cmd)
    end
end

vim.keymap.set("n", "<leader>tt", function()
    toggle_term("botright 15split")
end, { desc = "[T]erminal: [T]oggle (bottom split)" })
vim.keymap.set("t", "<leader>tt", function()
    toggle_term("botright 15split")
end, { desc = "[T]erminal: [T]oggle (bottom split)" })

vim.keymap.set("n", "<leader>tT", function()
    toggle_term("vsplit")
end, { desc = "[T]erminal: toggle (vsplit)" })
vim.keymap.set("t", "<leader>tT", function()
    vim.cmd("stopinsert")
    toggle_term("vsplit")
end, { desc = "[T]erminal: toggle (vsplit)" })

-- stylua: ignore start
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Go to previous [D]iagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Go to next [D]iagnostic" })
-- stylua: ignore end

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [e]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [q]uickfix list" })

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

require("lazy").setup({
    {
        "blazkowolf/gruber-darker.nvim",
        opts = {
            bold = false,
            invert = {
                signs = false,
                tabline = false,
                visual = false,
            },
            italic = {
                strings = false,
                comments = false,
                operators = false,
                folds = false,
            },
            undercurl = false,
            underline = false,
        },
        config = function(_, opts)
            require("gruber-darker").setup(opts)

            vim.cmd.colorscheme("gruber-darker")
        end,
    },

    {
        "stevearc/oil.nvim",
        lazy = false,
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            columns = { "permissions", "size", "mtime" },
            view_options = {
                show_hidden = true,
                is_always_hidden = function(name, _)
                    return name == "." or name == ".git"
                end,
            },
        },
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        config = function(_, opts)
            require("oil").setup(opts)
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "vim", "c", "go", "markdown" },
                highlight = { enable = true },
            })
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "M" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "M" },
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "saghen/blink.cmp",
        },
        opts = {
            lua_ls = {
                single_file_support = true,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        telemetry = { enable = false },
                        workspace = { checkThirdParty = false },
                    },
                },
            },
            basedpyright = {},
            clangd = {},
            gopls = {},
        },

        config = function(_, opts)
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            local servers = {}
            for name, cfg in pairs(opts) do
                if cfg ~= false then
                    local merged = vim.tbl_deep_extend("force", {}, cfg, { capabilities = capabilities })
                    vim.lsp.config(name, merged)
                    table.insert(servers, name)
                end
            end

            table.sort(servers)
            vim.lsp.enable(servers)

            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "E",
                        [vim.diagnostic.severity.WARN] = "W",
                        [vim.diagnostic.severity.INFO] = "I",
                        [vim.diagnostic.severity.HINT] = "H",
                    },
                },
                virtual_text = {
                    source = "if_many",
                    spacing = 2,
                    format = function(d)
                        return d.message
                    end,
                },
            })
        end,
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                local disable_filetypes = { c = true, cpp = true }
                if disable_filetypes[vim.bo[bufnr].filetype] then
                    return nil
                else
                    return {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    }
                end
            end,
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff" },
                go = { "goimports", "gofmt" },
            },
        },
    },

    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- See :h blink-cmp-config-keymap
            keymap = { preset = "default" },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = { documentation = { auto_show = false } },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    {
        "echasnovski/mini.statusline",
        version = false,
        config = function()
            local statusline = require("mini.statusline")
            statusline.setup({
                use_icons = false,
                content = {
                    active = function()
                        local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })

                        local git_branch = (vim.b.gitsigns_head or "-")
                        local git = git_branch ~= "-" and string.format(" %s ", git_branch) or ""

                        local diagnostics = statusline.section_diagnostics({ trunc_width = 75, icon = "" })

                        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.")
                        local modified = vim.bo.modified and "[+]" or ""

                        local filetype = vim.bo.filetype
                        if filetype == "" then
                            filetype = "text"
                        end

                        local location = "%l:%v"
                        local progress = "%p%%"

                        return statusline.combine_groups({
                            { hl = mode_hl, strings = { mode:upper() } },
                            { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
                            "%=",
                            { hl = "MiniStatuslineFilename", strings = { filename, modified } },
                            "%=",
                            { hl = "MiniStatuslineFileinfo", strings = { filetype } },
                            { hl = mode_hl, strings = { location, progress } },
                        })
                    end,
                },
            })
        end,
    },

    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            -- stylua: ignore start

            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set

            set("n", "<M-k>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor [k] up" })
            set("n", "<M-i>", function() mc.lineSkipCursor(-1) end, { desc = "Sk[i]p cursor up" })
            set("n", "<M-j>", function() mc.lineAddCursor(1) end, { desc = "Add cursor [j] down" })
            set("n", "<M-u>", function() mc.lineSkipCursor(1) end, { desc = "Sk[u]p cursor down" })

            set("n", "<M-n>", function() mc.matchAddCursor(1) end, { desc = "Match [n]ext" })
            set("n", "<M-s>", function() mc.matchSkipCursor(1) end, { desc = "[s]kip match" })
            set("n", "<M-p>", function() mc.matchAddCursor(-1) end, { desc = "Match [p]rev" })
            set("n", "<M-a>", function() mc.matchSkipCursor(-1) end, { desc = "Skip b[a]ck" })

            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)

            set("n", "<c-q>", mc.toggleCursor)

            mc.addKeymapLayer(function(layerSet)
                layerSet({ "n", "x" }, "<left>", mc.prevCursor)
                layerSet({ "n", "x" }, "<right>", mc.nextCursor)

                layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end)
            end)

            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

            -- stylua: ignore end
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            local actions = require("telescope.actions")

            -- stylua: ignore start
            local rg_globs = {
                "--hidden",
                "--glob", "!.git/*",
                "--glob", "!**/.git/*",
                "--glob", "!**/.cache/*",
                "--glob", "!**/__pycache__/*",
                "--glob", "!**/*.pyc",
                "--glob", "!**/*_cache/*",
                "--glob", "!**/node_modules/*",
                "--glob", "!**/dist/*",
                "--glob", "!**/build/*",
            }
            -- stylua: ignore end

            return {
                defaults = {
                    border = true,
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    mappings = {
                        i = {
                            ["<C-c>"] = actions.close,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                        n = { ["q"] = actions.close },
                    },
                },
                pickers = {
                    -- stylua: ignore start
                    find_files = {
                        hidden = true,
                        previewer = false,
                        find_command = {
                            "rg", "--files",
                            "--hidden",
                            "--glob", "!.git/*",
                            "--glob", "!**/.git/*",
                            "--glob", "!**/.cache/*",
                            "--glob", "!**/*_cache/*",
                            "--glob", "!**/__pycache__/*",
                            "--glob", "!**/*_cache/*",
                            "--glob", "!**/node_modules/*",
                        },
                    },
                    -- stylua: ignore end
                    live_grep = {
                        additional_args = function()
                            return rg_globs
                        end,
                    },
                    grep_string = {
                        additional_args = function()
                            return rg_globs
                        end,
                    },
                },
            }
        end,
        config = function(_, opts)
            require("telescope").setup(opts)

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
        end,
    },
})

-- See `:help modeline`
-- vim: ts=4 sts=4 sw=4 et
