" ============================================================================
" FILE: mplayer_mru.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" This file is a extension for fzf.
" fzf: https://github.com/junegunn/fzf
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


function! s:sink(candidates) abort " {{{
  call mplayer#cmd#enqueue(a:candidates)
endfunction " }}}

let s:option = {
      \ 'sink*': function('s:sink'),
      \ 'down': 20,
      \ 'options': '-m'
      \}


function! fzf#mplayer_mru#start(...) abort " {{{
  let dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if dir[-1 :] !=# '/'
    let dir .= '/'
  endif
  let s:option.source = mplayer#cmd#get_mru_list()
  let s:option.dir = dir
  call fzf#run(s:option)
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo

