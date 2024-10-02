;
; Function which defines the IRIS JP2K encoding parameters for each type
; of measurement
;
; Minimum required Helioviewer Setup (HVS) structure tags.
;
; Let us assume there is a device commonly known by its "nickname",
; but is actually a "detector" which is part of an "instrument" on a
; space or ground based "observatory".  There are "N" different
; measurements possible from the device.  The tags below are the
; minimum required.
;
; a = { observatory: 'AAA',$
; instrument:  'BBB',$
; detector:    'CCC',$
; nickname:    'DDD',$
; hvs_details_filename: 'XXX',$
; hvs_details_filename_version: 'Y.Z',$
; details(N) }
;
; For each of the N measurements, there is a details structure.
; The details structure is identical for every
; measurement, but the values can be different for each
; measurement. The tags below are the minimum required.
;
; details = { measurement: 'EEE', $
; n_levels: F, $
; n_laters: G, $
; idl_bitdepth: H, $
; bit_rate: [I,J] }
;

function HVS_DEFAULT_IRIS
  compile_opt idl2

  ; First retrieve general, non-instrument-specific details:
  g = HVS_GEN()

  ; Each measurement requires some details to control the creation of
  ; the JP2K files:
  d = {measurement: '', $
    n_levels: 0, $
    n_layers: 224, $
    idl_bitdepth: 8, $
    bit_rate: [-1, -1], $
    dataMin: 0.0, $
    dataMax: 0.0, $
    dataScalingType: 0}

  ; In this case, each IRIS measurement requires the same type of details:
  a = replicate(d, 2)

  ; Full description:
  b = {details: a, $ ; REQUIRED
    observatory: 'IRIS', $ ; REQUIRED
    instrument: 'SJI', $ ; REQUIRED
    detector: 'SJI', $ ; REQUIRED
    nickname: 'SJI', $ ; REQUIRED
    hvs_details_filename: 'hvs_default_iris.pro', $ ; REQUIRED
    hvs_details_filename_version: '1.0'} ; REQUIRED

  ; 1330A:
  b.details[0].measurement = '1330' ; REQUIRED
  b.details[0].n_levels = 0 ; REQUIRED
  b.details[0].n_layers = 224 ; REQUIRED
  b.details[0].IDL_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [-1, -1] ; REQUIRED

  ; 1400A:
  b.details[1].measurement = '1400' ; REQUIRED
  b.details[1].n_levels = 0 ; REQUIRED
  b.details[1].n_layers = 224 ; REQUIRED
  b.details[1].IDL_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [-1, -1] ; REQUIRED

  ; 2796
  b.details[1].measurement = '2796' ; REQUIRED
  b.details[1].n_levels = 0 ; REQUIRED
  b.details[1].n_layers = 224 ; REQUIRED
  b.details[1].IDL_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [-1, -1] ; REQUIRED

  ; 2832
  b.details[1].measurement = '2832' ; REQUIRED
  b.details[1].n_levels = 0 ; REQUIRED
  b.details[1].n_layers = 224 ; REQUIRED
  b.details[1].IDL_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [-1, -1] ; REQUIRED

  ; Verify:
  verify = {naxis1: {default: 4096, accept: {type: g.exact, value: [4096]}}, $
    naxis2: {default: 4096, accept: {type: g.exact, value: [4096]}}}

  b = add_tag(b, verify, 'verify')
  return, b
end