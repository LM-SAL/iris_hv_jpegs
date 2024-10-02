;
; Calculate a new solar centre given the application of the IDL
; command ROT.  ROT rotates clockwise, and so the centre of the Sun as
; observed in the data must also be rotated clockwise.  This function
; implements that.
;
function HV_CALC_ROT_CENTRE, originalSolarCentre, angle, rotCentre
  compile_opt idl2

  sunCentreVector = originalSolarCentre - rotCentre

  sunCentreVectorRot = [cos(angle) * sunCentreVector[0] + sin(angle) * sunCentreVector[1], $
    - sin(angle) * sunCentreVector[0] + cos(angle) * sunCentreVector[1]]

  rotatedSolarCentre = rotCentre + sunCentreVectorRot

  return, rotatedSolarCentre
end