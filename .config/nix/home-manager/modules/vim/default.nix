{ config
, lib
, pkgs
, ...
}: {
  config = lib.mkIf config.programs.vim.enable {
    programs.vim = {
      plugins = [
        pkgs.vimPlugins.vim-markdown
        # Also covers OpenTofu: its ftdetect claims *.tofu and *.tofutest.hcl.
        pkgs.vimPlugins.vim-terraform
      ];

      settings = {
        ignorecase = true;
        mouse = "a";
        number = true;
      };

      extraConfig = ''
        set autoread
        set incsearch
        set showcmd
        set hlsearch

        syntax on

        " No backups or swap files
        set nobackup
        set nowritebackup
        set noswapfile

        " Detect scons files as python files
        au BufReadPost SConscript set syntax=python
        au BufReadPost SConstruct set syntax=python

        " Autosave files on focus lost
        au FocusLost * :wa

        nnoremap <CR> :nohlsearch<CR><CR>
        inoremap <C-v> <ESC>"+pi

        " plasticboy/vim-markdown
        let g:vim_markdown_folding_disabled = 1
        let g:vim_markdown_no_default_key_mappings = 1
      '';
    };
  };
}
