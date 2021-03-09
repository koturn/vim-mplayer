" ============================================================================
" FILE: mplayer_mru.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file is a extension for alti.vim.
" alti.vim: https://github.com/LeafCage/alti.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


" {{{ Get SID prefix
function! s:get_sid_prefix() abort " {{{
  return matchstr(expand('<sfile>'), 'function \zs<SNR>\d\+_\zeget_sid_prefix$')
endfunction " }}}
let s:sid_prefix = s:get_sid_prefix()
delfunction s:get_sid_prefix
" }}}

let s:define = {
      \ 'name': 'mplayer_mru',
      \ 'enter': s:sid_prefix . 'enter',
      \ 'cmpl': s:sid_prefix . 'cmpl',
      \ 'prompt': s:sid_prefix . 'prompt',
      \ 'submitted': s:sid_prefix . 'submitted',
      \}
unlet s:sid_prefix

function! alti#mplayer_mru#start(...) abort " {{{
  call alti#init(s:define)
endfunction " }}}


function! s:enter() abort dict " {{{
  let self.candidates = mplayer#cmd#get_mru_list()
endfunction " }}}

function! s:cmpl(context) abort dict " {{{
  return a:context.fuzzy_filtered(self.candidates)
endfunction " }}}

function! s:prompt(context) abort " {{{
  return 'MPlayerMru> '
endfunction " }}}

function! s:submitted(context, line) abort " {{{
  call mplayer#cmd#enqueue(len(a:context.inputs) == 0 ? a:context.selection : a:context.inputs)
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
