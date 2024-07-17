{ pkgs, ... }:

{
  plugins = {
    lualine.enable = true;

    lsp = {
      enable = true;
      servers = {
        # Average webdev LSPs
        tsserver.enable = true; # TS/JS
        cssls.enable = true; # CSS
        html.enable = true; # HTML
        astro.enable = true; # AstroJS

        # Python
        pyright.enable = true;

        # Markdown
        marksman.enable = true;

        # Nix
        nil-ls.enable = true;

        # Docker
        dockerls.enable = true;

        # Bash
        bashls.enable = true;

        # C/C++
        clangd.enable = true;

        # C#
        csharp-ls.enable = true;

        # Lua
        lua-ls = {
          enable = true;
          settings.telemetry.enable = false;
        };

        # Rust
        rust-analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
        };

        # Zig
        zls.enable = true;
      };
    };

    cmp.enable = true;

    cmp-nvim-lsp.enable = true; # Enable suggestions for LSP
    cmp-buffer.enable = true; # Enable suggestions for buffer in current file
    cmp-path.enable = true; # Enable suggestions for file system paths
    cmp_luasnip.enable = true; # Enable suggestions for code snippets
    cmp-cmdline.enable = false; # Enable autocomplete for command line

    treesitter = {
      enable = true;
      nixvimInjections = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      settings = {
        indent.enable = true;
        folding.enable = false;
      };
    };
    treesitter-context = {
      enable = true;
      settings.multiline_threshold = 1;
    };

    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };

    sleuth.enable = true; # Detect tabstop and shiftwidth automatically

    # Git related plugins
    fugitive.enable = true;

    # Useful status updates for LSP
    fidget.enable = true;

    # Adds git related signs to the gutter, as well as utilities for managing changes
    gitsigns = {
      enable = true;
      # TODO: Find out how to migrate `on_attach` config.
      settings = {
        signs = {
          add = { text = "+"; };
          change = { text = "~"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          changedelete = { text = "~"; };
        };
        on_attach = ''
          function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map({ 'n', 'v' }, ']c', function()
              if vim.wo.diff then
                return ']c'
              end
              vim.schedule(function()
                gs.next_hunk()
              end)
              return '<Ignore>'
            end, { expr = true, desc = 'Jump to next hunk' })

            map({ 'n', 'v' }, '[c', function()
              if vim.wo.diff then
                return '[c'
              end
              vim.schedule(function()
                gs.prev_hunk()
              end)
              return '<Ignore>'
            end, { expr = true, desc = 'Jump to previous hunk' })

            -- Actions
            -- visual mode
            map('v', '<leader>hs', function()
              gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'stage git hunk' })
            map('v', '<leader>hr', function()
              gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'reset git hunk' })
            -- normal mode
            map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
            map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
            map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
            map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
            map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
            map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
            map('n', '<leader>hb', function()
              gs.blame_line { full = false }
            end, { desc = 'git blame line' })
            map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
            map('n', '<leader>hD', function()
              gs.diffthis '~'
            end, { desc = 'git diff against last commit' })

            -- Toggles
            map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
            map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

            -- Text object
            map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
          end
        '';
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    headlines-nvim # Should load this in at the opening of filetypes that require this, namely Markdown.
    nvim-web-devicons # Should load this in at Telescope/Neotree actions.
    friendly-snippets # Should load this in at LuaSnip's initialisation.
    vim-rhubarb # Git related plugins
    neodev-nvim # Additional lua configuration, makes nvim stuff amazing!
  ];
}
