;
; returns a nice version of the time just now, in string form
;
function ji_systime, dummy
  compile_opt idl2
  return, ji_txtrep(ji_txtrep(string(systime()), ' ', '_'), ':', '.')
end