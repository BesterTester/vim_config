" Syntax highlighting for access proxy logs

" Key=value pairs in quotes with separate colors for key and value
" Whole "key=value" (optional, mainly to scope things)
syntax region LogPair start=/"/ end=/"/ contains=LogKey,LogValue
" Key before the =
" syntax match LogKey /[A-Za-z0-9_-]\+\ze\s*=/ containedin=ALL
syntax match LogKey /[A-Za-z0-9_-]\+\ze\s*=/ contained
" Value after the =
" syntax match LogValue /=\s*\zs[^"]*/ containedin=ALL
syntax match LogValue /=\s*\zs[^"]*/ contained

" UUID at the beginning of each line (in brackets)
syntax match LogUUID /^\[\x\{8}-\x\{4}-\x\{4}-\x\{4}-\x\{12}\]/
" Timestamp [03/May/2023:11:03:27 +0200]
syntax match LogTimestamp /\[\d\{2}\/\w\{3}\/\d\{4}:\d\{2}:\d\{2}:\d\{2} [+-]\d\{4}\]/
" HTTP Method with URL and protocol: GET /path HTTP/1.1
syntax match LogHTTP /"\(GET\|POST\|PUT\|DELETE\|PATCH\|HEAD\|OPTIONS\) [^"]\+ HTTP\/1\.1"/
" IP addresses
syntax match LogIP /\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}/

" HTTP Status codes with byte count
syntax match LogStatus2xx /\<2\d\d \d\+\>/
syntax match LogStatus3xx /\<3\d\d \d\+\>/
syntax match LogStatus4xx /\<4\d\d \d\+\>/
syntax match LogStatus5xx /\<5\d\d \d\+\>/

" Link to standard vim highlight groups
highlight link LogKeyValue Special
highlight link LogUUID Identifier
highlight link LogTimestamp Identifier
highlight link LogHTTP Statement
highlight link LogIP Constant

highlight link LogKey Type
" highlight link LogEquals Special
highlight link LogValue String

highlight link LogStatus2xx SpecialKey
highlight link LogStatus3xx Question
highlight link LogStatus4xx WarningMsg
highlight link LogStatus5xx ErrorMsg
