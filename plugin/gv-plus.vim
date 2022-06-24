if exists("g:loaded_gv_plus")
  finish
endif
let g:loaded_gv_plus = 1

augroup VisualAccounts
  autocmd!
  if exists('##ModeChanged')
    autocmd ModeChanged [vV\x16]:n lua require'gv-plus'.store_visual_selection()
    nnoremap <unique> <silent> <script> gv :<C-U>lua require'gv-plus'.get_visual_selection(vim.v.count)<CR>
  else
    echom('Your neovim version does not support the ModeChanged event')
  endif
augroup end
