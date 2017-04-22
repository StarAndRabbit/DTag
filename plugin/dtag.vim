if exists('g:loaded_dtag')
    finish
else
    let g:loaded_dtag = 1
endif

if !exists('*system')
    echom 'DTag: No system() function available, skipping plugin'
    finish
endif

if !exists('g:tagbar_ctags_exe')
    if executable('exuberant-ctags')
        let g:tagbar_ctags_exe = 'exuberant-ctags'
    elseif executable('exctags')
        let g:tagbar_ctags_exe = 'exctags'
    elseif executable('ctags')
        let g:tagbar_ctags_exe = 'ctags'
    elseif executable('ctags.exe')
        let g:tagbar_ctags_exe = 'ctags.exe'
    elseif executable('tags')
        let g:tagbar_ctags_exe = 'tags'
    else
        echom 'DTag: Exuberant ctags not found, skipping plugin'
        finish
    endif
endif

" current file's tags list
let s:tagslist = []

function! s:GenerateTags(fname)
    let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nksaz --extra= --sort=yes '
    let ctags_cmd = g:tagbar_ctags_exe . ctags_args . shellescape(a:fname)
    return system(ctags_cmd)
endfunction

function! s:SplitTags(strtags)
    let dictag = {}
    for tag in split(a:strtags, '\n')
        let listtag = split(tag, '\t')
        let dictag.name = listtag[0]
        let dictag.path = listtag[1]
        let dictag.cmd = listtag[2]
        let dictag.kind = split(listtag[3], ':')[1]
        let dictag.line = split(listtag[4], ':')[1]
        call add(s:tagslist, deepcopy(dictag))
    endfor
endfunction

function! ShowTags()
    let cursorin = dtagui#SaveCursorIn()
    let fname = fnamemodify(bufname('%'), ':p')
    call dtagui#OpenTagWindow(30, 0)
    let tags = s:GenerateTags(fname)
    call s:SplitTags(tags)
    let names = []
    for tag in s:tagslist
        call add(names, tag.name)
    endfor
    call dtagui#RefreshUI(names)
    call dtagui#ResetCursorIn(cursorin)
endfunction
