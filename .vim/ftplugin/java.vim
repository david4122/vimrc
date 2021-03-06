
" let $JAVA_TOOL_OPTIONS = '-Xmx512m -XX:MaxPermSize=32m -Xss1m'

set wildignore+=*.class,*.jar

" Mappings
nnoremap [[ [m
nnoremap ]] ]m

" Colorscheme
highlight javaAnnotation ctermfg=red
highlight javaGenericType ctermfg=121
highlight MethodDecl ctermfg=111
highlight javaConstructor cterm=bold
highlight javaOperator ctermfg=yellow

augroup colorscheme
	autocmd Syntax java syntax match MethodDecl /\(^\s*\(public \|private \|protected \)\?\w[a-zA-Z0-9_<>]* \)\@<=\w[a-zA-Z0-9_]*\((.\{-})\)\@=/
	autocmd Syntax java syntax match javaGenericType /<.\{-}>/ containedin=javaParenT,javaParenT1,javaParenT2
	autocmd Syntax java syntax match javaConstructor /\(^\s*\(public \|private \|protected \)\)\@<=\w[a-zA-Z0-9_]*\((\)\@=/
augroup END

compiler javac

let g:srcDir = './'
if isdirectory('src')
	let g:srcDir = 'src/'
endif

let g:compileDir = './'
if isdirectory('bin')
	let g:compileDir = 'bin/'
endif

let g:testDir = './'
if isdirectory('test/')
	let g:testDir = 'test/'
endif

let g:resourceDir = './'
if isdirectory('resources')
	let g:resourceDir = './resources'
endif

if filereadable('build.gradle')
	let g:srcDir = 'src/main/java/'
	let g:testDir = 'src/test/java/'
	let g:resourceDir = 'src/main/resources'

	command! -bar Compile execute GetMakeCmd().' compileJava --console plain'

	if !exists('g:lombok_available')
		let g:lombok_available = systemlist("find ~/.gradle/caches -regextype posix-extended -regex '.*\/lombok-[0-9]+\.[0-9]+\.[0-9]+\.jar'")
		if len(g:lombok_available) > 0
			let $JAVA_TOOL_OPTIONS .= " -javaagent:".g:lombok_available[0]
		endif
	endif
else
	let &makeprg="javac -d ".g:compileDir." $(find ".g:srcDir." -name '*.java')"

	command! -bar -bang Build if <bang>0 || len(filter(getbufinfo(), 'v:val.changed')) == 0
				\ | 	make
				\ | else
				\ | 	echoerr "There are unsaved files"
				\ | endif

	command! -bar -nargs=+ -complete=custom,<SID>completeRun Run call <SID>run(<f-args>)
endif

let b:completeArgsFunc = 'JavaGenerateArgs'

if !exists('g:loaded_java') || !g:loaded_java
	let g:loaded_java = 1

	function! JavaGenerateArgs(completed)
		if empty(a:completed.abbr)
			return []
		endif
		let args = matchstr(a:completed.abbr, '\((\)\@<=.\{-}\()\)\@=')
		let args = split(args, ',')
		return args
	endfunction

	function! s:run(...)
		exe '!java -classpath '.g:compileDir.' '.a:1.(exists('a:2') ? ' < '.a:2 : '')
	endfunction

	function! s:completeRun(argLead, cmdLine, curPos)
		if len(split(a:cmdLine, '\s\+')) > 1
			return join(getcompletion(a:argLead, 'file'), "\n")
		else
			return <SID>completeClass(a:argLead, a:cmdLine, a:curPos)
		endif
	endfunction

	function! s:completePackage(argLead, cmdLine, curPos)
		let packages = split(system('ctags -R --java-kinds=p -f - '.g:srcDir), "\n")
		let packages = map(packages, 'matchstr(v:val, ''\(package \)\@<=.\{-}\(;\$\)\@='')')
		let packages = uniq(sort(packages))
		return len(packages) > 0 ? join(packages, ".\n").'.' : ''
	endfunction

	function! s:completeClass(argLead, cmdLine, curPos)
		let classes = []
		for file in globpath(g:srcDir, '**/*.java', 0, 1)
			let package = matchstr(system('ctags --java-kinds=p -f - '.file),  '\(package \)\@<=.\{-}\(;\)\@=')
			if !empty(package)
				let package.='.'
			endif

			for line in split(system('ctags --java-kinds=c -f - '.file), "\n")
				call add(classes, package.matchstr(line, '\(class \)\@<=.\{-}\( {\)\@='))
			endfor
		endfor
		return join(classes, "\n")
	endfunction

	function! s:addClass(prefix, classname)
		let path = substitute(a:classname, '\.', '/', 'g').'.java'
		let dir = fnamemodify(path, ':h')
		if !isdirectory(dir)
			call system('mkdir -p '.a:prefix.dir)
		endif
		exe 'e '.a:prefix.path
		let sepIdx = strridx(a:classname, '.')
		if sepIdx != -1
			let package = a:classname[0:sepIdx-1]
			call setline(1, 'package '.package.';')
		endif
		call append('$', '')
		call append('$', '')
		call cursor('$', 1)
		startinsert
	endfunction

	function! s:renameClass(new)
		let oldName = fnamemodify(@%, ':t:r')
		exe 'saveas '.g:srcDir.substitute(a:new, '\.', '/', 'g').'.java'
		silent! !rm #
		silent! bd #

		let idx = strridx(a:new, '.')
		exe '/class '.oldName.'/s/\(class \)\@<='.oldName.'/'.a:new[idx+1:].'/'
		exe '1s/package .\{-};/package '.a:new[:idx-1].';/'
		redraw!
	endfunction

	function! s:buildJar(filename)
		exe '!(cd '.g:compileDir.'; jar -cvfm ../'.a:filename.' ../META-INF/MANIFEST.MF * ../resources)'
	endfunction

	command! -nargs=1 -complete=custom,<SID>completePackage AddClass call s:addClass(g:srcDir, <q-args>)
	command! -nargs=1 -complete=custom,<SID>completePackage AddTest call s:addClass(g:testDir, <q-args>)
	command! -nargs=1 AddResource exe 'e '.g:resourceDir.<f-args>
	command! -nargs=1 -complete=file BuildJar call s:buildJar(<f-args>)
	command! -nargs=1 -complete=custom,<SID>completePackage RenameClass call s:renameClass(<q-args>)

	" Override fzf commands accordingly
	nnoremap <silent> <C-p> :exe 'Buffers '.g:srcDir<CR>

endif
