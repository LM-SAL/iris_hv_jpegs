;
; hv_find_embed.pro
;
;
function HV_FIND_EMBED, apph, scale, nx, ny, rescaleby = rescaleby
  compile_opt idl2
  ;
  ; get the number of scales available
  ;
  sc = n_elements(apph)
  ;
  ; find the first scale in the hierarchy less than the scale of the
  ; image
  ;
  repeat begin
    sc = sc - 1
  endrep until (apph[sc] le scale)
  ;
  ; Rescale factors found by looking at the limits the passed scale lies
  ; between.  A decision must be taken to rescale by either f1 or f2
  ;
  f1 = scale / apph[sc]
  f2 = scale / apph[sc + 1]
  ;
  ; Fractional change in number of pixels along the x or y axis on
  ; re-scaling by either f1 or f2.
  ;
  c1 = abs(1.0 - f1)
  c2 = abs(1.0 - f2)
  ;
  ; Since the rescale factors are logarithmically spaced, we must first
  ; take the log
  ;
  z1 = alog(apph[sc])
  zscale = alog(scale)
  z2 = alog(apph[sc + 1])
  ;
  ; Find the distance between zscale and the two candidate new scales
  ;
  cc1 = abs(zscale - z1)
  cc2 = abs(zscale - z2)
  ;
  ; Pick which distance measurement to use
  ;
  if not (keyword_set(rescaleby)) then begin
    d1 = c1
    d2 = c2
  endif else begin
    if (strupcase(rescaleby) eq 'SIZE') then begin
      d1 = c1
      d2 = c2
    endif
    if (strupcase(rescaleby) eq 'LOG') then begin
      d1 = cc1
      d2 = cc2
    endif
  endelse
  ;
  ; Choose which distance is the least, and set the rescale factors to
  ; be the closest as measured by c1 and c2
  ;
  if (d1 lt d2) then begin
    frescale = f1
    ; if ( (nint(frescale*nx) mod 2) eq 1) then begin
    ; hv_xlen = nint(frescale*nx) -1
    ; hv_ylen = nint(frescale*ny) -1
    ; frescale = float(hv_xlen)/float(nx)
    ; endif
    nx_embed = 2 * nx
    ny_embed = 2 * ny
  endif else begin
    frescale = f2
    ; if ( (nint(frescale*nx)mod 2) eq 1) then begin
    ; hv_xlen = nint(frescale*nx) -1
    ; hv_ylen = nint(frescale*ny) -1
    ; frescale = float(hv_xlen)/float(nx)
    ; endif
    nx_embed = 2 * nx
    ny_embed = 2 * ny
    sc = sc + 1
  endelse
  ;
  ; re-scaling factor
  ;
  ; frescale = scale/apph(sc)
  ;
  ; return all the properties we need
  ;
  return, {frescale: frescale, $
    sc: sc, $
    hv_xlen: nint(frescale * nx), $
    hv_ylen: nint(frescale * ny), $
    nx_embed: nx_embed, $
    ny_embed: ny_embed}
end