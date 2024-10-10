;
; Get a list of the current contents of the incoming directory
;
function HV_GET_INCOMING, incoming
  compile_opt idl2

  return, find_file(incoming)
end