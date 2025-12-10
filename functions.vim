" =========================
" KEY TO FUNCTION MAPPINGS
" =========================
"
nnoremap    <Leader>m               :call SendBufferViaEmail()<CR>
nnoremap    <Leader>n               :call RenameFileInTab()<CR>
nnoremap    -c                      :call ToggleComment()<CR>
vnoremap    -c                      :call ToggleComment()<CR>
nnoremap    -n                      :call ToggleLineNumbers()<CR>
nnoremap    -p                      :call TogglePaste()<CR>
nnoremap    -z                      :call ToggleWrap()<CR>
vnoremap    -a                      :<C-u>call AlignByDelimiter()<CR>
nnoremap    -f                      :call FilterLinesByPattern()<CR>
xnoremap    -f                      :<C-U>call FilterLinesByPattern(visualmode())<CR>
nnoremap    -F                      :call FilterLinesByPattern('not')<CR>
xnoremap    -F                      :<C-U>call FilterLinesByPattern(visualmode(), 'not')<CR>

inoremap <expr> <TAB>               TabOrCompletion()

nnoremap    ;i                      :call InsertDate()<CR>


" =========================
" FUNCTION LIST    
" =========================

 " SendBufferViaEmail()
 " RenameFileInTab()

 " AlignByDelimiter()
 " DecryptOIDCTokenSmart()
 " FilterLinesByPattern()
 " FormatAndInsertJSON()
 " FormatAndInsertXML()
 " HelpInNewTab()
 " InsertDate()
 " TabOrCompletion()
 " ToggleComment() range
 " ToggleLineNumbers()
 " TogglePaste()
 " ToggleWrap()
 

" =========================
" AUTOCOMMANDS AND FUNCTIONS
" =========================

function! AlignByDelimiter()
" Align a block of text by a given delimiter; '=' is default
  let l:delim = input("Enter delimiter (default '='): ")
  if empty(l:delim)
    let l:delim = '='
  endif
  execute "'<,'>!column -t -s" . shellescape(l:delim) . " -o" . shellescape(l:delim)
endfunction


function! TogglePaste()
" Toggling the line nubmers
    if &paste 
        setlocal nopaste
        echo "Paste: OFF"
    else
        setlocal paste
        echo "Paste: ON"
    endif
endfunction


function! ToggleLineNumbers()
" Toggling the line nubmers
    if &number
        setlocal nonumber
        echo "Line numbers: OFF"
    else
        setlocal number
        echo "Line numbers: ON"
    endif
endfunction


function! ToggleWrap()
" Toggling the line wrapping
    if &wrap
        setlocal nowrap
        echo "Line wrapping: OFF"
    else
        setlocal wrap
        echo "Line wrapping: ON"
    endif
endfunction


function! InsertDate()
" Insert a paragraph seperator and the current date time stamp
    let l:time_stamp = strftime('%c')
    let l:seperator = "====================================================================================================\n" 
    execute 'normal! O' . l:seperator . l:time_stamp . "\n"
endfunction


" Only apply to .txt files
augroup HelpInTabs
    autocmd!
    autocmd BufEnter *.txt call HelpInNewTab()
augroup END


function! HelpInNewTab()
" Only apply to help files
    if &buftype == 'help'
        " Convert the help window to a tab
        execute "normal \<C-W>T"
    endif
endfunction


function! TabOrCompletion()                           
" Autocomplete or insert spaces depending on character before cursor
    let col = col('.') - 1
    if col == 0 || getline('.')[col - 1] !~ '\k'
        return "\<TAB>"
    else
        return "\<C-N>"
    endif
endfunction


function! SendBufferViaEmail()
  " Send the currently active buffer as email attachment to me
  " Prompt with email address to use
  " Use Vim variable or environment variable
  let l:default_email = get(g:, 'vim_default_email', 'andy.wagner3@vodafone.com')
  "let l:default_email = g:vim_default_email
  "  if empty(l:default_email)
  "  let l:default_email = 'andy.wagner3@vodafone.com'
  "endif

  let l:email_address = input("Enter email address (default: " . l:default_email . "): ")
  if empty(l:email_address)
    let l:email_address = 'andy.wagner3@vodafone.com'
  endif
  let g:buffer_file_name = expand("%:p")
  let cmd = 'echo " " | /usr/bin/mail -s "SQL Buffer File" -a ' . g:buffer_file_name .  " " . l:email_address
  let output = system(cmd)
  echo "Sent email. Result: " . output
endfunction


function! RenameFileInTab()
  " Save the file
  execute 'write'
  let old_file_name = expand("%:p")
  let old_short_name = expand("%:t")
  let new_file_path = fnamemodify(old_file_name, ":p:h")
  " Prompt with current file name as default
  let new_short_name = input("Enter the new file name for: " . old_file_name . " : ", old_short_name)
  " Cancel if input is empty or user pressed Escape
  if empty(new_short_name)
    echo "Rename cancelled."
    return
  endif
  let new_file_name = new_file_path . "/" . new_short_name
  echo "\nNew file name including path is: " . new_file_name

  let failed = rename(old_file_name, new_file_name)
  echo "File renamed. Result: " . failed
  if failed == 0
    execute 'close'
    execute 'tabnew ' . new_file_name
  else
    echo "Renaming of " . old_file_name . " to " . new_file_name . " failed!"
  endif
  " Beispiel vom ScriptingVim02:
  " - request input, confirmation, or a selection:
  " 
  " let name = input("Enter your name: ")
  "
  " if confirm('Your name is really ' . name '?', "&Yes\n&No", 1)
  "   let choices = ['Shall I call you:', 
  "               \ '  1:  ' . name, 
  "               \ '  2:  Bruce'
  "               \ ]
  " 
  "   let nicknum = inputlist(choices)
  " 
  "   echo "\n\nYou chose:" nicknum
  " endif
endfunction


function! FilterLinesByPattern(...) abort
" Delete matching lines in the whole file.
" Supports Visual-mode pattern and optional 'not' parameter to invert the match.
  " Determine if we were invoked from Visual mode and if 'not' was requested.
  let l:is_visual = (a:0 >= 1 && a:1 !=# '')
  " Allow passing only 'not' (Normal mode), or as the second arg when Visual
  let l:not = (a:0 >= 2 && a:2 ==# 'not') || (a:0 == 1 && a:1 ==# 'not')

  if l:is_visual
    " Save and yank current visual selection into register z
    let l:save_reg = @"
    normal! gv"zy
    let l:pattern = '\V' . escape(@z, '\')
    let @" = l:save_reg
  else
    " Normal mode: use unnamed register as the literal pattern
    let l:pattern = '\V' . escape(getreg('"'), '\')
  endif

  " Build the global command, invert with g! if 'not' is set
  let l:gcmd = 'g' . (l:not ? '!' : '')

  " Delete all lines in the file that match (or do not match) the pattern
  execute l:gcmd . '/' . l:pattern . '/d'
endfunction


" Decrypt JWT token from register or log line
function! DecryptOIDCTokenSmart()
  " Get the contents of the default register
  let l:reg = getreg('"')

  " Define JWT token pattern
  let l:jwt_pattern = '\v^[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+$'

  " Check if register contains a valid JWT token
  if l:reg =~ l:jwt_pattern
    let l:token = l:reg
  else
    " Fallback: extract token from current line using Bearer pattern
    let l:line = getline('.')
    let l:token = matchstr(l:line, 'Bearer \zs[a-zA-Z0-9_-]\+\.[a-zA-Z0-9_-]\+\.[a-zA-Z0-9_-]\+')
  endif

  " If no token was found, notify and exit
  if empty(l:token)
    echo "No valid JWT token found in register or current line"
    return
  endif

  " Build the command to run the Python script
  let l:cmd = '/WEB_DATA/tbp-web/Ulm-OPS-Scripts/python_scripts/tool_decrypt_token.py -t ' . shellescape(l:token)

  " Run the command and capture the output
  let l:output = system(l:cmd)

  " Clean up the output
  let l:output = substitute(l:output, '\n', '\r', 'g')

  " Insert the output after the current line
  call append(line('.'), split(l:output, '\r'))
endfunction


" Format selected JSON and insert formatted content below selection
function! FormatAndInsertJSON()
  " Save current selection to a temp file
  let l:tmpfile = tempname()
  execute "normal! gv\"zy"
  call writefile(split(@z, "\n"), l:tmpfile)

  " Format using Python's json.tool
  let l:cmd = 'python -m json.tool ' . shellescape(l:tmpfile)
  let l:formatted = system(l:cmd)
  let l:formatted = substitute(l:formatted, '\n$', '', '')

  " Insert formatted JSON below selection
  execute "'<,'>normal! o"
  call append(line("'>"), split(l:formatted, "\n"))

  " Clean up temp file
  call delete(l:tmpfile)
endfunction


" Format selected XML and insert formatted content below selection, handling multiple roots
function! FormatAndInsertXML()
  let l:tmpfile = tempname()
  execute "normal! gv\"zy"
  " Wrap selection in a dummy root
  let l:xml_content = "<root>" . @z . "</root>"
  call writefile(split(l:xml_content, "\n"), l:tmpfile)

  " Format using Python's xml.dom.minidom
  let l:cmd = 'python -c "import sys; from xml.dom.minidom import parse; print(parse(sys.argv[1]).toprettyxml())" ' . shellescape(l:tmpfile)
  let l:formatted = system(l:cmd)
  let l:formatted = substitute(l:formatted, '\n$', '', '')

  " Remove dummy root tags
  let l:formatted = substitute(l:formatted, '<root>\_s*', '', '')
  let l:formatted = substitute(l:formatted, '</root>\_s*', '', '')

  " Insert formatted XML below selection
  execute "'<,'>normal! o"
  call append(line("'>"), split(l:formatted, "\n"))

  call delete(l:tmpfile)
endfunction


function! ToggleComment() range
  " Force SQL commentstring if filetype is sql
  if &filetype ==# 'sql'
    let l:comment_start = '--'
  else
    " Extract comment character from commentstring
    let l:cms = split(&commentstring, '%s')
    let l:comment_start = trim(get(l:cms, 0, '//'))
  endif

  " Escape special regex characters
  let l:comment_escaped = escape(l:comment_start, '/.*~[]^$\')

  let l:start = a:firstline
  let l:end = a:lastline

  for lnum in range(l:start, l:end)
    let ltxt = getline(lnum)
    
    " Skip empty lines
    if substitute(ltxt, '\s*$', '', '') ==# ''
      continue
    endif

    let lstripped = substitute(ltxt, '^\s*', '', '')
    let lindent = matchstr(ltxt, '^\s*')

    if lstripped =~# '^' . l:comment_escaped
      " Uncomment: remove the comment marker and one space
      let lnew = substitute(ltxt, '^\(\s*\)' . l:comment_escaped . '\s\?', '\1', '')
      call setline(lnum, lnew)
    else
      " Comment: add the comment marker with one space
      call setline(lnum, lindent . l:comment_start . ' ' . lstripped)
    endif
  endfor

  if l:start == l:end
    echo "Toggled " . l:comment_start . " comment on line " . l:start
  else
    echo "Toggled " . l:comment_start . " comments for lines " . l:start . "-" . l:end
  endif
endfunction

