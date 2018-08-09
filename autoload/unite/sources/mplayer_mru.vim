" ============================================================================
" FILE: mplayer_mru.vim
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
      \ 'name': 'mplayer_mru',
      \ 'description': 'Music player (Most recent used files)',
      \ 'default_kind': 'mplayer',
      \ 'hooks': {}
      \}

function! s:source.gather_candidates(args, context) abort " {{{
  return map(mplayer#cmd#get_mru_list(), '{
        \ "action__path": v:val,
        \ "word": v:val
        \}')
endfunction " }}}

function! s:source.hooks.on_close(args, context) abort " {{{
  call unite#kinds#mplayer#stop_preview()
endfunction " }}}


function! unite#sources#mplayer_mru#define() abort " {{{
  return s:source
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
