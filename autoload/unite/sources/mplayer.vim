" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" descriptions.
" unite.vim: https://github.com/Shougo/unite.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

let g:unite#sources#mplayer#default_dir = get(g:, 'g:unite#sources#mplayer#default_dir', '~/')


let s:source = {
      \ 'name': 'mplayer',
      \ 'description': 'Music player',
      \ 'action_table': {
      \   'action': {
      \     'description': 'Play music',
      \     'is_selectable': 1
      \   }
      \ },
      \ 'default_action': 'action'
      \}

function! s:source.action_table.action.func(candidates) abort
  call mplayer#enqueue(map(copy(a:candidates), 'v:val.word'))
endfunction

function! s:source.gather_candidates(args, context) abort
  let dir = (len(a:args) > 0 ? a:args[0] : g:ctrlp#mplayer#default_dir) . '**'
  let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
  return map(split(globpath(dir, glob_pattern, 1), "\n"), '{"word": v:val}')
endfunction

function! unite#sources#mplayer#define() abort
  return s:source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
