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
