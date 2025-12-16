" Syntax highlighting for access proxy logs

" Key=value pairs in quotes with separate colors for key and value
syntax match LogPair /\"[^\"]*=[^\"]*\"/ contains=LogKey,LogValue
syntax match LogKey /[A-Za-z0-9_-]\+\ze\s*=/ contained
syntax match LogValue /=\s*\zs[^\"]*/ contained

" UUID and time stamps (in brackets)
syntax match LogSquareBrackets /\[.\{-}\]/

" HTTP Method with URL and protocol: GET /path HTTP/1.1
syntax match LogHTTP /"\(GET\|POST\|PUT\|DELETE\|PATCH\|HEAD\|OPTIONS\) [^"]\+ HTTP\/1\.1"/

" HTTP Status codes with byte count
syntax match LogStatus2xx /\<2\d\d \d\+\>/
syntax match LogStatus3xx /\<3\d\d \d\+\>/
syntax match LogStatus4xx /\<4\d\d \d\+\>/
syntax match LogStatus5xx /\<5\d\d \d\+\>/

" IP addresses
syntax match LogIP /\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}/
syntax match LogIP /[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}:[a-f0-9]\{0,4}/


" Link to standard vim highlight groups
highlight link LogKey               Statement
highlight link LogValue             String

highlight link LogSquareBrackets    Identifier
highlight link LogHTTP              Statement
highlight link LogIP                Question

highlight link LogStatus2xx         SpecialKey
highlight link LogStatus3xx         Question
highlight link LogStatus4xx         WarningMsg
highlight link LogStatus5xx         ErrorMsg
