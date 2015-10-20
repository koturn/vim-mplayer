" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2015 10/20
" DESCRIPTION: {{{
" descriptions.
" ctrlp.vim: https://github.com/ctrlpvim/ctrlp.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim
if exists('g:loaded_ctrlp_mplayer') && g:loaded_ctrlp_mplayer
  finish
endif
let g:loaded_ctrlp_mplayer = 1
let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')
let g:ctrlp#mplayer#default_dir = get(g:, 'ctrlp#mplayer#default_dir', '~/')


let s:mplayer_var = {
      \ 'init': 'ctrlp#mplayer#init()',
      \ 'accept': 'ctrlp#mplayer#accept',
      \ 'lname': 'mplayer',
      \ 'sname': 'mplayer',
      \ 'type': 'path',
      \ 'sort': 0,
      \ 'nolim': 1
      \}
if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  call add(g:ctrlp_ext_vars, s:mplayer_var)
else
  let g:ctrlp_ext_vars = [s:mplayer_var]
endif
let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins

function! ctrlp#mplayer#start(...) abort
  let s:dir = (a:0 > 0 ? a:1 : g:ctrlp#mplayer#default_dir) . '**'
  call ctrlp#init(ctrlp#mplayer#id())
endfunction

function! ctrlp#mplayer#id() abort
  return s:id
endfunction

function! ctrlp#mplayer#init() abort
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  return split(globpath(s:dir, glob_pattern, 1), "\n")
endfunction

function! ctrlp#mplayer#accept(mode, str) abort
  call ctrlp#exit()
  call mplayer#enqueue(a:str)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
