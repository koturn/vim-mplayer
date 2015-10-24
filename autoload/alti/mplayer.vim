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


function! s:get_sid() abort
  return matchstr(expand('<sfile>'), '^function <SNR>\zs\d\+\ze_get_sid$')
endfunction
let s:sid_prefix = '<SNR>' . s:get_sid() . '_'
delfunction s:get_sid
let s:define = {
      \ 'name': s:sid_prefix . 'mplayer',
      \ 'enter': s:sid_prefix . 'enter',
      \ 'cmpl': s:sid_prefix . 'cmpl',
      \ 'prompt': s:sid_prefix . 'prompt',
      \ 'submitted': s:sid_prefix . 'submitted',
      \}

function! alti#mplayer#start(...) abort
  let s:dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if s:dir[len(s:dir) - 1] !=# '/'
    let s:dir .= '/'
  endif
  let s:define.static_head = s:dir
  call alti#init(s:define)
endfunction


function! s:enter() abort dict
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  let len = len(s:dir)
  let self.candidates = map(split(globpath(s:dir . '**', glob_pattern, 1), "\n"), 'v:val[len :]')
endfunction

function! s:cmpl(context) abort dict
  return a:context.fuzzy_filtered(self.candidates)
endfunction

function! s:prompt(context) abort
  return 'MPlayer> '
endfunction

function! s:submitted(context, line) abort
  call mplayer#enqueue(s:dir . a:context.selection)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
