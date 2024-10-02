;
; 14 May 2010
;
; return true/false to see if we are using a quicklook processing stream
;
function HV_USING_QUICKLOOK_PROCESSING, called_by
  compile_opt idl2
  a1 = strpos(strupcase(called_by), 'QL')
  a2 = strpos(strupcase(called_by), 'QUICKLOOK')

  tf = 0
  if ((a1[0] ge 0) or (a2[0] ge 0)) then begin
    tf = 1
  endif

  return, tf
end