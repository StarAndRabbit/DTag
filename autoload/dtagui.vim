" Function: OpenTagWindow
" show taglist window, the winpos's value make sure the window's pos,
" '0' show the window in right, '1' show the window in left
function! dtagui#OpenTagWindow(winsize, winpos)
    let cmd = 'silent! ' . (a:winpos ? 'vertical topleft ' : 'vertical botright ') . a:winsize . 'split ' . '__TagList__'
    execute(cmd)
    setlocal filetype=taglist
    setlocal noreadonly
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal bufhidden=delete
    setlocal nomodifiable
    setlocal nowrap
    setlocal nonumber
endfunction

" Function: CloseTagWindow
" close taglist window
function! dtagui#CloseTagWindow()
    let cursorin = dtagui#SaveCursorIn()
    let tagwinnr = bufwinnr('__TagList__')
    if tagwinnr == -1
        return
    else
        call win_gotoid(win_getid(tagwinnr))
        execute('q!')
    endif
    call dtagui#ResetCursorIn(cursorin)
endfunction

" Function: IsTagWindowOpened
" if tag window opened, return 1, else return 0
function! dtagui#IsTagWindowOpened()
    if bufwinnr('__TagList__') == -1
        return 0
    else
        return 1
    endif
endfunction

" Function: SaveCursorIn
" save the window's id that cursor in
function! dtagui#SaveCursorIn()
    return win_getid(winnr())
endfunction

" Function: ResetCursorIn
" reset cursor to saved window
function! dtagui#ResetCursorIn(cursorin)
    call win_gotoid(a:cursorin)
endfunction

" Function: RefreshUI
" refresh the ui display
function! dtagui#RefreshUI(list)
    let saveview = winsaveview()
    setlocal modifiable
    normal gg
    normal dG
    call append(0, a:list)
    normal dd
    normal gg
    setlocal nomodifiable
    call winrestview(saveview)
endfunction

" Function: GetFunctionsList
" from tags list get functions list
function! s:GetFunctionsList(tagslist)
    let funclist = []
    for tag in a:tagslist
        if tag.kind == 'f'
            call add(funclist, "\t" . tag.name)
        endif
    endfor
    return funclist
endfunction

" Function: GetVariablesList
" from tags list get variables list
function! s:GetVariablesList(tagslist)
    let varslist = []
    for tag in a:tagslist
        if tag.kind == 'v'
            call add(varslist, "\t" . tag.name)
        endif
    endfor
    return varslist
endfunction

function! dtagui#GetDisplayList(tagslist)
    let funclist = s:GetFunctionsList(a:tagslist)
    let varslist = s:GetVariablesList(a:tagslist)
    let dislist = []
    if !empty(funclist)
        call add(dislist, 'Functions:')
        call extend(dislist, funclist)
    endif
    if !empty(varslist)
        call add(dislist, 'Variables:')
        call extend(dislist, varslist)
    endif
    return dislist
endfunction

function! dtagui#GetNameFromLine(line)
    return substitute(getline(a:line), '\v\t', '', "")
endfunction
