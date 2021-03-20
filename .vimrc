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

" Python "
""""""""""
"" Python highlighting (enchancing default)
"Plugin 'python.vim--Vasiliev'
"" Python facilities
"Plugin 'python.vim'
"" pep8 syntax style
"Plugin 'pep8'
"" Python documentation browser
"Plugin 'pydoc.vim'
"" Python common errors highlighting
"Plugin 'pyflakes'
"" Virtual env activation
"Plugin 'virtualenv.vim'

" Markdown "
Plugin 'plasticboy/vim-markdown'

" Ansible/YAML
Plugin 'pearofducks/ansible-vim'

" Salt "
""""""""
"Plugin 'saltstack/salt-vim'

" Terraform "
"""""""""""""
Plugin 'hashivim/vim-terraform'

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

" plasticboy/vim-markdown "
" Don't like ultra folded docs
let g:vim_markdown_folding_disabled = 1
" Don't like default key mappings
let g:vim_markdown_no_default_key_mappings=1

" Personal configuration "
""""""""""""""""""""""""""
" Set updates on read
set autoread

" Coloring
" If it doesn't look good, set the terminal colour palete to solarized, quote:
"
" If you are going to use Solarized in Terminal mode (i.e. not in a GUI
" version like gvim or macvim), please please please consider setting your
" terminal emulator's colorscheme to used the Solarized palette
syntax on
"" Disabled because terminal emulator has been configured with ANSI inverted
" colours, other terminals shouldn't be aware of colour scheme
colorscheme solarized

" Enable mouse integration
set mouse=a

"" Disable backups
set nobackup
set nowritebackup
set noswapfile

" Detect scons files as python files
au BufReadPost SConscript set syntax=python
au BufReadPost SConstruct set syntax=python

" Autosave files on focus lost
au FocusLost * :wa

" Show commands
set showcmd
set autoread

" Highlight search results
set hlsearch
nnoremap <CR> :nohlsearch<CR><CR>

set ignorecase  " do case insensitive search 
set incsearch   " show incremental search results as you type
set number      " display line number
set noswapfile  " disable swap file
