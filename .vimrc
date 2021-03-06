
" TODO tab selects next arg / jumps to the end of method call

if &diff
	let g:quick_mode = 1
elseif !exists('g:quick_mode')
	let g:quick_mode = 0
endif
let g:colors_supported = system('tput colors') =~ '256'

if empty(glob('~/.vim/autoload/plug.vim'))
	if executable('curl')
		echom 'Downloading plugin manager...'
		call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
		autocmd VimEnter * PlugInstall --sync
	else
		echoerr 'Could not install plugin manager: curl not installed'
	endif
endif

" Plugins {{{1
call plug#begin('~/.vim/bundle')

Plug 'ap/vim-css-color'
Plug 'blueyed/smarty.vim', {'for': 'smarty'}
Plug 'chrisbra/csv.vim', {'for': 'csv'}
Plug 'dylanaraps/fff.vim'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'joonty/vdebug', {'on': 'VdebugStart'}
Plug 'junegunn/fzf', {'do': './install --bin'}
Plug 'junegunn/fzf.vim'
Plug 'kabbamine/vcoolor.vim', {'on': ['VCoolor', 'VCoolIns']}
Plug 'mattn/emmet-vim', {'for': ['html', 'smarty', 'php', 'xml', 'fxml']}
Plug 'sirver/ultisnips'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'valloric/matchtagalways', {'for': ['html', 'xml', 'php', 'smarty', 'fxml']}
Plug 'udalov/kotlin-vim'

if !g:quick_mode
	let ycm_cmd = './install.py --java-completer --cs-completer --clangd-completer'
	if exists('g:no_ycm') && g:no_ycm
		Plug 'Valloric/YouCompleteMe', {'do': ycm_cmd, 'on': 'YcmCompleter'}
	else
		Plug 'Valloric/YouCompleteMe', {'do': ycm_cmd}
	endif
	Plug 'chiel92/vim-autoformat'
	Plug 'majutsushi/tagbar'
	Plug 'mbbill/undotree'
	Plug 'mhinz/vim-signify'
	Plug 'tpope/vim-dispatch'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-obsession'
	Plug 'tpope/vim-dadbod'
	Plug 'kristijanhusak/vim-dadbod-ui'
	Plug 'ludovicchabant/vim-gutentags'
	Plug 'CoatiSoftware/vim-sourcetrail'
endif

if g:colors_supported
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'ryanoasis/vim-devicons'
endif

if filereadable('build.gradle') || filereadable('build.gradle.kts')
	Plug 'tfnico/vim-gradle'
endif

call plug#end()

" Plugins' setup {{{2
if !g:quick_mode
	" Tagbar
	let g:tagbar_width = 50
	let g:tagbar_singleclick = 1

	" Undotree
	let g:undotree_WindowLayout = 3
	let g:undotree_SplitWidth = 40
	let g:undotree_SetFocusWhenToggle = 1

	let g:window_right_pane_threshold = 150

	function! s:toggleRightPane()
		if &columns > g:window_right_pane_threshold
			if exists('t:right_pane_content') && t:right_pane_content == 'tagbar'
				TagbarOpen
			elseif exists('t:right_pane_content') && t:right_pane_content == 'undotree'
				UndotreeShow
			endif
		else
			TagbarClose
			UndotreeHide
		endif
	endfunction

	augroup rightPane
		autocmd!
		autocmd VimEnter * let t:right_pane_content = 'tagbar'
		autocmd VimEnter,VimResized * call <SID>toggleRightPane()
	augroup END

	function! s:swapUndotreeTagbar()
		let tagbar_buffer = filter(getbufinfo(),
					\ "v:val['name'] =~ 'Tagbar' && <SID>openedInCurrentTab(v:val['name'])")
		if len(tagbar_buffer) > 0
			TagbarClose
			UndotreeShow
			let t:right_pane_content = 'undotree'
		else
			UndotreeHide
			TagbarOpen
			let t:right_pane_content = 'tagbar'
		endif
	endfunction

	nnoremap <silent> <C-u> :call <SID>swapUndotreeTagbar()<CR>

	" Signify
	let g:signify_sign_change = '~'

	" YouCompleteMe
	if !exists('g:loaded_youcompleteme') || !g:loaded_youcompleteme
		let g:ycm_key_list_select_completion = ['`']
		let g:ycm_key_list_previous_completion = ['~']
		let g:ycm_always_populate_location_list = 1
		" let g:ycm_auto_trigger = 0
		let g:airline#extensions#ycm#enabled = 1

		let g:ycm_language_server = [
					\	{
					\		'name': 'kotlin',
					\		'filetypes': ['kotlin'],
					\		'cmdline': [ $HOME.'/repos/kotlin-language-server/server/build/install/server/bin/kotlin-language-server' ]
					\	}
					\ ]

	endif

	nnoremap <leader>f :YcmCompleter FixIt<CR>

endif

if g:colors_supported
	" Airline
	let g:airline_powerline_fonts = 1
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#show_buffers = 1
	let g:airline_theme = 'jellybeans'

	" fix tagbar status line
	autocmd VimEnter * AirlineRefresh

	" unicode symbols
	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif
	let g:airline_symbols.space = "\ua0"
	let g:airline_symbols.crypt = '🔒'
	" let g:airline_symbols.linenr = '␊'
	" let g:airline_symbols.linenr = '␤'
	let g:airline_symbols.linenr = '¶'
	let g:airline_symbols.maxlinenr = '☰'
	let g:airline_symbols.branch = '⎇'
	" let g:airline_symbols.paste = 'ρ'
	" let g:airline_symbols.paste = 'Þ'
	let g:airline_symbols.paste = '∥'
	let g:airline_symbols.spell = 'Ꞩ'
	let g:airline_symbols.notexists = '∄'
	let g:airline_symbols.whitespace = 'Ξ'
endif

" VCoolor
inoremap <kEnter> <Left><C-o>:VCoolor<CR>
nnoremap <kEnter> <Left>:VCoolor<CR>

" Gdiff
set diffopt+=vertical

" Ultisnips
let g:UltiSnipsExpandTrigger = "<Nul>"
let g:UltiSnipsJumpForwardTrigger = "<Nul>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"
if !exists('UltiSnipsSnippetDirectories')
	let g:UltiSnipsSnippetDirectories = ['UltiSnips', '~/.vim/UltiSnips']
endif

let g:ulti_expand_or_jump_res = 0

function! s:tryExpandSnippet()
	call UltiSnips#ExpandSnippetOrJump()
	return g:ulti_expand_or_jump_res
endfunction

function! s:buildArgsCompletionSnippet(args)
	let index = 0
	let stack = 0
	while index < len(a:args)
		let snipIndex = stack*2+index+1
		if strgetchar(a:args[index], 0) == char2nr(',')
			let arg = strpart(a:args[index], 2)
			let a:args[index] = '${'.(snipIndex).':, ${'.(snipIndex+1).':'.arg.'}'
			let stack += 1
		else
			let a:args[index] = '${'.(snipIndex).':'.a:args[index].'}'
			if index != 0
				let a:args[index] = ', '.a:args[index]
			endif
		endif
		let index += 1
	endwhile

	let snippet = join(a:args, '')
	if !empty(snippet)
		for i in range(stack)
			let snippet .= '}'
		endfor
		return snippet
	endif
endfunction

function! s:defaultArgsGenerator(completed)
	if(empty(a:completed.menu))
		return []
	endif
	let sepIdx = stridx(a:completed.menu, '|')
	return split(strpart(a:completed.menu, 0, sepIdx - 1), '\(\>, \| \[\(, \)\@=\|]\+\)')
endfunction

function! s:tabComplete()
	if <SID>tryExpandSnippet() == 0
		if exists('v:completed_item.menu') && !empty(keys(v:completed_item))
			let ArgsFunc = function(getbufvar(bufname('.'), 'completeArgsFunc', '<SID>defaultArgsGenerator'), [v:completed_item])
			let args = ArgsFunc()
			if len(args) == 0
				return "\<Tab>"
			endif
			let snippet = <SID>buildArgsCompletionSnippet(args)
			if v:completed_item.word !~ '('
				let snippet = '('.snippet
			endif
			let snippet .= ')$0'
			call UltiSnips#Anon(snippet)
		else
			return "\<Tab>"
		endif
	endif
	return ''
endfunction

inoremap <Tab> <C-r>=<SID>tabComplete()<CR>
xnoremap <Tab> :call UltiSnips#SaveLastVisualSelection()<CR>gvs
snoremap <Tab> <Esc>:call UltiSnips#ExpandSnippetOrJump()<CR>

" emmet
let g:user_emmet_leader_key = '<C-e>'
let g:user_emmet_settings = {
			\	'html': {
			\		'block_all_childless': 1,
			\	},
			\ }

" MatchTagAlways
let g:mta_use_matchparen_group = 0
let g:mta_set_default_matchtag_color = 0
let g:mta_filetypes = {
			\ 'html': 1,
			\ 'php': 1,
			\ 'xhtml': 1,
			\ 'xml': 1,
			\ 'fxml': 1 }

" FZF
let g:fzf_layout = {'window' : 'enew'}
let g:fzf_history_dir = '~/.vim/.fzf_hist'

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>,
			\ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'),
			\ <bang>0)

let g:fzf_rg_options = [
			\ '--hidden',
			\ '--column',
			\ '--line-number',
			\ '--no-heading',
			\ '--color=always',
			\ '--smart-case',
			\ '--colors "path:fg:yellow"',
			\ '--colors "path:style:bold"' ]

command! -nargs=* -bang Rg call fzf#vim#grep(
			\ 'rg '.join(fzf_rg_options).(<bang>0 ? ' --no-ignore ' : ' ').shellescape(<q-args>),
			\ 1,
			\ fzf#vim#with_preview(
			\		{'options': ['--color', $FZF_COLOR_SCHEME,
			\			'--prompt', 'Rg'.(empty(<q-args>) ? '' : ' (<args>)').'> ']},
			\		'right:50%:hidden', '?'))

let g:fzf_ignore = [
			\ '*.class',
			\ '*.jar',
			\ '.git',
			\ 'Session.vim',
			\ 'tags' ]

command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>,
			\ fzf#vim#with_preview({'source': "find -name ".join(g:fzf_ignore, ' -prune -o -name ')." -prune -o -type f -print"}),
			\ <bang>0)

nnoremap <silent> <C-p> :Buffers<CR>
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <leader>r :exe 'Rg '.expand('<cword>')<CR>

vnoremap <leader>r y:exe 'Rg '.@"<CR>

" Autoformat
let g:autoformat_remove_trailing_spaces = 0

" CSV
autocmd BufRead *.csv let b:delimiter = ','

" Gutentags
let g:gutentags_project_root = ['tags', 'src']

" AutoPairs
let g:AutoPairs = {'(':')',
			\ '[':']',
			\ '{':'}',
			\ "'":"'",
			\ '"':'"',
			\ '"""':'"""',
			\ "'''":"'''"}

let g:AutoPairsMultilineClose = 0

" DBUI
let g:db_ui_auto_execute_table_helpers = 1
let g:db_ui_use_nerd_fonts = 1

" Settings {{{1
set nocompatible
set number
set tabstop=4
set shiftwidth=4
set softtabstop=4
set mouse=a
set noswapfile
set incsearch
set noswapfile
set laststatus=2
set autowrite
set splitbelow
set splitright
set nostartofline
set hidden
set wildmenu
set wildmode=longest:full,full
set completeopt=longest,menuone
set autoindent
set nohlsearch
set omnifunc=syntaxcomplete#Complete
set whichwrap+=[,]
set backspace=indent,eol,start
set nofixendofline
set encoding=utf8
set display+=lastline
set breakindent
set breakindentopt+=shift:2
set wildignore+=tags,dbdata.vim,Session.vim,*.log
set virtualedit=block
set synmaxcol=0
set linebreak
set ignorecase
set smartcase
set ttymouse=sgr
set smarttab
set formatoptions+=j
set showcmd
set ttimeoutlen=50
set scrolloff=4
set sidescrolloff=5
set title
set lazyredraw
set cpoptions=AcFsBn
set noshowmode
set noexpandtab

set listchars=tab:→\ ,nbsp:•,eol:¬
set list

if &diff
	set diffopt+=iwhite
endif

let s:undo_dir = $HOME.'/.vim/undo'
if !isdirectory(s:undo_dir)
	call system('mkdir '.s:undo_dir)
endif
let &undodir = s:undo_dir
set undofile

syntax on
filetype plugin on
filetype indent on

runtime macros/matchit.vim

if g:quick_mode
	set signcolumn=no
else
	set relativenumber
endif

" Mappings {{{1
inoremap <A-Left> <C-o>:bp<CR>
inoremap <A-Right> <C-o>:bn<CR>
inoremap <A-Up> <C-o><C-e>
inoremap <A-Down> <C-o><C-y>
inoremap <S-Up> <ESC>:m-2<CR>==a
inoremap <S-Down> <ESC>:m+1<CR>==a
inoremap <A-o> <C-o>o
inoremap <A-S-o> <C-o>O
inoremap <A-S-i> <C-o>I
inoremap <A-S-a> <C-o>A
inoremap <S-Left> <C-d>
inoremap <S-Right> <C-t>
inoremap <C-d> <ESC>:w<CR>
inoremap <expr> <Up> (pumvisible() ? "\<C-y>\<Up>" : "\<Up>")
inoremap <expr> <Down> (pumvisible() ? "\<C-y>\<Down>" : "\<Down>")
inoremap <expr> <C-S-Down> (pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>")
inoremap <expr> <C-S-Up> (pumvisible() ? "\<C-y>\<C-e>" : "\<C-e>")
inoremap <expr> ` (pumvisible() ? "\<C-n>" : "`")
inoremap <expr> ~ (pumvisible() ? "\<C-p>" : "~")

nnoremap <A-Left> :bp<CR>
nnoremap <A-Right> :bn<CR>
nnoremap <A-Up> <C-e>
nnoremap <A-Down> <C-y>
nnoremap <S-Left> <<
nnoremap <S-Right> >>
nnoremap <silent> <S-Up> :m-2<CR>==
nnoremap <silent> <S-Down> :m+1<CR>==
nnoremap <C-d> :w<CR>
nnoremap <silent> <C-j> :if len(tagfiles()) > 0 \| exe "Tags" \| else \| exe "BTags" \| endif<CR>
nnoremap <silent> <leader>t :if len(tagfiles()) > 0 \| exe "Tags ".expand('<cword>') \| else \| exe "BTags ".expand('<cword>') \| endif<CR>
nnoremap Y y$
nnoremap <leader>E yy:@"<CR>
nnoremap <leader>a <C-^>
nnoremap <leader>o :YcmCompleter OrganizeImports<CR>
nnoremap <leader>c :cclose<CR>
nnoremap gp `[v`]
nnoremap <silent> <leader>h :set hlsearch!<CR>

nnoremap <C-Left> <C-w><Left>
nnoremap <C-Right> <C-w><Right>
nnoremap <C-Up> <C-w><Up>
nnoremap <C-Down> <C-w><Down>

nnoremap <silent> <leader>w :call search('\C[^a-z]', 'z', line('.'))<CR>
nnoremap <silent> <leader>b :call search('\C[^a-z]', 'b', line('.'))<CR>

nnoremap ]e :cnext<CR>
nnoremap [e :cprev<CR>
nnoremap <leader>e :crewind<CR>

nnoremap ]l :lnext<CR>
nnoremap [l :lprev<CR>
nnoremap <leader>l :lrewind<CR>

vnoremap <S-Left> <gv
vnoremap <S-Right> >gv
vnoremap <silent> <S-Down> :m'>+1<CR>gv=gv
vnoremap <silent> <S-Up> :m'<-2<CR>gv=gv
vnoremap <A-Up> <C-e>
vnoremap <A-Down> <C-y>
vnoremap <C-y> "+y
vnoremap <CR> y
vnoremap <leader>E y:@"<CR>

onoremap <silent> <leader>w /\C[^a-z]<CR>
onoremap <silent> <leader>b ?\C[^a-z]<CR>

if has('terminal')
	tnoremap <kHome> <Home>
	tnoremap <kEnd> <End>
	tnoremap <A-Left> <C-\><C-n>:bp<CR>
	tnoremap <A-Right> <C-\><C-n>:bn<CR>

	tnoremap <C-Left> <C-w><Left>
	tnoremap <C-Right> <C-w><Right>
	tnoremap <C-Up> <C-w><Up>
	tnoremap <C-Down> <C-w><Down>
endif

if &diff
	nnoremap <leader>d :windo normal! dd<CR>
endif

" Commands and functions {{{1
" prevent closing the window
command! -bar -bang Db if buflisted(@#) | b# | else | bp | endif
		\| try | bd<bang> # | catch | b# | echoerr v:exception | endtry
command! -bar -bang -nargs=? -complete=file Dw keepalt write<bang> <args> | Db<bang>

command! CpPath let @+ = fnamemodify(@%, ':h') | echo @+

function! s:openedInCurrentTab(bufname)
	let bufnr = bufnr(a:bufname)
	return index(tabpagebuflist(), bufnr) >= 0
endfunction

" Automatically restore view in the window
function! s:saveWinView()
	if !exists('w:win_views')
		let w:win_views = {}
	endif
	let w:win_views[bufnr('%')] = winsaveview()
endfunction

function! s:restoreWinView()
	if exists('w:win_views') && has_key(w:win_views, bufnr('%'))
				\ && line('.') == 1 && col('.') == 1
		call winrestview(w:win_views[bufnr('%')])
		unlet w:win_views[bufnr('%')]
	endif
endfunction

augroup winRestore
	autocmd!
	autocmd BufEnter * call <SID>restoreWinView()
	autocmd BufLeave * call <SID>saveWinView()
augroup END

if !exists('g:winModeMappigs')
	let g:winModeMappings = {
				\ "\<Left>": 'h',
				\ "\<Right>": 'l',
				\ "\<Up>": 'k',
				\ "\<Down>": 'j' }
endif

function! s:winMode()
	let current = win_getid()
	let cnt = ''
	let lastcmd = ''

	let cursor = &t_ve
	set t_ve=

	let cursor_bg_back = synIDattr(synIDtrans(hlID('CursorLine')), 'bg')
	if empty(cursor_bg_back)
		let cursor_bg_back = 'none'
	endif
	highlight CursorLine ctermfg=black ctermbg=green
	echohl ModeMsg

	while 1
		redraw
		echo '-- WIN --'
		let c = getchar()

		if 13 == c
			break
		elseif 27 == c
			call win_gotoid(current)
			break
		elseif 46 == c
			exe lastcmd
			continue
		elseif has_key(g:winModeMappings, c)
			let c = get(g:winModeMappings, c)
		else
			let c = nr2char(c)
		endif

		if c =~ '\d'
			let cnt .= c
			continue
		endif

		let lastcmd = cnt."wincmd ".c
		let cnt = ''
		exe lastcmd
	endwhile

	let &t_ve = cursor
	exe 'highlight CursorLine ctermfg=none ctermbg='.cursor_bg_back
	echohl Normal
	redraw
	echo
endfunction

nnoremap <silent> <C-w><C-w> :call <SID>winMode()<CR>

let g:highlight_current_word = 1

function! s:highlight_current_word()
	call <SID>remove_current_word_highlight()
	if g:highlight_current_word
		let w:current_word_match = matchadd('CurrentWord', printf('\V\<%s\>', escape(expand('<cword>'), '/\')), 100)
	endif
endfunction

function s:remove_current_word_highlight()
	if exists('w:current_word_match')
		call matchdelete(w:current_word_match)
		unlet w:current_word_match
	endif
endfunction

highlight CurrentWord cterm=underline
autocmd CursorHold,CursorHoldI * call <SID>highlight_current_word()
autocmd CursorMoved,CursorMovedI * call <SID>remove_current_word_highlight()

" Color scheme {{{1
set background=dark
highlight Constant cterm=none ctermfg=lightblue
highlight Operator ctermfg=red
highlight SpecialChar ctermfg=blue
highlight Type ctermfg=214
highlight Typedef cterm=bold
highlight Todo ctermfg=blue ctermbg=green
highlight SpecialKey ctermfg=237
highlight NonText ctermfg=239
highlight MatchParen cterm=bold,underline ctermfg=yellow ctermbg=none
highlight Comment cterm=italic ctermfg=darkgray
highlight LineNr cterm=italic ctermfg=240
highlight CursorLineNr cterm=bold,italic ctermfg=250 ctermbg=234
highlight StatusLine cterm=none ctermfg=121 ctermbg=233
highlight StatusLineNC cterm=none ctermfg=none ctermbg=233
highlight WildMenu cterm=inverse,bold ctermfg=121 ctermbg=233
highlight Folded ctermfg=121 ctermbg=234
highlight FoldColumn ctermfg=darkgray ctermbg=234
highlight SignColumn ctermbg=235
highlight VertSplit cterm=none ctermbg=233
highlight Visual ctermbg=black

highlight QuickFixLine cterm=bold ctermbg=233
highlight qfFileName ctermfg=green
highlight qfLineNr cterm=italic ctermfg=208

highlight TagbarHighlight cterm=underline,bold ctermfg=brown
highlight MatchTag cterm=underline,bold ctermbg=none ctermfg=none
highlight YcmWarningSign ctermfg=121 ctermbg=235

highlight Pmenu ctermfg=242 ctermbg=233
highlight PmenuSel ctermfg=121 ctermbg=234
highlight PmenuSbar ctermbg=233
highlight PmenuThumb ctermbg=yellow

highlight DiffAdd ctermbg=22
highlight DiffDelete ctermbg=235
highlight DiffChange ctermbg=17
highlight DiffText cterm=none ctermfg=white ctermbg=130

highlight SignifySignAdd ctermbg=235 ctermfg=green
highlight SignifySignDelete ctermbg=235 ctermfg=blue
highlight SignifySignChange ctermbg=235 ctermfg=lightgray

highlight phpMethodsVar cterm=italic
highlight DbgBreakptLine ctermbg=brown
highlight DbgBreakptSign ctermbg=brown
highlight MethodCall cterm=italic ctermfg=6

if &diff
	highlight CursorLine cterm=underline
else
	highlight CursorLine cterm=none ctermbg=234
endif

augroup colorscheme
	autocmd!

	autocmd Syntax * syntax match MethodCall /\(new \)\@<!\<[a-zA-Z_][a-zA-Z0-9_]\+\((\)\@=/ containedin=javaParenT,javaParenT1,javaParenT2

	" basic math operators
	autocmd Syntax *.java,*.cs,*.cpp syntax match Operator /\.\|=\|+\|>\|<\|?\|:\|-/ containedin=javaParenT,javaParenT1,javaParenT2,vimFuncBody
	" fix for comments
	autocmd Syntax *.java,*.cs,*.cpp syntax match Operator /\(\/\)\@<!\/\(\/\|\*\)\@!/ containedin=javaParenT,javaParenT1,javaParenT2,vimFuncBody
augroup END

if g:colors_supported
	set fillchars=vert:\  " space
endif

" Misc {{{1
augroup vimrc
	autocmd!

	autocmd VimResized * wincmd =

	autocmd FileType php compiler php
	autocmd FileType python let &makeprg = 'python -m py_compile'

	autocmd BufRead anacrontab setfiletype crontab
	autocmd BufRead .htaccess set commentstring=#\ %s
	autocmd FileType smarty set commentstring={*\ %s\ *}

	autocmd FileType help nnoremap <buffer> q :q<CR>

	autocmd FileType qf setlocal norelativenumber
	autocmd FileType qf setlocal scrolloff=0
augroup END

if &diff
	set cursorline
else
	augroup vimrc
		" cursorline only in current window
		autocmd WinEnter,BufWinEnter * setlocal cursorline
		autocmd WinLeave * setlocal nocursorline
	augroup END
endif

function! GetMakeCmd()
	return exists(':Make') ? 'Make' : 'make'
endfunc

if filereadable('build.gradle')
	autocmd BufEnter * compiler! gradle

	command! -bar -bang Build execute GetMakeCmd().' build --console plain'
	command! -bar Run execute GetMakeCmd().' run --console plain'
endif
" }}}

if filereadable('~/.vimrc.local')
	source ~/.vimrc.local
endif

if filereadable('.proj.vim')
	source .proj.vim
endif

" vim: fdm=marker
