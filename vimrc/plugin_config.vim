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

