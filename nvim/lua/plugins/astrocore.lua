-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@param direction 1|-1
function NextUsedBuffer(direction)
  local bufs = vim.t.bufs

  -- First we need to translate buf to id
  local originId = -1
  local originBuf = vim.api.nvim_get_current_buf()
  for i, v in ipairs(bufs) do
    if originBuf == v then
      originId = i
      break
    end
  end

  -- `originId` will always be set by now, as otherwise
  -- it means that the current buffer doesnt exist, which
  -- makes no sense
  local candidateId = originId

  local bufCount = #bufs
  repeat
    candidateId = candidateId + direction
    if candidateId > bufCount then
      candidateId = 1
    elseif candidateId < 1 then
      candidateId = bufCount
    end

    local candidateBuf = bufs[candidateId]

    if rawequal(next(vim.fn.win_findbuf(candidateBuf)), nil) then
      vim.cmd.buffer(candidateBuf)
      break
    end
  until candidateId == originId
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        tabstop = 4,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["<M-l>"] = { function() NextUsedBuffer(1) end, desc = "Next buffer" },
        ["<M-h>"] = { function() NextUsedBuffer(-1) end, desc = "Previous buffer" },

        -- move lines up and down using alt+k and alt+j
        ["<M-k>"] = { ":MoveLine(-1)<cr>", desc = "Move line up" },
        ["<M-j>"] = { ":MoveLine(1)<cr>", desc = "Move line down" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      v = {
        -- move lines up and down using alt+k and alt+j
        ["<M-k>"] = { ":MoveBlock(-1)<cr>", desc = "Move block up" },
        ["<M-j>"] = { ":MoveBlock(1)<cr>", desc = "Move block down" },
      },
    },
  },
}
