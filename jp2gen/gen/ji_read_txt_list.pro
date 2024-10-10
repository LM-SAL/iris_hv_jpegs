;
;
; ji_read_txt_list
; read a list strings in a text file and return the
; list as a string array
;
;
function ji_read_txt_list, source_list
  compile_opt idl2

  close, /all
  dummy = ''
  n = 0
  openr, 1, source_list
  while not (eof(1)) do begin
    readf, 1, dummy
    n = n + 1
  endwhile
  close, 1

  if (n ne 0) then begin
    list = strarr(n)
    n = 0
    openr, 1, source_list
    while not (eof(1)) do begin
      readf, 1, dummy
      list[n] = dummy
      n = n + 1
    endwhile
    close, 1
  endif else begin
    list = ['<zerolengthlist>']
  endelse

  RETURN, list
end