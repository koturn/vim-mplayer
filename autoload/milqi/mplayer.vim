" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2015 10/27
" DESCRIPTION: {{{
" descriptions.
" milqi.vim: https://github.com/kamichidu/vim-milqi
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:define = {'name': 'kotemplate'}

function! s:define.init(context) abort
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  let len = len(s:dir)
  return map(split(globpath(s:dir . '**', glob_pattern, 1), "\n"), 'v:val[len :]')
endfunction

function! s:define.accept(context, candidate) abort
  call milqi#exit()
  call mplayer#enqueue(s:dir . a:candidate)
endfunction


function! milqi#mplayer#start(...) abort
  let s:dir = expand(a:0 > 0 ? a:1 : get(g:, 'mplayer#default_dir', '~/'))
  if s:dir[len(s:dir) - 1] !=# '/'
    let s:dir .= '/'
  endif
  call milqi#candidate_first(s:define)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
