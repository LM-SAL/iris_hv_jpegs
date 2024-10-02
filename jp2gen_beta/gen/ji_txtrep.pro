function ji_txtrep, a, b, c
  compile_opt idl2
  d = a
  repeat begin
    here = strpos(d, b)
    if (here ne -1) then begin
      strput, d, c, here
    endif
  endrep until (here eq -1)
  RETURN, d
end