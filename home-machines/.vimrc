" 
" SEE ALSO : /etc/vim/*
" 
" 

" 2012-08-07 use Vundle ( src : https://github.com/gmarik/vundle/blob/master/doc/vundle.txt )
"set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

"
" tdowg1's Bundles here:
" Solarized : http://ethanschoonover.com/solarized/vim-colors-solarized
Bundle 'Solarized'


"" [Vundle Developer's] Bundles here:
""
"" original repos on github
"Bundle 'tpope/vim-fugitive'
"Bundle 'Lokaltog/vim-easymotion'
"Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
"Bundle 'tpope/vim-rails.git'
"" vim-scripts repos
"Bundle 'L9'
"Bundle 'FuzzyFinder'
"Bundle 'rails.vim'
"" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
"" ...

filetype plugin indent on     " required!
" or 
" filetype plugin on          " to not use the indentation settings set by plugins
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..
" /2012-08-07 use Vundle


syntax on
se nu
set tabstop=3


" Prevents vim from replacing spaces with tabs whenever autoindent is on:
" set expandtab
set smarttab
set shiftwidth=3
set shiftround
set autoindent
highlight ExtraWhitespace ctermbg=darkgreen guibg=lightgreen
colors ron
set hlsearch
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set laststatus=2
au BufReadPost,FileReadPost * syntax match Tab /        /
hi Tab gui=underline guifg=blue ctermbg=blue
filetype plugin indent on
syntax enable


:source $VIMRUNTIME/menu.vim
:set wildmenu
:set cpo-=<
:set wcm=<C-Z>
:map <F4> :emenu <C-Z>


" (me!) add from gVim
set gfn=Terminus\ 13


set bg=light

" 2012-12-06 Search[/Replace]: show more context when reviewing matches:
se scrolloff=5


" 2012-04-04 phisata comment this out, it was preventing autoindent and such
"set paste


" 2012-03-02 from /etc/vim/vimrc
" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
  filetype plugin indent on
endif
" /2012-03-02 from /etc/vim/vimrc


" src : http://effectif.com/vim/host-specific-vim-config
"let hostfile = $HOME . '/.vim/gvimrc-' . substitute(hostname(), "\\..*", "", "")
let hostfile = $HOME . '/.vim/vimrc-' . substitute(hostname(), "\\..*", "", "")
if filereadable(hostfile)
  exe 'source ' . hostfile
endif

