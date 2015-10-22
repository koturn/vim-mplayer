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
  let s:dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if s:dir[len(s:dir) - 1] !=# '/'
    let s:dir .= '/'
  endif
  call alti#init(alti#mplayer#define())
endfunction

function! alti#mplayer#define() abort
  return s:define
endfunction

function! alti#mplayer#enter() abort dict
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  let len = len(s:dir)
  let self.candidates = map(split(globpath(s:dir . '**', glob_pattern, 1), "\n"), 'v:val[len :]')
endfunction

function! alti#mplayer#cmpl(context) abort dict
  return a:context.fuzzy_filtered(self.candidates)
endfunction

function! alti#mplayer#prompt(context) abort
  return 'MPlayer> '
endfunction

function! alti#mplayer#submitted(context, line) abort
  call mplayer#enqueue(s:dir . a:context.selection)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
