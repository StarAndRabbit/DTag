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

" autocommand to auto refresh tags
augroup refreshtaglist
    au!
    au WinEnter * call s:RefreshTags()
    au BufReadPost * call s:RefreshTags()
    au BufWritePost * call s:RefreshTags()
augroup END

" current file's tags list
let s:tagslist = []

" current file's tags dic
let s:tagsdic = {}

let g:filename = ''

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
        let s:tagsdic[dictag.name] = deepcopy(dictag)
    endfor
endfunction

function! s:ToggleTagListWin()
    if bufwinnr('__TagList__') == -1
        let cursorin = dtagui#SaveCursorIn()
        let fname = fnamemodify(bufname('%'), ':p')
        let g:filename = bufname('')
        call dtagui#OpenTagWindow(30, 0)

        " file exist and not directory
        if getfsize(fname) != -1 && getfsize(fname) != 0
            let tags = s:GenerateTags(fname)
            call s:SplitTags(tags)
            call dtagui#RefreshUI(dtagui#GetDisplayList(s:tagslist))
        endif
        call dtagui#ResetCursorIn(cursorin)
    else
        call dtagui#CloseTagWindow()
    endif
endfunction

function! s:RefreshTags()
    if dtagui#IsTagWindowOpened() == 0
        return
    else
        let cursorin = dtagui#SaveCursorIn()
        let fname = fnamemodify(bufname('%'), ':p')
        
        "file exist and not directory
        if getfsize(fname) != -1 && getfsize(fname) != 0
            call win_gotoid(win_getid(bufwinnr('__TagList__')))
            let tags = s:GenerateTags(fname)
            let s:tagslist = []
            let s:tagsdic = {}
            call s:SplitTags(tags)
            call dtagui#RefreshUI(dtagui#GetDisplayList(s:tagslist))
            call dtagui#ResetCursorIn(cursorin)
            let g:filename = bufname('')
        endif
    endif
endfunction

command! -nargs=0 DTagToggle call s:ToggleTagListWin()

function! GetTagLine(tagname)
    if has_key(s:tagsdic, a:tagname)
        return s:tagsdic[a:tagname].line
    else
        return
    endif
endfunction
