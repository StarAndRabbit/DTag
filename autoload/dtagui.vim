" a dictionary content classified tags
let s:classifiedtags = {}

" a list content tags ready to display
let s:displaylist = []

" a list content all displayed title
let s:titlelist = []

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
function! dtagui#RefreshUI()
    let saveview = winsaveview()
    setlocal modifiable
    normal gg
    normal dG
    call append(0, s:displaylist)
    normal dd
    normal gg
    setlocal nomodifiable
    call winrestview(saveview)
endfunction

" Function: ClassifyTags
" get classified tags based on filetype
function! s:ClassifyTags(tagslist)
    if g:filetype == 'vim'
        let s:classifiedtags = vimtag#GetClassifiedTags(a:tagslist)
    elseif g:filetype == 'cpp'
        let s:classifiedtags = cpptag#GetClassifiedTags(a:tagslist)
    else
        return
    endif
endfunction

" Function: ResetDisplayList
" reset the display list
function! s:ResetDisplayList()
    let s:displaylist = []
    let s:titlelist = []
endfunction

" Function: GenerateDisplayList
" from classified tags generate display list
function! dtagui#GenerateDisplayList(tagslist)
    call s:ResetDisplayList()
    call s:ClassifyTags(a:tagslist)
    let titles = keys(s:classifiedtags)
    for title in titles
        if !empty(s:classifiedtags[title])
            call add(s:displaylist, '+' . title)
            call add(s:titlelist, title . '/')
        endif
    endfor
endfunction

function! s:GetTitleContent(title, tagsdic)
    if empty(a:title)
        return []
    else
        if empty(split(a:title, '/')[1:])
            if has_key(a:tagsdic, split(a:title, '/')[0])
                return a:tagsdic[split(a:title, '/')[0]]
            else
                return []
            endif
        else
            for tag in a:tagsdic[split(a:title, '/')[0]]
                if type(tag) == 4       " is dictonary
                    return dtagui#GetTitleContent(join(split(a:title, '/\zs')[1:], ''), tag)
                endif
            endfor
        endif
    endif
endfunction

function! s:Insert(srclist, dstlist, index)
    let tmpleft = a:srclist[:a:index]
    let tmpright = a:srclist[a:index+1:]
    return tmpleft + a:dstlist + tmpright
endfunction

function! s:GetDepth(str)
    let depth = 0
    let cnt = 0
    while cnt < len(a:str)
        if a:str[cnt] == "\t"
            let depth += 1
        else
            break
        endif
        let cnt += 1
    endwhile
    return depth
endfunction

function! s:SetDepth(str, depth)
    let cnt = 0
    let newstr = a:str
    while cnt < a:depth
        let newstr = "\t" . newstr
        let cnt += 1
    endwhile
    return newstr
endfunction
    

function! dtagui#OpenTitle(line)
    let index = a:line - 1
    let depth = s:GetDepth(s:displaylist[index]) + 1
    let s:displaylist[index] = substitute(s:displaylist[index], '\v^\s*\+', '-', '')
    let content = s:GetTitleContent(s:titlelist[index], s:classifiedtags)

    if empty(content)
        return
    endif

    " deal display and title list
    let titleaddlist = range(len(content))
    let s:titlelist = s:Insert(s:titlelist, titleaddlist, index)
    let disaddlist = []
    for tag in content
        if type(tag) == 4   " is dictonary
            for title in keys(tag)
                let tmptitle = '+' . title
                let tmptitle = s:SetDepth(tmptitle, depth)
                call add(disaddlist, tmptitle)
                let s:titlelist[len(disaddlist) + index] = s:titlelist[index] . title . '/'
            endfor
        else
            let tmptag = s:SetDepth(tag, depth)
            call add(disaddlist, tmptag)
        endif
    endfor
    let s:displaylist = s:Insert(s:displaylist, disaddlist, index)
    call dtagui#RefreshUI()
endfunction
