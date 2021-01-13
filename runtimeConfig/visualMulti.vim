" Visual-multi {
" Theme
let g:VM_theme = 'nord'
" Settings
let g:VM_maps = {}
let g:VM_leader = '\'
let g:VM_default_mappings = 0
let g:VM_mouse_mappings = 1
" (experimental)
" let g:VM_maps["Undo"] = 'u'
" let g:VM_maps["Redo"] = '<C-r>'

" Add new mapping while preserving the orginal mapping at the same time
" let g:VM_custom_remaps = {'<c-p>': 'N', '<c-s>': 'q'}

" To remap any key to normal! commands. Example:
" let g:VM_custom_noremaps = {'==': '==', '<<': '<<', '>>': '>>'}

let g:VM_maps['Add Cursors Down']      = '<C-A-j>'
let g:VM_maps['Add Cursors Up']      = '<C-A-k>'
let g:VM_maps['Find Under']      = '<C-d>'
let g:VM_maps['Visual Add']      = '<C-d>'
let g:VM_maps['Skip Region']     = '<C-k>'
" let g:VM_maps['Visual Subtract'] = 'u'
" let g:VM_maps['Visual Reduce']   = 'U'
let g:VM_maps['Select All']      = '<A-m>'
let g:VM_maps['Visual All']      = '<A-m>'
let g:VM_maps['Enlarge']        = '<A-a>'
let g:VM_maps['Shrink']        = '<A-S-a>'
" Mouse
let g:VM_maps['Mouse Cursor'] = '<C-LeftMouse>'
let g:VM_maps['Mouse Word'] = '<C-RightMouse>'
" Navigaton
let g:VM_maps['Invert Direction'] = 'o'
let g:VM_maps['Find Next'] = 'n'
let g:VM_maps['Find Prev'] = 'N'
let g:VM_maps['Goto Next'] = ']' " Without adding new occurrences
let g:VM_maps['Goto Prev'] = '[' " Without adding new occurrences
" Replace
let g:VM_maps['Replace'] = 'R'
let g:VM_maps['Replace'] = 's'
let g:VM_maps['Replace'] = 'C'
let g:VM_maps['Replace'] = 'c'
let g:VM_maps['Toggle Multiline'] = 'M'
let g:VM_maps['Increase'] = '<C-a>'
let g:VM_maps['Replace'] = '<C-x>'
" } Visual-multi
