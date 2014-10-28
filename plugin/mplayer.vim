" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Mplayer frontend of Vim.
" }}}
" ============================================================================
if exists('g:loaded_mplayer')
  finish
endif
let g:loaded_mplayer = 1
let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=+ -complete=file MPlayer call mplayer#play(<f-args>)
command! -bar -nargs=+ -complete=file MPlayerEnqueue call mplayer#enqueue(<f-args>)
command! -bar -nargs=0 MPlayerStop call mplayer#stop()
command! -bar -nargs=1 MPlayerVolume call mplayer#command('volume ' . <q-args> . ' 1')
command! -bar -nargs=1 -bang MPlayerSpeed call mplayer#set_speed(<f-args>, <bang>1)
command! -bar -nargs=1 -complete=customlist,mplayer#equlizer_complete MPlayerEqualizer call mplayer#set_equalizer(<f-args>)
command! -bar -nargs=0 MPlayerToggleMute call mplayer#command('mute')
command! -bar -nargs=0 MPlayerTogglePause call mplayer#command('pause')
command! -bar -nargs=0 MPlayerToggleRTTimeInfo call mplayer#toggle_rt_timeinfo()
command! -bar -nargs=1 MPlayerLoop call mplayer#command('loop ' . <q-args> . ' 1')
command! -bar -nargs=1 MPlayerSeek call mplayer#set_seek(<f-args>)
command! -bar -nargs=0 MPlayerSeekToHead call mplayer#command('seek 0 1')
command! -bar -nargs=0 MPlayerSeekToEnd call mplayer#command('seek 100 1')
command! -bar -nargs=0 MPlayerOperateWithKey call mplayer#operate_with_key()
command! -bar -nargs=? MPlayerPrev call mplayer#prev(<f-args>)
command! -bar -nargs=? MPlayerNext call mplayer#next(<f-args>)
command! -bar -nargs=0 MPlayerShowFileInfo call mplayer#show_file_info()
command! -bar -nargs=+ -complete=customlist,mplayer#cmd_complete MPlayerCommand call mplayer#command(<q-args>, 1)
command! -bar -nargs=1 -complete=customlist,mplayer#get_property_complete MPlayerGetProperty call mplayer#command('get_property ' . <q-args>, 1)
command! -bar -nargs=+ -complete=customlist,mplayer#set_property_complete MPlayerSetProperty call mplayer#command('set_property ' . <q-args>, 1)
command! -bar -nargs=+ -complete=customlist,mplayer#step_property_complete MPlayerStepProperty call mplayer#command('step_property ' . <q-args>, 1)
command! -bar -nargs=? -complete=customlist,mplayer#help_complete  MPlayerHelp call mplayer#help(<f-args>)

command! -bar -nargs=0 MPlayerFlush call mplayer#flush()


augroup MPlayer
  autocmd!
  autocmd VimLeave * call mplayer#stop()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
