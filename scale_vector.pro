; docformat = 'rst'
;
; NAME:
; Scale_Vector
;
; PURPOSE:
; This is a utility routine to scale the elements of a vector or an array into a
; given data range.
;
; ******************************************************************************************;
; ;
; Copyright (c) 1998-2013, by Fanning Software Consulting, Inc. All rights reserved.      ;
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
;
;+
; This is a utility routine to scale the elements of a vector or an array into a
; given data range.
;
; :Categories:
;    Utilities
;
; :Returns:
;     A vector or array of the same size as the input, scaled into the data range given
;     by `minRange` and `maxRange'. The input vector is confined to the data range set
;     by `MinValue` and `MaxValue` before scaling occurs.
;
; :Params:
;    maxRange: in, optional, type=varies, default=1
;       The maximum output value of the scaled vector. Set to 1 by default.
;    minRange: in, optional, type=varies, default=0
;       The minimum output value of the scaled vector. Set to 0 by default.
;    vector: in, required
;       The input vector or array to be scaled.
;
; :Keywords:
;    double: in, optional, type=boolean, default=0
;         Set this keyword to perform scaling in double precision. Otherwise, scaling
;         is done in floating point precision.
;     maxvalue: in, optional
;         Set this value to the maximum value of the vector, before scaling (vector < maxvalue).
;         The default value is Max(vector).
;     minvalue: in, optional
;         Set this value to the mimimum value of the vector, before scaling (minvalue < vector).
;         The default value is Min(vector).
;     nan: in, optional, type=boolean, default=0
;         Set this keyword to enable not-a-number checking. NANs in vector will be ignored.
;     preserve_type: in, optional, type=boolean, default=0
;         Set this keyword to preserve the input data type in the output.
;
; :Examples:
;       Simple example of scaling a vector::
;
;          IDL> x = [3, 5, 0, 10]
;          IDL> xscaled = Scale_Vector(x, -50, 50)
;          IDL> Print, xscaled
;               -20.0000     0.000000     -50.0000      50.0000

;       Suppose your image has a minimum value of -1.7 and a maximum value = 2.5.
;       You wish to scale this data into the range 0 to 255, but you want to use
;       a diverging color table. Thus, you want to make sure value 0.0 is scaled to 128.
;       You proceed like this::
;
;          scaledImage = Scale_Vector(image, 0, 255, MINVALUE=-2.5, MAXVALUE=2.5)
;
; :Author:
;    FANNING SOFTWARE CONSULTING::
;       David W. Fanning
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: david@idlcoyote.com
;       Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; :History:
;     Change History::
;         Written by:  David W. Fanning, 12 Dec 1998.
;         Added MAXVALUE and MINVALUE keywords. 5 Dec 1999. DWF.
;         Added NAN keyword. 18 Sept 2000. DWF.
;         Removed check that made minRange less than maxRange to allow ranges to be
;            reversed on axes, etc. 28 Dec 2003. DWF.
;         Added PRESERVE_TYPE and DOUBLE keywords. 19 February 2006. DWF.
;         Added FPUFIX to cut down on floating underflow errors. 11 March 2006. DWF.
;
; :Copyright:
;     Copyright (c) 1998-2013, Fanning Software Consulting, Inc.
;-
function Scale_Vector, vector, minRange, maxRange, $
  DOUBLE = double, $
  maxvalue = vectorMax, $
  minvalue = vectorMin, $
  nan = nan, $
  preserve_type = preserve_type
  compile_opt idl2

  ; Error handling.
  catch, theError
  if theError ne 0 then begin
    catch, /cancel
    void = ERROR_MESSAGE()
    RETURN, vector
  endif

  ; Check positional parameters.
  case n_params() of
    0: message, 'Incorrect number of arguments.'
    1: begin
      if keyword_set(double) then begin
        minRange = 0.0d
        maxRange = 1.0d
      endif else begin
        minRange = 0.0
        maxRange = 1.0
      endelse
    endcase
    2: begin
      if keyword_set(double) then maxRange = 1.0d > (minRange + 0.0001d) else $
        maxRange = 1.0 > (minRange + 0.0001)
    endcase
    else:
  endcase

  ; If input data type is DOUBLE and DOUBLE keyword is not set, then set it.
  if size(FPUFIX(vector), /tname) eq 'DOUBLE' and n_elements(double) eq 0 then double = 1

  ; Make sure we are working with at least floating point numbers.
  if keyword_set(DOUBLE) then minRange = double(minRange) else minRange = float(minRange)
  if keyword_set(DOUBLE) then maxRange = double(maxRange) else maxRange = float(maxRange)

  ; Make sure we have a valid range.
  if maxRange eq minRange then message, 'Range max and min are coincidental'

  ; Check keyword parameters.
  if keyword_set(DOUBLE) then begin
    if n_elements(vectorMin) eq 0 then vectorMin = double(min(FPUFIX(vector), nan = 1)) $
    else vectorMin = double(vectorMin)
    if n_elements(vectorMax) eq 0 then vectorMax = double(max(FPUFIX(vector), nan = 1)) $
    else vectorMax = double(vectorMax)
  endif else begin
    if n_elements(vectorMin) eq 0 then vectorMin = float(min(FPUFIX(vector), nan = 1)) $
    else vectorMin = float(vectorMin)
    if n_elements(vectorMax) eq 0 then vectorMax = float(max(FPUFIX(vector), nan = keyword_set(nan))) $
    else vectorMax = float(vectorMax)
  endelse

  ; Trim vector before scaling.
  index = where(finite(vector) eq 1, count)
  if count ne 0 then begin
    if keyword_set(DOUBLE) then trimVector = double(vector) else trimVector = float(vector)
    trimVector[index] = vectorMin > vector[index] < vectorMax
  endif else begin
    if keyword_set(DOUBLE) then trimVector = vectorMin > double(vector) < vectorMax else $
      trimVector = vectorMin > float(vector) < vectorMax
  endelse

  ; Calculate the scaling factors.
  scaleFactor = [((minRange * vectorMax) - (maxRange * vectorMin)) / $
    (vectorMax - vectorMin), (maxRange - minRange) / (vectorMax - vectorMin)]

  ; Clear math errors.
  void = check_math()

  ; Return the scaled vector.
  if keyword_set(preserve_type) then begin
    RETURN, FPUFIX(Convert_To_Type(trimVector * scaleFactor[1] + scaleFactor[0], size(vector, /tname)))
  endif else begin
    RETURN, FPUFIX(trimVector * scaleFactor[1] + scaleFactor[0])
  endelse
end