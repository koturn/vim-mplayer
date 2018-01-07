" ============================================================================
" FILE: mplayer_mru.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file is a extension for vim-milqi.
" milqi.vim: https://github.com/kamichidu/vim-milqi
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:define = {'name': 'mplayer_mru'}

function! s:define.init(context) abort
  return mplayer#cmd#get_mru_list()
endfunction

function! s:define.accept(context, candidate) abort
  call milqi#exit()
  call mplayer#cmd#enqueue(a:candidate)
endfunction


function! milqi#mplayer_mru#start(...) abort
  call milqi#candidate_first(s:define)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
