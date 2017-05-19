let s:cmdslist = []         " commands
let s:aucmdgrpslist = []    " auto command groups
let s:funcslist = []        " functions
let s:mapslist = []         " key maps
let s:varslist = []         " variables

function! s:SplitVimTags(tagslist)
    for tag in a:tagslist
        if tag.kind == 'c'
            call add(s:cmdslist, tag.name)
        elseif tag.kind == 'a'
            call add(s:aucmdgrpslist, tag.name)
        elseif tag.kind == 'f'
            call add(s:funcslist, tag.name)
        elseif tag.kind == 'm'
            call add(s:mapslist, tag.name)
        else
            call add(s:varslist, tag.name)
        endif
    endfor
endfunction

function! s:ResetAll()
    let s:cmdslist = []
    let s:aucmdgrpslist = []
    let s:funcslist = []
    let s:mapslist = []
    let s:varslist = []
endfunction

function! vimtag#GetClassifiedTags(tagslist)
    call s:ResetAll()
    call s:SplitVimTags(a:tagslist)
    let classifiedtags = {}
    let classifiedtags['Commands'] = s:cmdslist
    let classifiedtags['AutoCommand Groups'] = s:aucmdgrpslist
    let classifiedtags['Functions'] = s:funcslist
    let classifiedtags['Maps'] = s:mapslist
    let classifiedtags['Variables'] = s:varslist
    return classifiedtags
endfunction
