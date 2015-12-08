" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" descriptions.
" unite.vim: https://github.com/Shougo/unite.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:kind = {
      \ 'name': 'mplayer',
      \ 'action_table': {},
      \ 'default_action': 'play_music'
      \}

let s:kind.action_table.play_music = {
      \ 'description': 'play music files',
      \ 'is_selectable': 1
      \}
function! s:kind.action_table.play_music.func(candidates) abort
  call mplayer#enqueue(map(a:candidates, 'v:val.action__path'))
endfunction


function! unite#kinds#mplayer#define() abort
  return s:kind
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
