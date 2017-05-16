function! JumpToTagLine(line)
    call win_gotoid(win_getid(bufwinnr(g:filename)))
    call cursor(a:line, 1)
    normal zz
endfunction

nnoremap <buffer> <silent> <enter> :call JumpToTagLine(GetTagLine(dtagui#GetNameFromLine(line('.'))))<enter>
