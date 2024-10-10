;+
; NAME:
;       ASINHSCL
;
; PURPOSE:
;
;       This is a utility routine to perform an inverse hyperbolic sine
;       function intensity transformation on an image. I think of this
;       as a sort of "tuned" gamma or power-law function. The algorithm,
;       and notion of "asinh magnitudes", comes from a paper by Lupton,
;       et. al, in The Astronomical Journal, 118:1406-1410, 1999 September.
;       I've relied on the implementation of Erin Sheldon, found here:
;
;           http://cheops1.uchicago.edu/idlhelp/sdssidl/plotting/tvasinh.html
;
;       I'm also grateful of discussions with Marshall Perrin on the IDL
;       newsgroup with respect to the meaning of the "softening parameter", beta,
;       and for finding (and fixing!) small problems with the code.
;
;       Essentially this transformation allow linear scaling of noise values,
;       and logarithmic scaling of signal values, since there is a small
;       linear portion of the curve and a much large logarithmic portion of
;       the curve. (See the EXAMPLE section for some tips on how to view this
;       transformation curve.)
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: david@idlcoyote.com
;       Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       outputImage = ASINHSCL(image)
;
; ARGUMENTS:
;
;       image:         The image or signal to be scaled. Written for 2D images, but arrays
;                      of any size are treated alike.
;
; KEYWORDS:
;
;       BETA:          This keyword corresponds to the "softening parameter" in the Lupon et. al paper.
;                      This factor determines the input level at which linear behavior sets in. Beta
;                      should be set approximately equal to the amount of "noise" in the input signal.
;                      IF BETA=0 there is a very small linear portion of the curve; if BETA=200 the
;                      curve is essentially all linear. The default value of BETA is set to 3, which
;                      is appropriate for a small amount of noise in your signal. The value is always
;                      positive.
;
;       NEGATIVE:      If set, the "negative" of the result is returned.
;
;       MAX:           Any value in the input image greater than this value is
;                      set to this value before scaling.
;
;       MIN:           Any value in the input image less than this value is
;                      set to this value before scaling.
;
;       OMAX:          The output image is scaled between OMIN and OMAX. The
;                      default value is 255.
;
;       OMIN:          The output image is scaled between OMIN and OMAX. The
;                      default value is 0.
; RETURN VALUE:
;
;       outputImage:   The output, scaled into the range OMIN to OMAX. A byte array.
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLES:
;
;       Plot,  ASinhScl(Indgen(256), Beta=0.0), LineStyle=0
;       OPlot, ASinhScl(Indgen(256), Beta=0.1), LineStyle=1
;       OPlot, ASinhScl(Indgen(256), Beta=1.0), LineStyle=2
;       OPlot, ASinhScl(Indgen(256), Beta=10.), LineStyle=3
;       OPlot, ASinhScl(Indgen(256), Beta=100), LineStyle=4
;
; RESTRICTIONS:
;
;     Requires SCALE_VECTOR from the Coyote Library:
;
;        http://www.idlcoyote.com/programs/scale_vector.pro
;
;     Incorporates ASINH from the NASA Astronomy Library and renamed ASINHSCL_ASINH.
;
;       http://idlastro.gsfc.nasa.gov/homepage.html
;
; MODIFICATION HISTORY:
;
;       Written by:  David W. Fanning, 24 February 2006.
;       Removed ALPHA keyword and redefined the BETA keyword to correspond
;         to the "softening parameter" of Lupton et. al., following the
;         suggestions of Marshall Perrin. 25 April 2006. DWF.
;-
; ******************************************************************************************;
; Copyright (c) 2008, by Fanning Software Consulting, Inc.                                ;
; All rights reserved.                                                                    ;
; ;
; Redistribution and use in source and binary forms, with or without                      ;
; modification, are permitted provided that the following conditions are met:             ;
; ;
; * Redistributions of source code must retain the above copyright                    ;
; notice, this list of conditions and the following disclaimer.                     ;
; * Redistributions in binary form must reproduce the above copyright                 ;
; notice, this list of conditions and the following disclaimer in the               ;
; documentation and/or other materials provided with the distribution.              ;
; * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
; contributors may be used to endorse or promote products derived from this         ;
; software without specific prior written permission.                               ;
; ;
; THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
; SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
; ******************************************************************************************;
function ASinhScl_ASinh, x
  compile_opt idl2
  ;
  ; NAME:
  ; ASINH
  ; PURPOSE:
  ; Return the inverse hyperbolic sine of the argument
  ; EXPLANATION:
  ; The inverse hyperbolic sine is used for the calculation of asinh
  ; magnitudes, see Lupton et al. (1999, AJ, 118, 1406)
  ;
  ; CALLING SEQUENCE
  ; result = asinh( x)
  ; INPUTS:
  ; X - hyperbolic sine, numeric scalar or vector or multidimensional array
  ; (not complex)
  ;
  ; OUTPUT:
  ; result - inverse hyperbolic sine, same number of elements as X
  ; double precision if X is double, otherwise floating pt.
  ;
  ; METHOD:
  ; Expression given in  Numerical Recipes, Press et al. (1992), eq. 5.6.7
  ; Note that asinh(-x) = -asinh(x) and that asinh(0) = 0. and that
  ; if y = asinh(x) then x = sinh(y).
  ;
  ; REVISION HISTORY:
  ; Written W. Landsman                 February, 2001
  ; Work for multi-dimensional arrays  W. Landsman    August 2002
  ; Simplify coding, and work for scalars again  W. Landsman October 2003
  ;
  on_error, 2

  y = alog(abs(x) + sqrt(x ^ 2 + 1.0))

  index = where(x lt 0, count)
  if count gt 0 then y[index] = -y[index]

  RETURN, y
end

; -------------------------------------------------------------------------------

function ASinhScl, image, $
  beta = beta, $
  negative = negative, $
  max = maxValue, $
  min = minValue, $
  omax = maxOut, $
  omin = minOut
  compile_opt idl2

  ; Return to caller on error.
  on_error, 2

  ; Check arguments.
  if n_elements(image) eq 0 then message, 'Must pass IMAGE argument.'

  ; Check for underflow of values near 0. Yuck!
  curExcept = !except
  !except = 0
  i = where(image gt -1e-35 and image lt 1e-35, count)
  if count gt 0 then image[i] = 0.0
  void = check_math()
  !except = curExcept

  ; Work in double precision.
  output = double(image)

  ; Too damn many floating underflow warnings, no matter WHAT I do! :-(
  thisExcept = !except
  !except = 0

  ; Perform initial scaling of the image into 0 to 1.0.
  output = Scale_Vector(temporary(output), 0.0, 1.0, maxvalue = maxValue, $
    minvalue = minValue, /nan, double = 1)

  ; Check keywords.
  if n_elements(beta) eq 0 then beta = 3.0d
  if n_elements(maxOut) eq 0 then maxOut = 255b else maxOut = 0 > byte(maxOut) < 255
  if n_elements(minOut) eq 0 then minOut = 0b else minOut = 0 > byte(minOut) < 255
  if minOut ge maxOut then message, 'OMIN must be less than OMAX.'

  ; Create a non-linear factor from the BETA value.
  scaled_beta = ((beta > 0) - minValue) / (maxValue - minValue)
  nonlinearity = 1.0d / (scaled_beta > 1e-12)

  ; Find out where 0 and 1 map in ASINH, then set these as MINVALUE and MAXVALUE
  ; in next SCALE_VECTOR call. This is necessary to preserve proper scaling.
  extrema = ASinhScl_ASinh([0, 1.0d] * nonlinearity)

  ; Inverse hyperbolic sine scaling.
  output = Scale_Vector(ASinhScl_ASinh(temporary(output) * nonlinearity), $
    minOut, maxOut, /nan, double = 1, minvalue = extrema[0], maxvalue = extrema[1])

  ; Clear math errors.
  void = check_math()
  !except = thisExcept

  ; Does the user want the negative result?
  if keyword_set(negative) then RETURN, byte(maxOut - round(output) + minOut) $
  else RETURN, byte(round(output))
end

; -------------------------------------------------------------------------------