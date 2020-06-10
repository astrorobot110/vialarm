scriptencoding utf-8

let s:cpo = &cpoptions
set cpo&vim

command! -nargs=* -complete=command Vialarm call vialarm#main(<q-args>)

augroup vialarm_system
	autocmd!
	autocmd FocusGained * call vialarm#stackedAlarm()
augroup END

let &cpoptions = s:cpo
