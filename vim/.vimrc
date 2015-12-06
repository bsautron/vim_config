syntax on
set cindent

inoremap ( ()<left>
inoremap { {}<left>
inoremap [ []<left>
inoremap ' ''<left>
inoremap " ""<left>
inoremap < <><left>

set statusline +=line:\ %l\ col:\ %c

hi MulSpaces ctermbg=red ctermfg=white cterm=bold
match MulSpaces / [ ]\+/

hi EndSpace ctermbg=blue ctermfg=white cterm=bold
2match EndSpace / $/

call system("mkdir -p ~/.vim.d")
set backupdir=~/.vim.d
set directory=~/.vim.d

fu! Pad(str, width)
	return a:str . repeat(' ', a:width - len(a:str))
endfunction

fu! CheckLine(line1, line2)
	if a:line1 == a:line2
		return 1
	endif
	return 0
endfunction

fu! HaveHeader()
	let line = [strlen(getline(1)) == 80 && match(getline(1), '\/\* \*\+ \*\/') != -1]
	call add(line, strlen(getline(2)) == 80 && match(getline(2), '\/\* \+\*\/') != -1)
	call add(line, strlen(getline(3)) == 80 && match(getline(3), '\/\* \+::: \+:::::::: \+\*\/') != -1)
	call add(line, strlen(getline(4)) == 80 && match(getline(4), '\/\* \+\S\+ \+:+: \+:+: \+:+: \+\*\/') != -1)
	call add(line, strlen(getline(5)) == 80 && match(getline(5), '\/\* \++:+ +:+ \++:+ \+\*\/') != -1)
	call add(line, strlen(getline(6)) == 80 && match(getline(6), '\/\* \+By: \S\+ <\S\+@\S\+> \++#+ \++:+ \++#+ \+\*\/') != -1)
	call add(line, strlen(getline(7)) == 80 && match(getline(7), '\/\* \++#+#+#+#+#+ \++#+ \+\*\/') != -1)
	call add(line, strlen(getline(8)) == 80 && match(getline(8), '\/\* \+Created: [0-9]\{4}\/[0-9]\{2\}\/[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} by \S\+ \+#+# \+#+# \+\*\/') != -1)
	call add(line, strlen(getline(9)) == 80 && match(getline(9), '\/\* \+Updated: [0-9]\{4}\/[0-9]\{2\}\/[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} by \S\+ \+###   ########\.fr \+\*\/') != -1)
	call add(line, strlen(getline(10)) == 80 && match(getline(10), '\/\* \+\*\/') != -1)
	call add(line, strlen(getline(11)) == 80 && match(getline(11), '\/\* \*\+ \*\/') != -1)
	if join(line, "") == "11111111111"
		return 1
	return 0
	endif
endfunction

fu! MakeHeader()
	let filenameLine = "/*   " . Pad(expand("%:t"), 51) . ":+:      :+:    :+:   */"
	let user = $USER
	let email = exists("$MAIL") ? $MAIL : $USER . "@student.42.fr"
	let usermailLine = "/*   " . Pad("By: " . user . " <" . email . ">", 47) . "+#+  +:+       +#+        */"
	let now =  strftime("%Y/%m/%d %X")
	let createdLine = "/*   Created: " . Pad(now . " by ". user, 41) . "#+#    #+#             */"
	let updatedLine = "/*   Updated: " . Pad(now . " by ". user, 40) . "###   ########.fr       */"

	let head = ["/* ************************************************************************** */"]
	call add(head, "/*                                                                            */")
	call add(head, "/*                                                        :::      ::::::::   */")
	call add(head, filenameLine)
	call add(head, "/*                                                    +:+ +:+         +:+     */")
	call add(head, usermailLine)
	call add(head, "/*                                                +#+#+#+#+#+   +#+           */")
	call add(head, createdLine)
	call add(head, updatedLine)
	call add(head, "/*                                                                            */")
	call add(head, "/* ************************************************************************** */")
	return head
endfunction

fu! PutHeader()
	if HaveHeader() == 0
		let head = MakeHeader()
		let i = 0
		while i <= 10
			call append(i, head[i])
			let i += 1
		endwhile
		call append(i, "")
	endif
endfunction

fu! GetLastUpdateBuff()
	if &modified == 0 && HaveHeader()
		let b:edited = 0
		let b:updated = getline(9)
	else
		let b:edited = 1
	endif
endfunction

fu! SetLastUpdateBuff()
	if b:edited == 0 && HaveHeader()
		call setline(9, b:updated)
	endif
endfunction

let b:edited = 0
:autocmd BufWritePre *.c :call GetLastUpdateBuff()
:autocmd BufWritePost *.c :call SetLastUpdateBuff()

nnoremap <C-c>h <esc>:call PutHeader()<cr>
