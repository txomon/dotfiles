" This vimrc will be using vundle
" be iMproved, required
set nocompatible
" required
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" Plugins should be between these two calls (vundle#begin and vundle#end)
call vundle#begin()
" The following are examples of different formats supported.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" General features "
""""""""""""""""""""
" Source code browsing
Plugin 'taglist.vim'
" Autocompletion popups
Plugin 'AutoComplPop'
" AutoClose for braces and so closing
" disabled for inserting horrible chars "Plugin 'AutoClose'
" Super tab for completion
Plugin 'ervandew/supertab'
" Buffer management
Plugin 'sjbach/lusty'
" Color schemes for syntax highlighting
Plugin 'ScrollColors'

" VCS "
"""""""
" Git version control
Plugin 'fugitive.vim'
" Visual history browser
Plugin 'Gundo'

" IDE "
"""""""
" Task list like eclipse's
Plugin 'TaskList.vim'

" C "
"""""
" C/C++ IDE
Plugin 'c.vim'

" Python "
""""""""""
" Python highlighting (enchancing default)
Plugin 'python.vim--Vasiliev'
" Python facilities
Plugin 'python.vim'
" pep8 syntax style
Plugin 'pep8'
" Python documentation browser
Plugin 'pydoc.vim'
" Python common errors highlighting
Plugin 'pyflakes'
" Virtual env activation
Plugin 'virtualenv.vim'

" Go "
""""""
Plugin 'txomon/vim-go'

" Markdown "
Plugin 'plasticboy/vim-markdown'

" Salt "
""""""""
Plugin 'saltstack/salt-vim'

call vundle#end()            " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
filetype plugin indent on    " required

" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Plugin configuration "
""""""""""""""""""""""""
" Lusty "
" I might receive error messages, put this to fix it:
set hidden

" plasticboy/vim-markdown "
" Don't like ultra folded docs
let g:vim_markdown_initial_foldlevel=2
" Don't like default key mappings
let g:vim_markdown_no_default_key_mappings=1

" txomon/vim-go
let g:go_disable_autoinstall = 1

" Personal configuration "
""""""""""""""""""""""""""
" Set updates on read
set autoread

" Syntax coloring enable
syntax on
set background=dark

" Enable mouse integration
set mouse=a

"" Disable backups
set nobackup
set nowritebackup
set noswapfile
" Fix tmux missinteractions
""map <Esc>[B <Down>
""nnoremap [A <Up>
""nnoremap [B <Down>
""nnoremap [C <Right>
""nnoremap [D <Left>
""map [A <Up>
""map [B <Down>
""map [C <Right>
""map [D <Left>

set background=dark
