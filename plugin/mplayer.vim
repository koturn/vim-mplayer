" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
if exists('g:loaded_mplayer')
  finish
endif
let g:loaded_mplayer = 1
let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=+ -complete=file MPlayer call mplayer#cmd#play(<f-args>)
command! -bar -nargs=+ -complete=file MPlayerEnqueue call mplayer#cmd#enqueue(<f-args>)
command! -bar -nargs=0 MPlayerStop call mplayer#cmd#stop()
command! -bar -nargs=0 MPlayerKill call mplayer#cmd#kill()
command! -bar -nargs=1 MPlayerVolume call mplayer#cmd#set_volume(<f-args>)
command! -bar -nargs=0 MPlayerVolumeBar call mplayer#cmd#volumebar()
command! -bar -nargs=1 -bang MPlayerSpeed call mplayer#cmd#set_speed(<f-args>, <bang>1)
command! -bar -nargs=1 -complete=customlist,mplayer#complete#equlizer MPlayerEqualizer call mplayer#cmd#set_equalizer(<f-args>)
command! -bar -nargs=0 MPlayerMute call mplayer#cmd#toggle_mute()
command! -bar -nargs=0 MPlayerPause call mplayer#cmd#toggle_pause()
command! -bar -nargs=0 MPlayerRTTimeInfo call mplayer#cmd#toggle_rt_timeinfo()
command! -bar -nargs=1 MPlayerLoop call mplayer#cmd#set_loop()
command! -bar -nargs=1 MPlayerSeek call mplayer#cmd#set_seek(<f-args>)
command! -bar -nargs=0 MPlayerSeekToHead call mplayer#cmd#set_seek_to_head()
command! -bar -nargs=0 MPlayerSeekToEnd call mplayer#cmd#set_seek_to_end()
command! -bar -nargs=0 MPlayerOperateWithKey call mplayer#cmd#operate_with_key()
command! -bar -nargs=? MPlayerPrev call mplayer#cmd#prev(<f-args>)
command! -bar -nargs=? MPlayerNext call mplayer#cmd#next(<f-args>)
command! -bar -nargs=0 MPlayerShowFileInfo call mplayer#cmd#show_file_info()
command! -bar -nargs=+ -complete=customlist,mplayer#complete#cmd MPlayerCommand call mplayer#cmd#command(<q-args>)
command! -bar -nargs=1 -complete=customlist,mplayer#complete#get_property MPlayerGetProperty call mplayer#cmd#command('get_property ' . <q-args>)
command! -bar -nargs=+ -complete=customlist,mplayer#complete#set_property MPlayerSetProperty call mplayer#cmd#command('set_property ' . <q-args>)
command! -bar -nargs=+ -complete=customlist,mplayer#complete#step_property MPlayerStepProperty call mplayer#cmd#command('step_property ' . <q-args>)
command! -bar -nargs=? -complete=customlist,mplayer#complete#help  MPlayerHelp call mplayer#cmd#help(<f-args>)

command! -bar -nargs=0 MPlayerFlush call mplayer#cmd#flush()

command! -nargs=? -complete=dir CtrlPMPlayer  call ctrlp#mplayer#start(<f-args>)
command! -nargs=? -complete=dir AltiMPlayer  call alti#mplayer#start(<f-args>)
command! -nargs=? -complete=dir MilqiMPlayer  call milqi#mplayer#start(<f-args>)
command! -nargs=? -complete=dir FZFMPlayer  call fzf#mplayer#start(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
