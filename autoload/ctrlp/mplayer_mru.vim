" ============================================================================
" FILE: mplayer_mru.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file is a extension for ctrlp.vim.
" ctrlp.vim: https://github.com/ctrlpvim/ctrlp.vim
" }}}
" ============================================================================
if exists('g:loaded_ctrlp_mplayer_mru') && g:loaded_ctrlp_mplayer_mru
  finish
endif
let g:loaded_ctrlp_mplayer_mru = 1
let s:save_cpo = &cpo
set cpo&vim

augroup MPlayerMruCtrlP " {{{
  autocmd!
augroup END " }}}

let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')

" {{{ Get SID prefix
function! s:get_sid_prefix() abort " {{{
  return matchstr(expand('<sfile>'), 'function \zs<SNR>\d\+_\zeget_sid_prefix$')
endfunction " }}}
let s:sid_prefix = s:get_sid_prefix()
delfunction s:get_sid_prefix
" }}}

let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), {
      \ 'init': s:sid_prefix  . 'init()',
      \ 'accept': s:sid_prefix  . 'accept',
      \ 'exit': s:sid_prefix  . 'exit()',
      \ 'lname': 'mplayer_mru',
      \ 'sname': 'mplayer_mru',
      \ 'type': 'path',
      \ 'sort': 0,
      \ 'nolim': 1,
      \ 'opmul': 1
      \})
let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins s:sid_prefix


function! ctrlp#mplayer_mru#start(...) abort " {{{
  let s:dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if s:dir[-1 :] !=# '/'
    let s:dir .= '/'
  endif
  call ctrlp#init(s:id, {'dir': s:dir})
endfunction " }}}


function! s:init() abort " {{{
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  if g:mplayer#enable_ctrlp_multi_select
    autocmd! MPlayerMruCtrlP BufReadCmd
    execute 'autocmd MPlayerMruCtrlP BufReadCmd' glob_pattern 'call s:enqueue_hook()'
  endif
  return mplayer#cmd#get_mru_list()
endfunction " }}}

function! s:accept(mode, str) abort " {{{
  call ctrlp#exit()
  call mplayer#cmd#enqueue(a:str)
endfunction " }}}

function! s:exit() abort " {{{
  if g:mplayer#enable_ctrlp_multi_select
    autocmd MPlayerMruCtrlP CursorHold,CursorHoldI,CursorMoved,CursorMovedI,InsertEnter * call s:delete_autocmds_hook()
  endif
endfunction " }}}


function! s:enqueue_hook() abort " {{{
  call mplayer#cmd#enqueue(expand('%:p'))
  bwipeout
endfunction " }}}

function! s:delete_autocmds_hook() abort " {{{
  autocmd! MPlayerMruCtrlP CursorHold,CursorHoldI,CursorMoved,CursorMovedI,InsertEnter *
  autocmd! MPlayerMruCtrlP BufReadCmd
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
