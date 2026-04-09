" Auto-detect macOS light/dark mode; defaults to light on Linux.
" Colors come from the terminal palette (set in iTerm2) — no vim plugin needed.
if system('defaults read -g AppleInterfaceStyle 2>/dev/null') =~ 'Dark'
  set background=dark
else
  set background=light
endif

" Disable vi compatibility — unlocks all vim features (some distros still default to vi mode)
set nocompatible

" Yank/paste uses the system clipboard — no more :reg juggling to paste outside vim
set clipboard=unnamed

" Tab completion menu for commands — shows options instead of just cycling
set wildmenu

" Backspace should work intuitively in insert mode (across indents, line breaks, etc.)
set backspace=indent,eol,start

" Faster rendering for remote/slow terminals
set ttyfast

" Search/replace applies to all occurrences per line by default (not just the first)
set gdefault

" UTF-8 without BOM — BOM causes issues with many Unix tools
set encoding=utf-8 nobomb

" Comma as leader key — easier to reach than the default backslash
let mapleader=","

" Keep swap/backup/undo files out of project directories — prevents .swp litter
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Don't pollute /tmp with backup files
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline instructions embedded in files (e.g., `vim: set ts=4:`)
set modeline
set modelines=4

" Allow per-directory .vimrc for project-specific settings, but block dangerous commands
set exrc
set secure

" Line numbers make it easy to reference lines in error messages and discussions
set number

syntax on

" Highlight current line — visual anchor so you don't lose the cursor
set cursorline

" 2-space tabs match our .editorconfig default
set tabstop=2

" Make invisible whitespace visible — catches trailing spaces and mixed indentation
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" Highlight all search matches and show matches as you type — instant visual feedback
set hlsearch
set ignorecase
set incsearch

" Always show the status bar — displays filename, mode, cursor position
set laststatus=2

" Mouse works in all modes — click to position, scroll, drag-select
set mouse=a

" No audible bell — flashing screen (visual bell) or nothing is less jarring
set noerrorbells

" Don't jump cursor to column 0 when moving between lines
set nostartofline

" Show cursor position in status bar
set ruler

" Skip the vim splash screen
set shortmess=atI

" Show current mode (INSERT, VISUAL, etc.) and partial commands as you type them
set showmode
set showcmd

" Show filename in terminal title bar — useful with multiple terminal tabs
set title

" Relative line numbers — shows distance from cursor for jump commands like `5j` or `12k`
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif

" Start scrolling 3 lines before the edge — gives context while scrolling
set scrolloff=3

" Strip trailing whitespace with ,ss — useful before committing
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>

" Save as root with ,W — for when you open a system file and forgot sudo
noremap <leader>W :w !sudo tee % > /dev/null<CR>

if has("autocmd")
	filetype on
	" Proper syntax highlighting for these file types
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif
