pro hv_iris_fits2jp2k, index, data, files_out, obsid = obsid, $
  $ ; IRIS details file:
  details_file = details_file, $
  $ ; Output directories for generated jpeg2000 images:
  dir_obs_wave_out_iris = dir_obs_wave_out_iris, $
  dir_obs_out_cruiser = dir_obs_out_cruiser, $
  $ ; Calling program (if any):
  called_by = called_by, $
  $ ; Optionally copy jpeg2000 files to remote site:
  transfer_direct = transfer_direct, $
  no_log_time = no_log_time
  compile_opt idl2

  ; Code to create JPEG2000 versions of IRIS images

  progname = 'hv_iris_fits2jp2k'

  ; Line feed character:
  lf = string(10b)

  if ~exist(details_file) then $
    details_file = '/sanhome/slater/public_html/share/iris_jp2k/hvs_default_iris.pro'

  ; Read the details file:
  info = call_function(file_break(details_file, /no_extension))

  ; If necessary, create directories for jp2k files, log files, and database files:
  ; nickname = info.nickname
  ; storage = HV_STORAGE(nickname = info.nickname)

  ; Get general information
  g = HVS_GEN()

  ; Get contact details
  wby = HV_WRITTENBY()

  ; All the supported measurements
  wave_arr = info.details[*].measurement

  ; Number of elements in the list
  nl = n_elements(index)
  prepped = strarr(nl)

  ; Loop through all images, generating canonical helioviewer header and
  ; writing out the jpeg2000 file for each image:
  for i = 0, nl - 1 do begin
    hd = index[i]
    img = reform(data[*, *, i])
    fitsname = file_break(files_out[0])

    ; Check that this FITS file is supported
    this_wave = where(wave_arr eq trim(hd.twave1), this_wave_count)
    measurement = trim(hd.twave1)

    ; Construct an HVS
    tobs = HV_PARSE_CCSDS(hd.date_obs)

    exptime = hd.exptime

    ; Crop image to remove the parts of the CCD with no data
    idx = array_indices(img, where(img ne -200))
    min_idx = min(idx, dimension = 2)
    max_idx = max(idx, dimension = 2)
    img = img[min_idx[0] : max_idx[0], min_idx[1] : max_idx[1]]
    S = size(img, /dimensions)
    new_x = S[0]
    new_y = S[1]
    ; Replace any left overs -200 with the average
    img[where(img le 0)] = mean(img[where(img ge 0)])

    ; Exposure normalization
    img = img / (1.0 * exptime)

    ; img = (img > (info.details[this_wave].dataMin)) < info.details[this_wave].dataMax
    if info.details[this_wave].dataScalingType eq 0 then begin
      img = bytscl(img)
    endif
    if info.details[this_wave].dataScalingType eq 1 then begin
      img = bytscl(sqrt(img))
    endif
    if info.details[this_wave].dataScalingType eq 3 then begin
      img = ASinhScl(img, beta = 20)
    endif

    hd = add_tag(hd, info.observatory, 'hv_observatory')
    hd = add_tag(hd, info.instrument, 'hv_instrument')
    hd = add_tag(hd, info.detector, 'hv_detector')
    hd = add_tag(hd, measurement, 'hv_measurement')
    hd = add_tag(hd, 0.0, 'hv_rotation')
    hd = add_tag(hd, progname, 'hv_source_program')

    ; Create the hvs structure
    hvsi = {dir: '', $
      fitsname: fitsname, $
      header: hd, $
      yy: tobs.yy, $
      mm: tobs.mm, $
      dd: tobs.dd, $
      hh: tobs.hh, $
      mmm: tobs.mmm, $
      ss: tobs.ss, $
      milli: tobs.milli, $
      measurement: measurement, $
      details: info}

    ; Make the storage directory
    ; loc = storage.jp2_location + $
    ; (HV_DIRECTORY_CONVENTION(hvsi.yy,hvsi.mm,hvsi.dd,hvsi.measurement))[3]
    loc = dir_obs_wave_out_iris
    if ~file_exist(loc) then mk_dir, loc

    ; Create jpeg2000 file name according to convention
    date = hvsi.yy + '_' + hvsi.mm + '_' + hvsi.dd
    time = hvsi.hh + '_' + hvsi.mmm + '_' + hvsi.ss + '_' + hvsi.milli
    jp2_filename = 'IRIS_SJI' + '_' + measurement + '_' + date + '_' + time + '.jp2'

    ; Who created this file and where
    hv_comment = 'JP2 file created locally at ' + wby.local.institute + $
      ' using ' + progname + $
      ' at ' + systime() + '.' + lf + $
      'Contact ' + wby.local.contact + $
      ' for more details/questions/comments' + $
      ' regarding this JP2 file.' + lf

    ; Which setup file was used
    hv_comment = hv_comment + $
      'HVS (Helioviewer setup) file used to create this JP2 file: ' + $
      info.hvs_details_filename + $
      ' (version ' + info.hvs_details_filename_version + ').' + lf

    ; Source code attribution
    hv_comment = $
      HV_XML_COMPLIANCE(hv_comment + $
        'FITS to JP2 source code provided by ' + $
        g.source.contact + $
        '[' + g.source.institute + ']' + $
        ' and is available for download at ' + $
        g.source.jp2Gen_code + '.' + lf + $
        'Please contact the source code providers' + $
        'if you suspect an error in the source code.' + lf + $
        'Full source code for the entire Helioviewer Project' + $
        'can be found at ' + g.source.all_code + '.')

    if tag_exist(hd, 'hv_comment') then begin
      hv_comment = HV_XML_COMPLIANCE(hd.hv_comment) + lf + hv_comment
    endif

    ; ********************************
    ; Create full JPEG2000 XML header
    ; ********************************

    ; FITS header into string in XML format:
    xh = ''
    ntags = n_tags(hd)
    tagnames = tag_names(hd)
    tagnames = HV_XML_COMPLIANCE(tagnames)
    jcomm = where(tagnames eq 'COMMENT')
    jhist = where(tagnames eq 'HISTORY')
    jhv = where(strupcase(strmid(tagnames[*], 0, 3)) eq 'HV_')
    jhva = where(strupcase(strmid(tagnames[*], 0, 4)) eq 'HVA_')
    indf1 = where(tagnames eq 'TIME_D$OBS', ni1)
    if ni1 eq 1 then tagnames[indf1] = 'TIME-OBS'
    indf2 = where(tagnames eq 'DATE_D$OBS', ni2)
    if ni2 eq 1 then tagnames[indf2] = 'DATE-OBS'
    xh = '<?xml version="1.0" encoding = "UTF-8"?>' + lf

    ; Enclose all the FITS keywords in their own container
    xh += '<meta>' + lf

    ; FITS keywords
    xh += '<fits>' + lf
    for j = 0, ntags - 1 do begin
      if ((where(j eq jcomm) eq -1) and $
        (where(j eq jhist) eq -1) and $
        (where(j eq jhv) eq -1) and $
        (where(j eq jhva) eq -1)) then begin
        value = HV_XML_COMPLIANCE(strtrim(string(hd.(j)), 2))
        ; Do not add any FITS keywords that end with 3
        if tagnames[j].endsWith('3') then continue
        ; Ignore PC3_j parts
        if tagnames[j].endsWith('3_1') then continue
        if tagnames[j].endsWith('3_2') then continue
        ; Account for crop by updating each of the following keywords
        if tagnames[j] eq 'NAXIS1' then value = new_x
        if tagnames[j] eq 'NAXIS2' then value = new_y
        if tagnames[j] eq 'FOVX' then value = new_x * hd.cdelt1
        if tagnames[j] eq 'FOVY' then value = new_y * hd.cdelt2
        if tagnames[j] eq 'XCEN' then value = hd.xcen + abs(index[0].sltpx1Ix - hd.sltpx1Ix) * hd.cdelt1
        if tagnames[j] eq 'CRVAL1' then value = hd.xcen + abs(index[0].sltpx1Ix - hd.sltpx1Ix) * hd.cdelt1
        ; IF tagnames[j] eq "CRPIX1" THEN value = (new_x / 2) + 0.5
        ; IF tagnames[j] eq "YCEN" THEN value = index[0].ycen + (i * index[0].CDELT2)
        ; IF tagnames[j] eq "CRVAL2" THEN value = index[0].crval2 + (i * index[0].CDELT2)
        ; IF tagnames[j] eq "CRPIX2" THEN value = (new_y / 2) + 0.5
        value = HV_XML_COMPLIANCE(strtrim(string(value), 2))
        xh += '<' + tagnames[j] + '>' + value + '</' + tagnames[j] + '>' + lf
      endif
    endfor

    ; FITS history
    xh += '<history>' + lf
    j = jhist
    k = 0
    while (hd.(j))[k] ne '' do begin
      value = HV_XML_COMPLIANCE((hd.(j))[k])
      xh += value + lf
      k = k + 1
    endwhile
    xh += '</history>' + lf

    ; FITS Comments
    xh += '<comment>' + lf
    j = jcomm
    k = 0
    while (hd.(j))[k] ne '' do begin
      value = HV_XML_COMPLIANCE((hd.(j))[k])
      xh += value + lf
      k = k + 1
    endwhile
    xh += '</comment>' + lf

    ; Close the FITS information
    xh += '</fits>' + lf

    ; Explicitly encode the allowed Helioviewer JP2 tags
    xh += '<helioviewer>' + lf

    ; Original rotation state
    xh += '<HV_ROTATION>' + $
      HV_XML_COMPLIANCE(strtrim(string(hd.hv_rotation), 2)) + $
      '</HV_ROTATION>' + lf

    ; JP2GEN version
    xh += '<HV_JP2GEN_VERSION>' + $
      HV_XML_COMPLIANCE(trim(g.source.jp2Gen_version)) + $
      '</HV_JP2GEN_VERSION>' + lf

    ; JP2GEN branch revision
    xh += '<HV_JP2GEN_BRANCH_REVISION>' + $
      HV_XML_COMPLIANCE(trim(g.source.jp2Gen_branch_revision)) + $
      '</HV_JP2GEN_BRANCH_REVISION>' + lf

    ; HVS setup file
    xh += '<HV_HVS_DETAILS_FILENAME>' + $
      HV_XML_COMPLIANCE(trim(info.hvs_details_filename)) + $
      '</HV_HVS_DETAILS_FILENAME>' + lf

    ; HVS setup file version
    xh += '<HV_HVS_DETAILS_FILENAME_VERSION>' + $
      HV_XML_COMPLIANCE(trim(info.hvs_details_filename_version)) + $
      '</HV_HVS_DETAILS_FILENAME_VERSION>' + lf

    ; JP2 comments
    xh += '<HV_COMMENT>' + hv_comment + '</HV_COMMENT>' + lf

    ; Explicit support from the Helioviewer Project
    xh += '<HV_SUPPORTED>TRUE</HV_SUPPORTED>' + lf

    ; Close the Helioviewer information
    xh += '</helioviewer>' + lf

    ; Enclose all the XML elements in their own container
    xh += '</meta>' + lf

    ; Write this JP2 file:
    oJP2 = obj_new('IDLffJPEG2000', concat_dir(loc, jp2_filename), /write, $
      bit_rate = info.details[this_wave].bit_rate, $
      n_layers = info.details[this_wave].n_layers, $
      n_levels = info.details[this_wave].n_levels, $
      progression = 'RPCL', $
      xml = xh, $
      reversible = 1)
    oJP2.setData, img
    obj_destroy, oJP2
    prepped[i] = loc + jp2_filename

    ; ==============================================================================
    ; Optionally also write this JPEG2000 file to a corresponding cruiser directory:
    ; ==============================================================================

    if ~exist(do_cruiser) then do_cruiser = 1 ; Temporary hardcode

    if keyword_set(do_cruiser) then begin
      ; Create cruiser obs directory if it does not already exist:
      if ~file_exist(dir_obs_out_cruiser) then mk_dir, dir_obs_out_cruiser

      oJP2 = obj_new('IDLffJPEG2000', /write, $
        concat_dir(dir_obs_out_cruiser, jp2_filename), $
        bit_rate = info.details[this_wave].bit_rate, $
        n_layers = info.details[this_wave].n_layers, $
        n_levels = info.details[this_wave].n_levels, $
        progression = 'RPCL', $
        xml = xh, $
        reversible = 1)
      oJP2.setData, img
      obj_destroy, oJP2
    endif ; End of optional file write to cruiser dir
  endfor

  no_log_latest_file_time = 1 ; Temporary hardcode

  ; Update the 'last file written' log:
  if not keyword_set(no_log_latest_file_time) then begin
    t_create_ut = anytim(ut_time(!stime), /ccsds)
    t_create_ut_sec = anytim(t_create_ut)
    t_obs_ut = hd.date_obs
    t_obs_ut_sec = anytim(t_obs_ut)
    t_obs_lag_sec = t_create_ut_sec - t_obs_ut_sec

    if not exist(dir_logs) then dir_logs = '~/logs'
    filnam_t_last = concat_dir(dir_logs, 'last_file_' + strtrim(hd.wavelnth, 2))
    buff = t_create_ut + ' ' + strtrim(t_create_ut_sec, 2) + ' ' + t_obs_ut + ' ' + $
      strtrim(t_obs_ut_sec, 2) + ' ' + strtrim(t_obs_lag_sec, 2)
    file_append, filnam_t_last, buff, /new
  endif

  RETURN
end