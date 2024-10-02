;
; 18 Dec 2009
;
; Return a string array from a text file
;
function HV_HVS_READ, filename
  compile_opt idl2
  list = readlist(filename)
  return, list
end