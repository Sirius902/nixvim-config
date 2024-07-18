{
  # TODO: Remove leader key timeout or add which-key.

  globals.mapleader = " ";
  globals.maplocalleader = " ";

  globalOpts = {
    # Set highlight on search
    hlsearch = false;

    # Line numbers
    number = true;
    relativenumber = true;

    # Tab defaults (might get overwritten by an LSP server)
    tabstop = 4;
    shiftwidth = 4;
    softtabstop = 0;
    expandtab = true;
    smarttab = true;

    # Sync clipboard between OS and Neovim.
    #  Remove this option if you want your OS clipboard to remain independent.
    #  See `:help 'clipboard'`
    clipboard = "unnamedplus";

    # Enable break indent
    breakindent = true;

    # Save undo history
    undofile = true;

    # Case-insensitive searching UNLESS \C or capital in search
    ignorecase = true;
    smartcase = true;

    # Keep signcolumn on by default
    signcolumn = "yes";

    # Decrease update time
    updatetime = 250;
    timeoutlen = 500;

    # Set completeopt to have a better completion experience
    completeopt = "menuone,noselect";

    # NOTE: You should make sure your terminal supports this
    termguicolors = true;
  };

  extraConfigLua = ''
    -- Keymaps for better default experience
    -- See `:help vim.keymap.set()`
    vim.keymap.set({ 'n', 'v' }, '<space>', '<nop>', { silent = true })

    -- Diagnostic keymaps
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

    -- Add GLSL file types.
    vim.filetype.add({
      extension = {
        frag = 'glsl',
        vert = 'glsl',
      },
    })

    vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = '[P]roject [V]iew' })
    vim.keymap.set('n', '<leader>pd', [[:cd %:p:h<cr>:pwd<cr>]], { desc = '[P]roject Set Current [D]irectory' })

    vim.keymap.set('n', '<leader>pg', function()
      -- `vim.fn.expand` will not return `string[]` with these parameters.
      local buf_dir = vim.fn.expand('%:p:h') --[[@as string]]

      local git_job = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, {
        text = true,
        cwd = buf_dir,
      }):wait()

      if git_job.code == 0 then
        local git_root = git_job.stdout:sub(0, -2)
        vim.api.nvim_set_current_dir(git_root)
        print(git_root)
      else
        print(git_job.stderr:sub(0, -2))
      end
    end, { desc = '[P]roject CD To [G]it Root' })

    vim.keymap.set('n', '<leader>p*', function()
      vim.fn.setreg('*', vim.fn.getcwd())
    end, { desc = '[P]roject CWD to [*]' })

    vim.keymap.set('n', '<leader>cw', [[:%s/\s\+$//e<cr>]], { desc = '[C]ode [W]hitespace Trim' })
    vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, { desc = '[C]ode [F]ormat' })

    -- See `:help telescope.builtin`
    vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    local function telescope_live_grep_open_files()
      require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end
    vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
    vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
    vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
    vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
  '';
}
