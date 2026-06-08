" =========================
" KEY TO FUNCTION MAPPINGS
" =========================

" Programming specific mappings
nnoremap -b :call CompileAndRunVSplit()<CR>
nnoremap -r :call RerunInVSplit()<CR>
nnoremap -P :call OpenPDF()<CR>


" =========================
" PLUGIN CONFIGURATION    
" =========================



" =========================
" PLUGIN CONFIGURATION    
" =========================

call plug#begin('~/repositories/plugged')

" Vlime - Common Lisp development environment
" Plug 'vlime/vlime', {'rtp': 'vim/'}

" Paredit - structured editing for Lisp
" Plug 'kovisoft/paredit'

" https://github.com/lervag/vimtex
  Plug 'lervag/vimtex'

call plug#end()


" =========================
" VimTeX CONFIG
" =========================

let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'C:\Users\Andy.Wagner3\Software\SumatraPDF-3.6.1-64\SumatraPDF-3.6.1-64.exe'
let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
let g:vimtex_view_general_options_latexmk = '-reuse-instance'


" =========================
" FUNCTION LIST
" =========================

 " CompileAndRunVSplit()
 " RerunInVSplit()
 " OpenPDF()


" =========================
" FUNCTIONS
" =========================

let g:out_esc       = ''

function! OpenPDF()
    let l:pdf = expand('%:p:r') . '.pdf'
    execute 'silent !cmd /c start "" "' . shellescape(l:pdf) '"'
endfunction


function! CompileAndRunVSplit()
    update

    let l:src = expand('%:p')
    let l:src_esc = shellescape(l:src)
    let l:filetype = &filetype
    
    if l:filetype ==# 'c' || l:filetype ==# 'cpp'
        " C/C++ compilation and execution
        let l:out = expand('%:p:r')
        let g:out_esc = shellescape(l:out)
        let g:last_filetype = 'compiled'
        let l:cmd = 'bash -lc "gcc ' . l:src_esc . ' -o ' . g:out_esc . ' -lm && ' . g:out_esc . '"'
        
    elseif l:filetype ==# 'lisp'
        " Lisp script execution
        let g:out_esc = l:src_esc
        let g:last_filetype = 'interpreted'
        let l:cmd = 'bash -lc "/usr/bin/sbcl --script ' . l:src_esc . '"'
        
    elseif l:filetype ==# 'tex'
        " LaTeX file compilation and open PDF
        let l:cmd = "C:\\Users\\Andy.Wagner3\\AppData\\Local\\Programs\\MiKTeX\\miktex\\bin\\x64\\pdflatex.exe " . shellescape(l:src)
    else
        echo "Unsupported file type: " . l:filetype
        return
    endif
    
    execute 'vertical rightbelow terminal ' . l:cmd
endfunction


function! RerunInVSplit()
    if !exists('g:last_filetype')
        echo "No program has been run yet"
        return
    endif
    
    execute 'quit'
    
    if g:last_filetype ==# 'compiled'
        " Re-run compiled executable
        let l:rerun_cmd = 'bash -lc "' . g:out_esc . '"'
    elseif g:last_filetype ==# 'interpreted'
        " Re-run interpreted script
        let l:rerun_cmd = 'bash -lc "/usr/bin/sbcl --script ' . g:out_esc . '"'
    endif
    
    execute 'vertical rightbelow terminal ' . l:rerun_cmd
endfunction
