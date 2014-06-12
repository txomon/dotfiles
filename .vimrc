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
" Super tab for completion
Plugin 'ervandew/supertab'
" Autoclose brackets
Plugin 'AutoClose'
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

" Set updates on read
set autoread

" Syntax coloring enable
syntax on

" Enable mouse integration
set mouse=a
