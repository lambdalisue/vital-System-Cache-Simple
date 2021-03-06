"******************************************************************************
" A simple cache system which store cached values in instances
"
" Author:   Alisue <lambdalisue@cache_keynote.net>
" URL:      http://cache_keynote.net/
" License:  MIT license
" (C) 2014, Alisue, cache_keynote.net
"******************************************************************************
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) dict abort " {{{
  let s:V = a:V
  let s:Prelude = a:V.import('Prelude')
  let s:String = a:V.import('Data.String')
endfunction " }}}
function! s:_vital_depends() abort " {{{
  return [
        \ 'Prelude',
        \ 'Data.String',
        \]
endfunction " }}}

function! s:hash(obj) " {{{
  let str = s:Prelude.is_string(a:obj) ? a:obj : string(a:obj)
  if strlen(str) < 150
    " hash might be a filename thus.
    let hash = str
    let hash = substitute(hash, ':', '=-', 'g')
    let hash = substitute(hash, '[/\\]', '=+', 'g')
  else
    let hash = s:String.hash(str)
  endif
  return hash
endfunction " }}}

let s:cache = {
      \ '_cached': {},
      \}
function! s:new() " {{{
  " Return a memory cache instance
  return extend(deepcopy(s:cache), {
        \ 'base': deepcopy(s:cache),
        \})
endfunction " }}}
function! s:cache.cache_key(obj) dict " {{{
  " Return a cache_key of 'obj'.
  return s:hash(a:obj)
endfunction " }}}
function! s:cache.has(name) dict " {{{
  " Return if the instance has a cache of 'name'
  " Args:
  "   - name: a name of a cache
  let cache_key = self.cache_key(a:name)
  return has_key(self._cached, cache_key)
endfunction " }}}
function! s:cache.get(name, ...) dict " {{{
  " Return a cached value of 'name' or default
  " Args:
  "   - name: a name of a cache
  "   - default: a default value (optional)
  let default = get(a:000, 0, '')
  let cache_key = self.cache_key(a:name)
  if has_key(self._cached, cache_key)
    return self._cached[cache_key]
  else
    return default
  endif
endfunction " }}}
function! s:cache.set(name, value) dict " {{{
  " Save 'value' into cache dictionary with 'name'
  " Args:
  "   - name: a name of a cache
  "   - value: a value which will be cached
  let cache_key = self.cache_key(a:name)
  let self._cached[cache_key] = a:value
endfunction " }}}
function! s:cache.remove(name) dict " {{{
  " Remove a cache of 'name'. It won't raise exceptions even if no cache of
  " 'name' exists
  " Args:
  "   - name: a name of a cache
  let cache_key = self.cache_key(a:name)
  if has_key(self._cached, cache_key)
    unlet self._cached[cache_key]
  endif
endfunction " }}}
function! s:cache.keys() dict " {{{
  return keys(self._cached)
endfunction " }}}
function! s:cache.clear() dict " {{{
  " Clear all cache saved in this instance
  let self._cached = {}
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
"vim: sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
