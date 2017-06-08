syntax match typeName "\v[^(\t*(\+|\-))].*"
highlight link typeName Comment

syntax match typeSymbol "\v^\s*[\+\-]"
highlight link typeSymbol Include

syntax match tagName "\v^\s*[^(\+|\-)].*"
highlight link tagName Normal

highlight Comment ctermfg=LightBlue
highlight Include ctermfg=Red
