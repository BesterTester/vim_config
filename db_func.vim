" =========================
" KEY TO FUNCTION MAPPINGS
" =========================

nnoremap <leader>d  :call ConvertFromEpoc()<CR>
nnoremap <Leader>e  :call ConvertToEpoc()<CR>
nnoremap <Leader>c  :call ExtractCurrentSQL()<CR>
nnoremap <Leader>b  :call ExecuteBashCommandBuffer('OCI_prod_ULM_access.sh')<CR>
nnoremap <Leader>B  :call ExecuteBashCommandBuffer('OCI_prod_Event_access.sh')<CR>
nnoremap <Leader>t  :call OpenSqlBufferInTab()<CR>

nnoremap <Leader>s  :call SendBufferToFifo()<CR>

" =========================
" FUNCTION LIST    
" =========================

 " ConvertBufferToCSV()
 " ConvertFromEpoc()
 " ConvertToEpoc()
 " ExecuteBashCommand(bash_file)
 " ExecuteBashCommandBuffer(bash_file)
 " ExtractCurrentSQL()
 " OpenSqlBufferInTab()
 " TransposeFixedWidthMatrixWithHeader()
 " s:ExtractFields(line, ranges)

 " StartStopConnection()
 " SendBufferToFifo()
 " ExtractCurrentSQL_2()
 "

" =========================
" SQL BUFFER FUNCTIONS
" =========================

let g:manager_name  = 'pers_conn_manager'
let g:script_dir    = '/WEB_DATA/' . g:manager_name . '/'
let g:pid_file      = g:script_dir . g:manager_name . '.pid'
let g:output_dir    = g:script_dir . 'sql_output/'
let g:input_fifo    = g:script_dir . 'input.fifo'
let g:sql_buffer    = g:script_dir . 'sql_buffer.sql'
let g:input_filename = ""


" Start/Stop Database connection
function! StartStopConnection()
    let l:script_name   = '/WEB_DATA/opsScripts/Ulm-OPS-Scripts/python_scripts/oracle_persistent_connection.py'
    let l:con_start     = 'cd ' . g:script_dir . '; nohup ' . l:script_name . ' start 2>&1 &'
    let l:con_stop      = l:script_name . ' stop'
    let l:get_pid       = 'cat ' . g:pid_file
    let l:pid = system(l:get_pid)
    if l:pid 
        echo "Stopping Connection!"
        call system(l:con_stop)
        execute '1sleep'
        let l:fifo_list = system('ls -l ' . g:script_dir . '*.fifo')
        echo "Connection stoped. Fifo List: " . l:fifo_list
    else
        echo "Starting Connection!"
        call system(l:con_start)
        execute '1sleep'
        let l:pid = system(l:get_pid)
        echo "Connection started. PID : " . l:pid
    endif
endfunction


" Send the currently open buffer to fifo
function! SendBufferToFifo()
    let l:input_fifo = g:input_fifo
    let l:filename = expand('%:p')
    let l:buffer_content = getline(1, '$')

    " Check if FIFO exists
    let l:cmd = '[ -p "' . l:input_fifo . '" ]'
    let l:exit_code = system(l:cmd . ' ; echo $?')
    if str2nr(trim(l:exit_code)) == 0
        echo "Sending buffer " . g:sql_buffer . " to fifo " . l:input_fifo . "..."

        " Write filename and buffer content to a temp file
        let l:temp_file = tempname()
        call writefile([l:filename] + l:buffer_content, l:temp_file)

        " Send temp file to fifo
        let l:send_cmd = 'cat "' . l:temp_file . '" > "' . l:input_fifo . '"'
        let l:result = system(l:send_cmd)

        " Clean up temp file
        call delete(l:temp_file)

        if v:shell_error == 0
            echo "Successfully sent buffer to fifo " . l:input_fifo
        else
            echo "Error sending buffer to fifo. Error code: " . v:shell_error
        endif
    else
        echo "No fifo: " . l:input_fifo
        echo "Buffer not sent."
    endif
endfunction


function! ExtractCurrentSQL_2()
  " Generate timestamp filename in format "output_yyyy-mm-dd_HHMMSS.out"
  let g:timestamp = strftime("%Y-%m-%d_%H%M%S")
  let g:input_filename = g:output_dir . g:timestamp . "_input.sql"

  " Find the start of the current SQL statement (go up until a semicolon or beginning of file)
  let start_line = line('.')
  while start_line > 1 && getline(start_line-1) !~ ';$'
    let start_line -= 1
  endwhile

  " Find the end of the current SQL statement (go down until a semicolon or end of file)
  let end_line = line('.')
  while end_line < line('$') && getline(end_line) !~ ';$'
    let end_line += 1
  endwhile

  " Extract the SQL statement
  let sql_statement = getline(start_line, end_line)

  " Create a new array with the spool commands and SQL statement
  let output_content = [g:input_filename . "|"]


  " Add each line of the SQL statement
  for line in sql_statement
    call add(output_content, line)
  endfor

  " Write everything to the file (overwriting any existing content)
  call writefile(output_content, g:input_filename)

  execute 'tabnew ' . g:input_filename
endfunction


" =========================
" DATABASE FUNCTIONS
" =========================

function! ConvertToEpoc()
" Convert date in register into epoch by linux command
  let l:timestamp = @"
  let l:cmd = 'date -d "' . l:timestamp . '" +%s%3N'
  let l:epoch = system(l:cmd)
  let l:epoch = substitute(l:epoch, '\n', '', '')
  let @" = l:epoch
  normal! ""p
endfunction


function! ConvertFromEpoc()
" Convert epoch under cursor into date
  let l:epoch = expand('<cword>')
  if l:epoch =~ '^\d\+$'
    let l:cmd = 'ts=' . l:epoch . '; printf "%s.%03d\n" "$(date -d "@$((ts/1000))" "+%Y-%m-%d %H:%M:%S")" "$((ts%1000))"'
    let l:date = system(l:cmd)
    let l:date = substitute(l:date, '\n', '', 'g')
    execute 'normal! ciw' . l:date
  else
    echo "No valid epoch under cursor"
  endif
endfunction


function! ExtractCurrentSQL()
" Generate timestamp filename in format "output_yyyy-mm-dd_HHMMSS.out"
  let g:timestamp = strftime("%Y-%m-%d_%H%M%S")
  let g:spool_filename = "/WEB_DATA/tmp_spool/output_" . g:timestamp . ".out"
  " Find the start of the current SQL statement (go up until a semicolon or beginning of file)
  let start_line = line('.')
  while start_line > 1 && getline(start_line-1) !~ ';$'
    let start_line -= 1
  endwhile

  " Find the end of the current SQL statement (go down until a semicolon or end of file)
  let end_line = line('.')
  while end_line < line('$') && getline(end_line) !~ ';$'
    let end_line += 1
  endwhile

  " Extract the SQL statement
  let sql_statement = getline(start_line, end_line)

  " Create a new array with the spool commands and SQL statement
  let output_content = ['spool ' . g:spool_filename]
  call add(output_content ,'set linesize 5000')  " Allow super long output
  call add(output_content ,'set pagesize 50000') " Set header only on first page
  call add(output_content ,'ALTER SESSION SET NLS_DATE_FORMAT = "yyyy-mm-dd hh24:mi:ss";') " Set date format
  call add(output_content ,'ALTER SESSION SET NLS_TIMESTAMP_FORMAT = "YYYY-MM-DD HH24:MI:SS";') " Set time stamp format

  call add(output_content, '')                   " Add blank line for separation

  " Add each line of the SQL statement
  for line in sql_statement
    " Skip lines that are SQL comments (start with --)
    if line !~ '^\s*--'
      call add(output_content, line)
    endif
  endfor

  call add(output_content, '')                  " Add blank line for separation
  call add(output_content, 'spool off')

  " Write everything to the file (overwriting any existing content)
  call writefile(output_content, g:sql_buffer)

  " Open the SQL Buffer to review the spool file
  call OpenSqlBufferInTab()
endfunction


function! OpenSqlBufferInTab()
  if filereadable(g:sql_buffer)
    execute 'tabnew ' . g:sql_buffer
    " echo "Opened SQL buffer in new tab"
  else
    echo "No SQL buffer file has been created yet at " . g:sql_buffer
  endif
endfunction


function! ExecuteBashCommand(bash_file)
  execute 'update'
  " Check if sql_buffer file exists
  if filereadable(g:sql_buffer)
    let cmd = '/home/tbp-web/awagner1/DATABASE/' . a:bash_file . ' ' . shellescape(g:sql_buffer)
    let output = system(cmd)
    " Append SQL from sql_buffer to the g:spool_filename
    let cmd = 'cat ' . shellescape(g:sql_buffer) . ' >> ' . shellescape(g:spool_filename)
    let output = system(cmd)
    execute 'tabnew ' . g:spool_filename
    setlocal nowrap
    setlocal nonumber
  else
    echo "No SQL buffer file has been created yet"
  endif
endfunction


function! ExecuteBashCommandBuffer(bash_file)
  " Use the currently modified sql_buffer.sql file to execute the SQL
  execute 'update'

  " Check if sql_buffer file exists
  if !filereadable(g:sql_buffer)
    echo "No SQL buffer file has been created yet"
    return
  endif

  " Read all lines from the actual sql_buffer file
  let sql_buffer_lines = readfile(g:sql_buffer)
  if empty(sql_buffer_lines)
    echo "SQL buffer file is empty"
    return
  endif

  " Extract the filename from the spool command (first line)
  let new_spool_filename = matchstr(sql_buffer_lines[0], '\vspool\s+\zs\S+')
  if empty(new_spool_filename)
    echo "Could not extract spool filename from sql_buffer"
    return
  endif

  " Check for data-modifying SQL keywords
  let dangerous_keywords = ['INSERT', 'UPDATE', 'DELETE', 'MERGE', 'DROP', 'TRUNCATE']
  let found_dangerous = 0
  let found_keyword = ''

  for line in sql_buffer_lines
    " Convert line to uppercase for case-insensitive matching
    let upper_line = toupper(line)
    " Skip comment lines
    if upper_line =~ '^\s*--' || upper_line =~ '^\s*REM'
      continue
    endif

    for keyword in dangerous_keywords
      " Match keyword as whole word (with word boundaries)
      if upper_line =~ '\<' . keyword . '\>'
        let found_dangerous = 1
        let found_keyword = keyword
        break
      endif
    endfor

    if found_dangerous
      break
    endif
  endfor

  " If dangerous SQL found, prompt for confirmation
  if found_dangerous
    echohl WarningMsg
    echo "WARNING: SQL contains data-modifying keyword: " . found_keyword
    echohl None
    let response = input("Do you really want to execute this SQL? (yes/no): ")

    if response !=# 'yes'
      echo "\nExecution cancelled by user"
      return
    endif
    echo "\nProceeding with execution..."
  endif

  " Execute the bash command
  let cmd = '/home/tbp-web/awagner1/DATABASE/' . a:bash_file . ' ' . shellescape(g:sql_buffer)
  let output = system(cmd)
  if v:shell_error != 0
    echo "Error executing bash command: " . output
    return
  endif

  " Append SQL from sql_buffer to the spool_filename
  let cmd = 'cat ' . shellescape(g:sql_buffer) . ' >> ' . shellescape(new_spool_filename)
  call system(cmd)

  " Close current buffer and open the result file
  execute 'quit'
  execute 'tabnew ' . new_spool_filename
  setlocal nowrap
  setlocal nonumber
endfunction


function! TransposeFixedWidthMatrixWithHeader()
  let lines = getline(1, '$')
  if len(lines) < 3
    echo "Nicht genügend Zeilen für Header, Struktur und Daten."
    return
  endif

  let header_line = lines[0]
  let structure_line = lines[1]

  " Spaltenbereiche aus Strukturzeile ermitteln
  let col_ranges = []
  let in_col = 0
  let start = 0
  for i in range(0, len(structure_line))
    if structure_line[i] ==# '_' && !in_col
      let start = i
      let in_col = 1
    elseif structure_line[i] !=# '_' && in_col
      call add(col_ranges, [start, i])
      let in_col = 0
    endif
  endfor
  if in_col
    call add(col_ranges, [start, len(structure_line)])
  endif

  " Spaltennamen aus Headerzeile extrahieren
  let headers = []
  for range in col_ranges
    let [start, end] = range
    if start < len(header_line)
      let name = strpart(header_line, start, end - start)
      call add(headers, substitute(name, '^\s*\|\s*$', '', 'g'))
    else
      call add(headers, '')
    endif
  endfor

  " Datenzeilen extrahieren
  let matrix = []
  for line in lines[2:]
    let row = []
    for range in col_ranges
      let [start, end] = range
      if start < len(line)
        let cell = strpart(line, start, end - start)
        call add(row, substitute(cell, '^\s*\|\s*$', '', 'g'))
      else
        call add(row, '')
      endif
    endfor
    call add(matrix, row)
  endfor

  " Transponieren inkl. Header
  let transposed = []
  for col in range(0, len(headers))
    let new_row = [get(headers, col, '')]
    for row in matrix
      call add(new_row, get(row, col, ''))
    endfor
    call add(transposed, join(new_row, ';'))
  endfor

  " Buffer ersetzen
  call setline(1, transposed)
endfunction

function! ConvertBufferToCSV()
  " Hole alle Zeilen inkl. letzter Zeile ohne Zeilenumbruch
  let lines = getline(1, line('$'))

  if len(lines) < 3
    echo "Nicht genügend Zeilen für Header, Struktur und Daten."
    return
  endif

  let header_line = lines[0]
  let structure_line = lines[1]

  " Spaltenbereiche aus Strukturzeile ermitteln
  let col_ranges = []
  let in_col = 0
  let start = 0
  for i in range(0, len(structure_line))
    if structure_line[i] ==# '_' && !in_col
      let start = i
      let in_col = 1
    elseif structure_line[i] !=# '_' && in_col
      call add(col_ranges, [start, i])
      let in_col = 0
    endif
  endfor
  if in_col
    call add(col_ranges, [start, len(structure_line)])
  endif

  " Funktion zum Extrahieren und Trimmen eines Feldes
  function! s:ExtractFields(line, ranges)
    let fields = []
    for range in a:ranges
      let [start, end] = range
      if start < len(a:line)
        let field = strpart(a:line, start, end - start)
        call add(fields, substitute(field, '^\s*\|\s*$', '', 'g'))
      else
        call add(fields, '')
      endif
    endfor
    return fields
  endfunction

  " Header extrahieren
  let header = s:ExtractFields(header_line, col_ranges)

  " Daten extrahieren
  let data = []
  for line in lines[2:]
    call add(data, s:ExtractFields(line, col_ranges))
  endfor

  " CSV-Zeilen vorbereiten
  let csv_lines = [join(header, ';')]
  for row in data
    call add(csv_lines, join(row, ';'))
  endfor

  " Lösche Buffer Inhalt
  execute '%delete'

  " Bufferinhalt ersetzen
  call setline(1, csv_lines)
  echo "Tabelle wurde in CSV umgewandelt."
endfunction

