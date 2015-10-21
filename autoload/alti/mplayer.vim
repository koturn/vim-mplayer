" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Extension for alti.vim
" alti.vim: https://github.com/LeafCage/alti.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:define = {
      \ 'name': 'mplayer',
      \ 'enter': 'alti#mplayer#enter',
      \ 'cmpl': 'alti#mplayer#cmpl',
      \ 'prompt': 'alti#mplayer#prompt',
      \ 'submitted': 'alti#mplayer#submitted',
      \}


function! alti#mplayer#start(...) abort
  let dir = a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/')
  call alti#init(alti#mplayer#define())
endfunction

function! alti#mplayer#define() abort
  return s:define
endfunction

function! alti#mplayer#enter() abort dict
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  let self.candidates = split(globpath(s:dir, glob_pattern, 1), "\n")
endfunction

function! alti#mplayer#cmpl(context) abort dict
  return a:context.fuzzy_filtered(self.candidates)
endfunction

function! alti#mplayer#prompt(context) abort
  return 'MPlayer> '
endfunction

function! alti#mplayer#submitted(context, line) abort
  call mplayer#enqueue(a:context.selection)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
