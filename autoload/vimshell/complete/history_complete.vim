"=============================================================================
" FILE: history_complete.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 Dec 2009
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

function! vimshell#complete#history_complete#whole()"{{{
    let &iminsert = 0
    let &imsearch = 0

    " Command completion.

    " Set complete function.
    let &l:omnifunc = 'vimshell#complete#history_complete#omnifunc_whole'

    if exists(':NeoComplCacheDisable') && exists('*neocomplcache#manual_omni_complete')
        return neocomplcache#manual_omni_complete()
    else
        return "\<C-x>\<C-o>\<C-p>"
    endif
endfunction"}}}
function! vimshell#complete#history_complete#insert()"{{{
    let &iminsert = 0
    let &imsearch = 0

    " Command completion.

    " Set complete function.
    let &l:omnifunc = 'vimshell#complete#history_complete#omnifunc_insert'

    if exists(':NeoComplCacheDisable') && exists('*neocomplcache#manual_omni_complete')
        return neocomplcache#manual_omni_complete()
    else
        return "\<C-x>\<C-o>\<C-p>"
    endif
endfunction"}}}

function! vimshell#complete#history_complete#omnifunc_whole(findstart, base)"{{{
    if a:findstart
        if !vimshell#check_prompt()
            " Not found prompt.
            return -1
        endif

        return len(vimshell#get_prompt())
    endif

    " Save options.
    let l:ignorecase_save = &ignorecase

    " Complete.
    if g:VimShell_SmartCase && a:base =~ '\u'
        let &ignorecase = 0
    else
        let &ignorecase = g:VimShell_IgnoreCase
    endif

    " Collect words.
    let l:complete_words = g:vimshell#hist_buffer
    for l:str in split(a:base)
        let l:words = []
        for hist in l:complete_words
            if hist =~ l:str
                call add(l:words, hist)
            endif
        endfor

        let l:complete_words = l:words
    endfor
    
    let l:words = l:complete_words
    let l:complete_words = []
    for word in l:words
        call add(l:complete_words, { 'word' : word, 'menu' : 'history' })
    endfor

    " Restore options.
    let &ignorecase = l:ignorecase_save
    let &l:omnifunc = ''

    return l:complete_words
endfunction"}}}
function! vimshell#complete#history_complete#omnifunc_insert(findstart, base)"{{{
    if a:findstart
        " Get cursor word.
        return match(vimshell#get_cur_text(), '\%([[:alnum:]_+~-]\|\\[ ]\)*$')
    endif

    " Save options.
    let l:ignorecase_save = &ignorecase

    " Complete.
    if g:VimShell_SmartCase && a:base =~ '\u'
        let &ignorecase = 0
    else
        let &ignorecase = g:VimShell_IgnoreCase
    endif
    let l:complete_words = []
    for hist in g:vimshell#hist_buffer
        if len(hist) > len(a:base) && hist =~ a:base
            call add(l:complete_words, { 'word' : hist, 'menu' : 'history' })
        endif
    endfor

    " Restore options.
    let &ignorecase = l:ignorecase_save
    let &l:omnifunc = ''

    return l:complete_words
endfunction"}}}

" vim: foldmethod=marker
