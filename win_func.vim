" =========================
" WINDOW SPECIFIC CONFIGURATION
" =========================

" Force yank to clipboard
set clipboard=unnamedplus
nnoremap    y               "+y
nnoremap    yy              "+yy
nnoremap    Y               "+Y
vnoremap    y               "+y


" Set the cursor shape
let &t_ti.="\e[1 q"
let &t_si.="\e[5 q"
let &t_ei.="\e[1 q"
let &t_te.="\e[0 q"


" =========================
" AUTOCOMMANDS AND FUNCTIONS
" =========================

" Autocommand to call the SaveSession function on Vim exit
autocmd VimLeave * call ExitVim()

nnoremap    ;e              :call ExitVim()<CR>                         " Save all buffers befor exiting vim


" =========================
" FUNCTION LIST    
" =========================

  " ExitVim()
  " ActivateNetrwTab()


function! ExitVim()
" Function to save all unsaved files for recovery in the next session
" and exit vim
  let l:counter = 1
  let l:saved = 0
  let l:target_dir = expand('~/repositories')
  let l:current_tab = tabpagenr()

  " Loop through all tabs
  for tab in range(1, tabpagenr('$'))
    execute 'tabnext' tab
    let l:bufname = bufname('%')
    let l:modified = &modified
    let l:filetype = &filetype

    " Skip netrw buffers
    if l:filetype ==# 'netrw'
      continue
    endif

    " If buffer is unnamed or matches '[Unbenannt]'
    if l:bufname == '' || l:bufname =~ '\[Unbenannt\]'
      " Find a unique filename
      while filereadable(l:target_dir . '/Unbenannt_' . l:counter . '.note')
        let l:counter += 1
      endwhile

      " Save the buffer
      execute 'saveas ' . fnameescape(l:target_dir . '/Unbenannt_' . l:counter . '.note')
      let l:saved += 1
      let l:counter += 1
    elseif l:modified
      " Save modified named buffers
      execute 'update'
      let l:saved += 1
    endif
  endfor

  " Return to original tab
  execute 'tabnext' l:current_tab
  echom l:saved . ' buffers saved.'

  " Save the session with all files
  execute 'mks! ~/_vim_latest_session'

  " Quit all buffers
  execute 'qall!'
endfunction


function! ActivateNetrwTab()
  let l:current_tab = tabpagenr()

  " Loop through all tabs
  for tab in range(1, tabpagenr('$'))
    execute 'tabnext' tab
    " Check all windows in the tab
    for win in range(1, winnr('$'))
      execute win . 'wincmd w'
      if &filetype ==# 'netrw'
        echom 'Activated netrw tab: ' . tab
        return
      endif
    endfor
  endfor

  " If no netrw tab found, return to original tab
  execute 'tabnext' l:current_tab
  echom 'No netrw tab found.'
endfunction

