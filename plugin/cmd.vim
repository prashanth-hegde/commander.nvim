if exists('g:loaded_commander') | finish | endif        " prevent loading file twice

let s:save_cpo = &cpo                               " save user coptions
set cpo&vim                                         " reset them to defaults

command! Commander lua require'commander'.execute_command()

let &cpo = s:save_cpo                               " and restore after
unlet s:save_cpo

let g:loaded_commander = 1
