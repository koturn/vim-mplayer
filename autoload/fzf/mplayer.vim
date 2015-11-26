" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2015 11/03
" DESCRIPTION: {{{
" descriptions.
" fzf: https://github.com/junegunn/fzf
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


function! s:sink(candidates) abort
  call mplayer#enqueue(a:candidates)
endfunction

let s:option = {
        \ 'sink*': function('s:sink'),
        \ 'down': 20,
        \ 'options': '-m'
        \}


function! fzf#mplayer#start(...) abort
  let dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if dir[-1 :] !=# '/'
    let dir .= '/'
  endif
  let s:option.source = s:gather_candidates(dir)
  let s:option.dir = dir
  call fzf#run(s:option)
endfunction


function! s:gather_candidates(dir) abort
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  let len = len(a:dir)
  return map(split(globpath(a:dir . '**', glob_pattern, 1), "\n"), 'v:val[len :]')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
