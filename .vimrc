" =========================
" KEY TO FUNCTION MAPPINGS
" these mappings are located in there respective configuration file
" where the function itself is located
" NOTE: some short cuts might even overlap
"
" =========================

let mapleader = ','             " Remap the Leader to comma
let g:prog_leader = '-'         " Set an additional leader

" =========================
" KEYBOARD MAPPING
" =========================

" Keyboard and search
nnoremap    /               /\v
cnoremap    %s/             %s/\v
noremap     ä               <C-]>             " Settings for german keyboard; follow links

inoremap    <expr> <TAB>    TabOrCompletion()
nnoremap    <TAB>           gt
nnoremap    <S-TAB>         gT


nnoremap    ;r              :source ~/awagner1/.vimrc                   " Quick saving and loading of config files
nnoremap    vv              <c-v>                                       " Remap visual block mode to not interfere with windows paste
tnoremap    -e              <C-\><C-n>                                  " Exit terminal mode keep tab open
tnoremap    -q              <C-\><C-n>:q!<CR>                           " Exit terminal mode and close terminal
nnoremap    -vv             :rightbelow vertical terminal<CR>|          " Open vertical terminal
nnoremap    -w              <C-W>                                       " Circle throug windows
nnoremap    -q              :q<CR>                                      " Close window

" Add empty line below stay in normal mode; except in command line window
nnoremap <expr> <Enter> &buftype ==# 'nofile' && &filetype ==# 'vim' ? '<Enter>' : 'o<ESC>'



" set the cursor shape
let &t_ti.="\e[1 q"
let &t_si.="\e[5 q"
let &t_ei.="\e[1 q"
let &t_te.="\e[0 q"

set runtimepath+=~/awagner1/.vim


" =========================
" FILE TYPE APPLICATIONS
" =========================

let g:netrw_preview   = 1
let g:netrw_liststyle = 0
let g:netrw_winsize   = 30
let g:netrw_keepdir   = 0

" Add this to your .vimrc
let g:netrw_browsex_viewer = 'terminal'


" Filetype and plugins
filetype on                     " Enable type file detection.
filetype plugin on              " Enable plugins and load plugin for the detected file type.
filetype indent on              " Load an indent file for the detected file type.
filetype plugin indent on

" Syntax and colors
syntax on                       " Set syntax on and color scheme
" colorscheme slate             " Farben ausgeschalten zum Test
autocmd BufRead,BufNewFile .vim* set filetype=vim


" =========================
" INDENTATION AND TABS
" =========================

set expandtab                   " Use spaces instead of tabs
set tabstop=4                   " Number of spaces a tab counts for
set shiftwidth=4                " Number of spaces to use for each step of (auto)indent


" =========================
" DISPLAY SETTINGS
" =========================

set hlsearch
set incsearch
set showcmd
set matchpairs+=<:>
set number
set clipboard=unnamedplus

set cursorline
highlight CursorLine term=standout cterm=bold ctermbg=1
highlight ColorColumn term=bold cterm=bold ctermbg=1

" Set vim syntax highlighting for each vim file
autocmd BufNewFile,BufRead .vim* set filetype=vim

" =========================
" FILE MANAGEMENT
" =========================

set viminfo='50,n~/awagner1/.viminfo    " Set my personal .viminfo file
set undofile
set undodir=~/awagner1/.vim/undodir

" FINDING FILES
set path+=**
set wildmenu

" =========================
" TABLINE
" =========================

highlight TabLineSel ctermfg=white ctermbg=blue
highlight TabLine    ctermfg=black ctermbg=yellow

" =========================
" STATUSLINE
" =========================

set laststatus=2
set noshowmode

" Custom statusline
set statusline=
set statusline+=%#TabLineFill#\ \|MODE:
set statusline+=%#StatusLineTerm#\%{(mode()=='n')?'\NORMAL\ ':''}
set statusline+=\%{(mode()=='i')?'\INSERT\ ':''}
set statusline+=\%{(mode()=='v')?'\VISUAL\ ':''}
set statusline+=\%{(mode()=='V')?'\V-LINE\ ':''}
set statusline+=\%{(mode()=='^V')?'\V-BLOCK\ ':''}
set statusline+=\%{(mode()=='R')?'\REPLACE\ ':''}
set statusline+=\%{(mode()=='Rv')?'\V-REPLACE\ ':''}
set statusline+=\%{(mode()=='c')?'\COMMAND\ ':''}
set statusline+=\%{(mode()=='t')?'\TERMINAL\ ':''}
set statusline+=\%{mode()} " only to find the return values of mode()
set statusline+=%#TabLineFill#\ \|HOST:
set statusline+=%#ErrorMsg#\%{hostname()}
set statusline+=%#TabLineFill#\ \|FILE:
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&fileformat}\]
set statusline+=\ [%c/%{col('$')}]
set statusline+=\ [%l/%L]

" ============================================================
" Rename tabs to show tab number.
" (Based on http://stackoverflow.com/questions/5927952/whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
    function! MyTabLine()
        let s = ''
        let wn = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%1*' : '%2*')
            let s .= ' '
            let wn = tabpagewinnr(i,'$')

            let s .= '%#TabNum#'
            let s .= i
            " let s .= '%*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let bufnr = buflist[winnr - 1]
            let file = bufname(bufnr)
            let buftype = getbufvar(bufnr, 'buftype')
            if buftype == 'nofile'
                if file =~ '\/.'
                    let file = substitute(file, '.*\/\ze.', '', '')
                endif
            else
                let file = fnamemodify(file, ':p:t')
            endif
            if file == ''
                let file = '[No Name]'
            endif
            " Add modified indicator
            let modified = getbufvar(bufnr, '&modified') ? '[+] ' : ''
            let s .= ' ' . modified . file . ' '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
    set showtabline=1
    highlight link TabNum Special
endif


" ============================================================
" Python function <- this works
function! IcecreamInitialize()
python3 << EOF
class StrawberryIcecream:
    def __call__(self):
        print('EAT ME')
ice = StrawberryIcecream()
ice()
EOF
endfunction


