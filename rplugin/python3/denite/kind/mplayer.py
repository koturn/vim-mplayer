"""
FILE: mplayer.vim
AUTHOR: koturn <jeak.koutan.apple@gmail.com>
DESCRIPTION: {{{
Mplayer frontend of Vim.
This file is a extension for unite.vim and provides denite-kind.
denite.nvim: https://github.com/Shougo/denite.nvim
}}}
"""

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'mplayer'
        self.default_action = 'mplayer'

    def action_mplayer(self, context):
        self.vim.call('mplayer#cmd#enqueue', list(map(lambda target: target['action__path'], context['targets'])))

    def action_preview(self, context):
        self.vim.call('mplayer#denite#play', [context['targets'][0]['action__path']])
        return True
