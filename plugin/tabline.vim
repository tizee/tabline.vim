" File: tabline.vim
" Author: tizee
" Email: 33030965+tizee@users.noreply.github.com
" Github: https://github.com/tizee/tabline.vim
" Description: a tabline plugin
scriptencoding utf-8

if exists('loaded_tabline_vim') || &cp || v:version < 700
  finish
endif

let g:loaded_tabline_vim = 1

let s:tab_seperator_left = '┃'
let s:tab_seperator_right= ' '

function! s:TabTitle(tabnumber)
  let buflist = filter(tabpagebuflist(a:tabnumber),"bufname(v:val)[0] !=# '!'")
  let winnr = tabpagewinnr(a:tabnumber)
  let bufnr = buflist[winnr-1]
  let name = bufname(bufnr)
  let buf_filetype_icon = ''
  " vim-devicons
  if exists('*WebDevIconsGetFileTypeSymbol') && empty(getbufvar(bufnr, '&buftype'))
    let buf_filetype=getbufvar(bufnr, '&filetype')
    if !empty(buf_filetype)
      let buf_filetype_icon=get(g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols,buf_filetype,'')
      if empty(buf_filetype_icon)
        let buf_filetype_icon=WebDevIconsGetFileTypeSymbol(name)
      endif
    endif
  endif

  let listlen = len(buflist)
  " handle special buffers
  " empty buffer
  if !strlen(name)
    let name = '[No Name]'
  endif
  " terminal
  if getbufvar(bufnr, '&buftype') == 'terminal'
    " truncate to last 20 characters
    let name = name[-15:]
    let name = '[Term] ' .. name
  endif

  let flag = ' '
  let modified = getbufvar(bufnr, '&modified')
  if modified
    let flag .= '+ '
  endif
  let changed = getbufvar(bufnr, 'tabline_buf_changed', 0)
  if changed
    let flag .= '! '
  endif
  if !modified && !changed
    call setbufvar(bufnr, 'tabline_buf_changed', 0)
    let flag = ' '
  endif
  if listlen == 1
    let listlen = ''
  endif
  return listlen .. flag  .. name .. ' ' .. buf_filetype_icon
endfunction

" highlight groups for tab
" hl-TabLine     Tab pages line, not active tab page label.
" hl-TabLineSel  Tab pages line, active tab page label.
" hl-TabLineFill Tab pages line, where there are no labels.

function s:TabMouseClickStr(tabnumber)
  return '%' .. (a:tabnumber) .. 'T'
endfunction

" tabline use the same options from statusline
" generate tabline format string
function! SimpleTabline()
  let hl_current='%#TabLineSel#'
  let hl_reset='%#TabLine#'
  let hl_fill='%#TabLineFill#'
  let format_str = ''
  " i starts from 0
  " tab number starts from 1
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      " active tab highlight group
      let format_str ..= hl_current
    else
      " inactive tab highlight group
      let format_str ..= hl_reset
    endif
    let format_str ..= s:tab_seperator_left
    " mouse click
    let format_str ..= s:TabMouseClickStr(i+1)
    " tab title
    let format_str ..= s:TabTitle(i+1)
    let format_str ..= s:tab_seperator_right
    " fill and reset tab page number
    let format_str ..= hl_fill .. '%T'
  endfor
  " add a close button if there is more than one tab
  if tabpagenr("$") > 1
    " close symbol
    let format_str ..= '%='. hl_reset .. '%999XX'
  endif
  return format_str
endfunction

augroup Tabline
  autocmd!
  autocmd BufEnter,InsertEnter,TextChanged * silent! checktime
  autocmd BufWritePost,BufReadPost,BufNewFile * silent! let b:tabline_buf_changed = 0
  autocmd FileChangedShell * call setbufvar(expand('<a-file>'), 'tabline_buf_changed', 1)
augroup END

set tabline=%!SimpleTabline()

" vim:set et sw=2 ts=2 tw=120
