{ pkgs, lib, ... }:

{
  plugins = {
    lualine.enable = true;

    indent-blankline = {
      enable = true;
      settings.scope.enabled = false;
    };

    lsp = {
      enable = true;
      servers =
        let
          servers = [
            # Average webdev LSPs
            "tsserver"
            "cssls"
            "html"
            "astro"

            # Python
            "pyright"

            # Markdown
            "marksman"

            # Nix
            "nil-ls"

            # Docker
            "dockerls"

            # Bash
            "bashls"

            # C/C++
            "clangd"

            # C#
            "csharp-ls"

            # Lua
            "lua-ls"

            # Rust
            "rust-analyzer"

            # Zig
            "zls"
          ];
          sharedConfigs = builtins.map
            (server: {
              ${server} = {
                enable = true;
                onAttach.override = true;
                onAttach.function = ''
                  -- [[ Configure LSP ]]
                  --  This function gets run when an LSP connects to a particular buffer.

                  -- NOTE: Remember that lua is a real programming language, and as such it is possible
                  -- to define small helper and utility functions so you don't have to repeat yourself
                  -- many times.
                  --
                  -- In this case, we create a function that lets us more easily define mappings specific
                  -- for LSP related items. It sets the mode, buffer and description for us each time.
                  local nmap = function(keys, func, desc)
                    if desc then
                      desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
                  end

                  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                  nmap('<leader>ca', function()
                    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
                  end, '[C]ode [A]ction')

                  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                  -- See `:help K` for why this keymap
                  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                  -- Lesser used LSP functionality
                  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
                  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
                  nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                  end, '[W]orkspace [L]ist Folders')

                  -- Create a command `:Format` local to the LSP buffer
                  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    vim.lsp.buf.format()
                  end, { desc = 'Format current buffer with LSP' })
                '';
              };
            })
            servers;
        in
        lib.mkMerge (sharedConfigs ++ [{
          lua-ls.settings.telemetry.enable = false;

          rust-analyzer = {
            installRustc = false;
            installCargo = false;
          };
        }]);
    };

    cmp.enable = true;

    cmp-nvim-lsp.enable = true; # Enable suggestions for LSP
    cmp-buffer.enable = true; # Enable suggestions for buffer in current file
    cmp-path.enable = true; # Enable suggestions for file system paths
    cmp_luasnip.enable = true; # Enable suggestions for code snippets
    cmp-cmdline.enable = false; # Enable autocomplete for command line

    luasnip.enable = true;
    friendly-snippets.enable = true;

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

    headlines.enable = true;

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
    nvim-web-devicons # Should load this in at Telescope/Neotree actions.
    vim-rhubarb # Git related plugins
    neodev-nvim # Additional lua configuration, makes nvim stuff amazing!
  ];
}
