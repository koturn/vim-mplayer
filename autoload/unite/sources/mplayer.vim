" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file is a extension for unite.vim and provides unite-source.
" unite.vim: https://github.com/Shougo/unite.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:source = {
      \ 'name': 'mplayer',
      \ 'description': 'Music player',
      \ 'default_kind': 'mplayer',
      \ 'hooks': {}
      \}
let s:has_704_279 = v:version > 704 || v:version == 704 && has('patch279')

if exists('*getcompletion')
  function! s:source.complete(args, context, arglead, cmdline, cursorpos) abort
    let dirs = getcompletion(a:arglead, 'dir')
    let homedir = expand("~")
    return a:arglead[0] ==# '~' ? map(dirs, 'substitute(v:val, "^" . homedir, "~", "")') : dirs
  endfunction
else
  function! s:source.complete(args, context, arglead, cmdline, cursorpos) abort
    if a:arglead ==# '~'
      return ['~/']
    elseif a:arglead ==# ''
      let dirs = map(filter(split(globpath('./', '*'), "\n"),
            \ 'isdirectory(v:val)'), 'fnameescape(v:val[2 :]) . "/"')
    else
      let dirs = map(filter(split(expand(a:arglead . '*'), "\n"),
            \ 'isdirectory(v:val)'), 'fnameescape(v:val) . "/"')
    endif
    if a:arglead[0] ==# '~'
      let homedir = expand("~")
      let dirs = map(dirs, 'substitute(v:val, "^" . homedir, "~", "")')
    endif
    let arglead = tolower(a:arglead)
    return filter(dirs, '!stridx(tolower(v:val), arglead)')
  endfunction
endif

function! s:source.gather_candidates(args, context) abort
  let s:dir = expand(len(a:args) > 0 ? a:args[0] : get(g:, 'mplayer#default_dir', '~/'))
  if s:dir[-1 :] !=# '/'
    let s:dir .= '/'
  endif
  let len = len(s:dir)
  let globptn = mplayer#get_suffix_globptn()
  let gp = s:has_704_279 ? globpath(s:dir . '**', globptn, 1, 1) : split(globpath(s:dir . '**', globptn, 1), "\n")
  return map(gp, '{
        \ "action__path": v:val,
        \ "word": v:val[len :],
        \}')
endfunction

function! s:source.hooks.on_close(args, context) abort
  call unite#kinds#mplayer#stop_preview()
endfunction


function! unite#sources#mplayer#define() abort
  return s:source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
