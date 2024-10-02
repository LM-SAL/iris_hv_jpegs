;
; 5 May 2010
;
; Parse a filename
;
function HV_PARSE_LOCATION, a, $
  transfer_path = transfer_path, $
  location = location, $
  all_subdir = all_subdir
  compile_opt idl2
  ;
  progname = 'HV_PARSE_LOCATION'
  ;
  z = strsplit(EXPAND_TILDE(a), path_sep(), /extract)
  nz = n_elements(z)
  ;
  ; To transfer a file you need information from the nickname down.
  ;
  if keyword_set(transfer_path) then begin
    tp = ''
    if (nz lt 5) then begin
      print, progname + ': not enough information to create a transfer path. Stopping.'
      stop
    endif else begin
      for i = nz - 1, nz - 6, -1 do begin
        if (i eq (nz - 1)) then begin
          eee = ''
        endif else begin
          eee = path_sep()
        endelse
        tp = z[i] + eee + tp
      endfor
    endelse
    answer = tp
  endif
  ;
  ; Get the location above the device nickname
  ;
  if keyword_set(location) then begin
    tp = ''
    zz = reverse(z)
    for i = 6, nz - 1 do begin
      tp = zz[i] + path_sep() + tp
    endfor
    answer = path_sep() + tp
  endif
  ;
  ; Return
  ;
  if keyword_set(all_subdir) then begin
    z = strsplit(answer, path_sep(), /extract)
    nz = n_elements(z)
    ddd = strarr(nz)
    ddd[0] = z[0] + path_sep()
    for i = 1, nz - 1 do begin
      if i eq (nz - 1) then begin
        eee = ''
      endif else begin
        eee = path_sep()
      endelse
      ddd[i] = ddd[i - 1] + z[i] + eee
    endfor
    answer = ddd
  endif

  return, answer
end