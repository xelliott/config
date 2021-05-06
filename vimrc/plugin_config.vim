"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !empty(glob(g:plugin_path . '/vim-airline/autoload/airline.vim'))
  " Hide default mode indicator
  set noshowmode

  " Do not show max line number symbol
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  let g:airline_symbols.maxlinenr = ''
endif

let g:ale_fortran_language_server_use_global = 1
" let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'fortran': ['language_server'],
\}

nmap gd :ALEGoToDefinition -tab<CR>
nmap gr :ALEFindReferences<CR>

nnoremap <silent> K :ALEHover<CR>

nnoremap <C-p> :<C-u>FZF<CR>
nnoremap <Leader>pf :Files %:p:h<CR>

