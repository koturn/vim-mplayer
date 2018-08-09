" ============================================================================
" FILE: denite.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file provides helper functions for denite-source.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


" {{{ Script local variables
let s:mplayer = mplayer#new()
" }}}

function! mplayer#denite#play(path) abort " {{{
  call s:mplayer.play(a:path)
endfunction " }}}

function! mplayer#denite#stop() abort " {{{
  call s:mplayer.stop()
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
