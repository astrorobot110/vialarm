scriptencoding utf-8

let s:cpo = &cpoptions
set cpo&vim

let s:errormsg = {
	\ 'E01': '[vialarm]: Error: Time format must be ''HH:MM''.',
	\ 'E02': '[vialarm]: Error: No such time. :(',
	\ 'E03': '[vialarm]: Error: Command is empty.'
	\ }
 
let s:recentTime = localtime()
let g:vialarm_isRunning = 0

function! s:timerStart() abort
	if !g:vialarm_isRunning
		let s:vialarmTimer = timer_start((60-(localtime()%60))*1000, function('s:getAlarm'))
		let g:vialarm_isRunning = 1
		if v:vim_did_enter
			echo '[vialarm]: Start vialarm.'
		endif
	else
		echo '[vialarm]: Vialarm is already running.'
	endif
endfunction

function! s:timerStop() abort
	if g:vialarm_isRunning
		call timer_stop(s:vialarmTimer)
		unlet s:vialarmTimer
		let g:vialarm_isRunning = 0
		echo '[vialarm]: Stop vialarm.'
	else
		echo '[vialarm]: Vialarm is already stopping.'
	endif
endfunction

function! s:getAlarm(timer) abort
	let autocmdText = split(execute('autocmd User'), '\n')
	let matchText = '^\s\+\zs[Vv]ialarm\(_.*\)\?_'.strftime('%H:%M', localtime())
	let index = match(autocmdText, matchText)
	if index >= 0
		let alarmName = matchstr(autocmdText[index], matchText)
		execute 'doautocmd User' alarmName
	endif

	let s:recentTime = localtime()

	if timer_info(s:vialarmTimer)[0].repeat > 0
		let s:vialarmTimer = timer_start(60000, function('s:getAlarm'), {'repeat':-1})
	endif
endfunction

function! s:addOneshot(time, command) abort
	try
		if match(a:time, '^\d\d:\d\d$') < 0
			throw 'vialarm_E01'
		elseif matchstr(a:time, '^\d\d') > 23 || matchstr(a:time, '\d\d$') > 59
			throw 'vialarm_E02'
		elseif a:command ==# ''
			throw 'vialarm_E03'
		endif

		execute 'augroup vialarm_oneshots'
		execute 'autocmd User' 'Vialarm_'.a:time '++once' a:command
		execute 'augroup END'

		echo printf('[vialarm]: Added alarm in %s.', a:time)

	catch /vialarm_E01/
		echoerr s:errormsg.E01
	catch /vialarm_E02/
		echoerr s:errormsg.E02
	catch /vialarm_E03/
		echoerr s:errormsg.E03
	endtry
endfunction

function! s:showAlarms() abort
	let autocmdText = split(execute('verbose autocmd User'), '\n')[1:]

	let currentGroup = ''
	let currentLine = 0

	echohl Title
	echo '[vialarm]: Current alarm is...'
	echohl None

	while currentLine < len(autocmdText)
		if match(autocmdText[currentLine], '^\S') >= 0
			let currentGroup = autocmdText[currentLine]
			let currentLine += 1
		elseif match(autocmdText[currentLine], '^\s\+[Vv]ialarm_') >= 0
			if currentGroup !=# ''
				echohl Title
				echo currentGroup
				echohl None
				let currentGroup = ''
			endif
			let lines = match(autocmdText[currentLine], '\d\d:\d\d$') >= 0 ? 3 : 2
			echo join(autocmdText[currentLine:currentLine+lines-1], "\n")
			let currentLine += lines
		else
			let currentLine += 1
		endif
	endwhile
endfunction

function! s:showTimerInfo() abort
	echohl Title
	if exists('s:vialarmTimer')
		echo '[vialarm]: Vialarm is running. Current timer information is...'
		echohl None

		let timerState = deepcopy(timer_info(s:vialarmTimer)[0])

		for k in filter(keys(timerState), 'v:val !=? "callback"')
			echo printf('  %-10S: %d', k, timerState[k])
		endfor
	else
		echo '[vialarm]: Vialarm was stopped.'
		echohl None
	endif
endfunction

function! vialarm#main(args) abort
	let args = split(a:args, '\s')

	if len(args) == 0
		call s:showAlarms()
	elseif args[0] =~? '^\d\+'
		try
			if len(args) > 1
				let time = args[0]
				let command = join(args[1:], ' ')
				call s:addOneshot(time, command)
			else
				throw 'vialarm_E03'
			endif
		catch /vialarm_E03/
			echoerr s:errormsg.E03
		endtry
	elseif args[0] ==? 'start'
		call s:timerStart()
	elseif args[0] ==? 'stop'
		call s:timerStop()
	elseif args[0] == 'timer'
		call s:showTimerInfo()
	endif
endfunction

function! vialarm#stackedAlarm() abort
	let autocmdText = split(execute('autocmd User'), '\n')
			\ ->filter('v:val =~# ''^\s\+Vialarm''')
			\ ->map({_, val->split(val, '\s\+')[0]})

	while s:recentTime < localtime()
		let timeText = strftime('%H:%M', s:recentTime)
		let matchText = '^\s\+\zsVialarm\(_.*\)\?_'..timeText
		for alarmName in filter(deepcopy(autocmdText), 'v:val =~# matchText')
			execute 'doautocmd User' alarmName
		endfor

		let s:recentTime += 60
	endwhile

	let s:recentTime = localtime()
endfunction

let &cpoptions = s:cpo
