"""
FILE: mplayer.vim
AUTHOR: koturn <jeak.koutan.apple@gmail.com>
DESCRIPTION: {{{
Mplayer frontend of Vim.
denite.nvim: https://github.com/Shougo/
}}}
"""

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'mplayer'

    def action_default(self, context):
        self.vim.call('mplayer#cmd#enqueue', list(map(lambda e: e['action__path'], context['targets'])))
