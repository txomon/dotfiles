{ config
, lib
, pkgs
, ...
}: {
  config = lib.mkIf config.programs.vim.enable {
    programs.vim = {
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
      '';
    };
  };
}
