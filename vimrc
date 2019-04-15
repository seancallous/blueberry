"        .
"  __   __)            
" (. | /o ______  __  _.
"    |/<_/ / / <_/ (_(__
"    |                  

" -------------------------------------------------
"   plug
" -------------------------------------------------

if has('nvim')
  call plug#begin('~/.vim/bundle')

  "Plug 'itchyny/lightline.vim', { 'do': 'ln -s ~/blueberry/vim/jellybeans_lightline.vim ~/.vim/bundle/lightline.vim/autoload/lightline/colorscheme/jellybeans_lightline.vim' }
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
  Plug 'terryma/vim-multiple-cursors', { 'on': [] }
  Plug 'morhetz/gruvbox'

  augroup load_us_ycm
    autocmd!
    autocmd InsertEnter * call plug#load('vim-multiple-cursors')
      \| autocmd! load_us_ycm
  augroup END

  call plug#end()
endif

" -------------------------------------------------
"   user settings
" -------------------------------------------------

" rendering
set encoding=utf-8
set nocompatible
set ttyfast
set synmaxcol=256
"set background=dark

" mode switch delays
set ttimeout
set ttimeoutlen=30
set timeoutlen=3000

" gruvbox
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italicize_comments = '1'
let g:gruvbox_italic = '1'
let g:gruvbox_bold = '0'

" syntax highlighting
colorscheme gruvbox
set t_Co=256
set termguicolors
"hi Normal ctermbg=none guibg=none 

filetype indent on
set number relativenumber " relative numbers
set cursorline " hightlight current line
set showmatch " hl matching [{(s
"hi MatchParen cterm=bold ctermbg=darkgray ctermfg=white

" invisibles
"set list
"set listchars=tab:|

" whitespace
set wrap
set scrolloff=10
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" search
set incsearch " search as characters are entered
set hlsearch " highlight matches
set ignorecase " case-insensitive search
set smartcase " case-sensitive if search contains uppercase
set showmatch
nnoremap \ :noh<return>

" clipboard woes, default vim
set clipboard=unnamedplus " systemwide
vmap <leader>y :w! /tmp/vitmp<CR>
nmap <leader>p :r! cat /tmp/vitmp<CR>

" disable new line comment
autocmd FileType * setlocal formatoptions-=cro

" -------------------------------------------------
"   vim magic
" -------------------------------------------------

" recompile suckless programs automagically
autocmd BufWritePost config.h,config.def.h !sudo make install

" run xrdb whenever Xdefaults or Xresources are updated
autocmd BufWritePost ~/.Xresources,~/.Xdefaults !xrdb %

" auto-update current buffer if it's been changed from somewhere else
set autoread
augroup autoRead
    autocmd!
    autocmd CursorHold * silent! checktime
augroup END

" -------------------------------------------------
"   keymaps
" -------------------------------------------------

" hardmode
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
noremap <PageUp> <nop>
noremap <PageDown> <nop>

inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
inoremap <PageUp> <nop>
inoremap <PageDown> <nop>

" vi-line movement
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" -------------------------------------------------
"   filetype specifics
" -------------------------------------------------

" python
au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4

" -------------------------------------------------
"   status line
" -------------------------------------------------

let g:currentmode={ 
    \ 'n'  : 'NORMAL ',
    \ 'no' : 'N·Operator Pending ',
    \ 'v'  : 'VISUAL ',
    \ 'V'  : 'VLINE ',
    \ '^V' : 'VBLOCK ',
    \ 's'  : 'Select ',
    \ 'S'  : 'S·Line ',
    \ '^S' : 'S·Block ',
    \ 'i'  : 'INSERT ',
    \ 'R'  : 'REPLACE ',
    \ 'Rv' : 'V·Replace ',
    \ 'c'  : 'COMMAND ',
    \ 'cv' : 'Vim Ex ',
    \ 'ce' : 'Ex ',
    \ 'r'  : 'Prompt ',
    \ 'rm' : 'More ',
    \ 'r?' : 'Confirm ',
    \ '!'  : 'Shell ',
    \ 't'  : 'Terminal '
    \ }

function! ExtractColorFromScheme(color)
  return synIDattr(synIDtrans(hlID('a:color')), 'fg')
endfunction

function! ExtractColorFromXresources()
  return system("xrdb -query | awk '/^\*'color0':(.*)/ { print $2 }'")
endfunction

let _blue = system("xrdb -query | awk '/^\*'color12':(.*)/ { print $2 }'")

" mode name
hi User1 ctermbg=4 guibg=4 guifg=bg ctermfg=black cterm=bold 
" mode arrow separator
hi User2 ctermbg=8 ctermfg=4
" file name
hi User3 ctermbg=8 ctermfg=fg guibg=8 guifg=fg
" gray to black
hi User4 ctermbg=bg ctermfg=8
" gray to white
hi User5 ctermbg=8 ctermfg=fg
" black on white
hi User6 ctermbg=fg ctermfg=bg

" pull the colors needed from Xresources (yes, i am stupid) 
exe 'hi StatusLineBlue guibg=' . system("xrdb -query | awk '/^\*'color10':(.*)/ { print $2 }'")

function! ChangeStatuslineColor()
  if mode() =~# '\v(n|c)'
    "hi User1 ctermbg=12 
    "hi User2 ctermfg=12
    hi! link User1 StatusLineBlue
  elseif (mode() =~# '\v(v|V)' || ModeCurrent() == 'VBLOCK ')
    hi User1 ctermbg=11
    hi User2 ctermfg=11
  elseif mode() == 'i'
    hi User1 ctermbg=10
    hi User2 ctermfg=10
  else
    hi User1 ctermbg=9
    hi User2 ctermfg=9
  endif
  redrawstatus
  return ''
endfunction

function! ModeCurrent() abort
    let l:modecurrent = mode()
    " abort -> function will abort soon as error detected
    " use get() -> fails safely, since ^V doesn't seem to register
    " 3rd arg is used when return of mode() == 0, which is case with ^V
    " thus, ^V fails -> returns 0 -> replaced with 'V Block'
    let l:modelist = toupper(get(g:currentmode, l:modecurrent, 'VBLOCK '))
    let l:current_status_mode = l:modelist
    return l:current_status_mode
endfunction

function! StatusLineFileName()
    let full_file_path = expand('%:p')
    return strlen(full_file_path) < winwidth(0)*0.55 ? full_file_path : expand('%f')
endfunction

function! StatusLineFileType()
    return &filetype
endfunction

function! StatusLineModified()
    return &modified ? ' + ' : ''
endfunction

function! StatusLineReadonly()
    return &readonly ? ' readonly ' : ''
endfunction

set noshowmode
set laststatus=2
set statusline=

" left side
set statusline+=%{ChangeStatuslineColor()} " automagically set mode color
set statusline+=%1*\ %{ModeCurrent()} " current mode text
set statusline+=%2*
set statusline+=%3*\ %{StatusLineFileName()}
set statusline+=\ %{StatusLineReadonly()}
set statusline+=\ %{StatusLineModified()}
set statusline+=%4* 
" right side
set statusline+=%=
set statusline+=%{StatusLineFileType()}
set statusline+=\ %4* 
set statusline+=%3*\ %p%% " percentage through the file
set statusline+=\ %5* 
set statusline+=%6*\ %l:%c " line:column
set statusline+=\ 
