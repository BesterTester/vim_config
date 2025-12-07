" =========================
" KEY TO FUNCTION MAPPINGS
" =========================

" Programming specific mappings
nnoremap -b :call CompileAndRunVSplit()<CR>
nnoremap -r :call RerunInVSplit()<CR>


" =========================
" PLUGIN CONFIGURATION    
" =========================

call plug#begin('~/.vim/plugged')

" Vlime - Common Lisp development environment
Plug 'vlime/vlime', {'rtp': 'vim/'}

" Paredit - structured editing for Lisp
Plug 'kovisoft/paredit'

call plug#end()


" =========================
" FUNCTION LIST
" =========================

 " CompileAndRunVSplit()
 " RerunInVSplit()


" =========================
" FUNCTIONS
" =========================

let g:out_esc       = ''

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
