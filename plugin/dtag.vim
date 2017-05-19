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
let g:filetype = ''

function! s:GenerateTags(fname)
    let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nksaz --extra= --sort=yes '
    let ctags_cmd = g:tagbar_ctags_exe . ctags_args . shellescape(a:fname)
    return system(ctags_cmd)
endfunction

function! s:SplitTags(strtags)
    let dictag = {}
    for tag in split(a:strtags, '\n')

        " split each tag
        let listtag = split(tag, '\t')

        let dictag.name = listtag[0]
        let dictag.path = listtag[1]
        let dictag.cmd = listtag[2]

        " split all attributes
        let vartag = listtag[3:]
        for var in vartag
            let attr = split(var, ':')[0]
            let value = join(split(var, ':')[1:])
            let dictag[attr] = value
        endfor

        call add(s:tagslist, deepcopy(dictag))
        let s:tagsdic[dictag.name] = deepcopy(dictag)
    endfor
endfunction

function! s:ToggleTagListWin()
    if bufwinnr('__TagList__') == -1
        let cursorin = dtagui#SaveCursorIn()
        let fname = fnamemodify(bufname('%'), ':p')
        let g:filename = bufname('')
        let g:filetype = &filetype
        call dtagui#OpenTagWindow(30, 0)

        " file exist and not directory
        if getfsize(fname) != -1 && getfsize(fname) != 0
            let tags = s:GenerateTags(fname)
            call s:SplitTags(tags)
            call dtagui#GenerateDisplayList(s:tagslist)
            call dtagui#RefreshUI()
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
        if getfsize(fname) != -1 && getfsize(fname) != 0 && bufname('') != g:filename
            call win_gotoid(win_getid(bufwinnr('__TagList__')))
            let tags = s:GenerateTags(fname)
            let s:tagslist = []
            let s:tagsdic = {}
            call s:SplitTags(tags)
            call dtagui#GenerateDisplayList(s:tagslist)
            call dtagui#RefreshUI()
            call dtagui#ResetCursorIn(cursorin)
            let g:filename = bufname('')
            let g:filetype = &filetype
        endif
    endif
endfunction

command! -nargs=0 DTagToggle call s:ToggleTagListWin()
