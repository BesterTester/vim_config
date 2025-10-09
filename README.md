# Vim Configuration

My personal Vim configuration files for managing settings across multiple systems.

## Structure

- Environment-specific configurations
- Shared functions and mappings
- Database integration tools
- Programming helpers

## Usage

Source the appropriate configuration files from your system-specific `.vimrc`.


## Example .vimrc file
" =========================
" WINDOWS SPECIFIC SETTINGS
" =========================

set colorscheme
let g:color_scheme = 'slate'

let g:vim_rc_file = '~/awagner1/_vimrc'

source C:/Users/Andy.Wagner3/repositories/vim_config/.vimrc
source C:/Users/Andy.Wagner3/repositories/vim_config/.vim_functions
source C:/Users/Andy.Wagner3/repositories/vim_config/.vim_programming

