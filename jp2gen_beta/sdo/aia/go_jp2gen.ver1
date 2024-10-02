
pro go_jp2gen, t0=t0, t1=t1, cadence=cadence, wave_arr=wave_arr

if not exist(cadence) then cadence=12
n_wave = n_elements(wave_arr)

t_grid = timegrid(t0, t1, hour=1)
n_tim = n_elements(t_grid)

for i=0,n_tim-2 do begin
  for j=0, n_wave-1 do begin

;    search_array = ['img_type=light','wavelnth='+strtrim(wave_arr[j],2)]

;t_samp_0s = anytim(!stime, /ccsds)
;t_sec_0s = anytim(t_samp_0s)

;    sdo_cat, t_grid[i], t_grid[i+1], cat, files, search_array=search_array, count=count, tcount=tcount

;t_samp_0e = anytim(!stime, /ccsds)
;t_sec_0e = anytim(t_samp_0e)
;delt_sec_0 = t_sec_0e - t_sec_0s
;print,' time (sec) for sdo_cat = ' + strtrim(delt_sec_0,2)

;    if count[0] ne '' then begin
;      ss_grid = grid_data(cat.date_obs, sec=cadence)
;      list = files[ss_grid]

;t_samp_1s = anytim(!stime, /ccsds)
;t_sec_1s = anytim(t_samp_1s)

    files_struct = ssw_aia_gridfiles( t_grid[i], t_grid[i+1], waves=wave_arr[j], level=1.5, sec_grid=cadence, $
      /array, search_array=search_array, debug=debug, _extra=_extra)
    list = files_struct.(2)
    if list[0] ne '' then begin
      list = list[uniq(list)]
      wave_string = strlowcase(strtrim(wave_arr[j],2))
      if ((wave_string eq 'blos') or (wave_string eq 'cont')) then $
        hv_hmi_list2jp2_gs, list, details_file=details_file else $
        hv_aia_list2jp2_gs2, list, details_file='hvs_version5_aia'

;t_samp_1e = anytim(!stime, /ccsds)
;t_sec_1e = anytim(t_samp_1e)
;delt_sec_1 = t_sec_1e - t_sec_1s
;print,' time (sec) for sdo_cat = ' + strtrim(delt_sec_1,2)

    endif

print, 'Finished wave ' + strtrim(wave_arr[j],2) + ' for ' + anytim(t_grid[i], /yoh)

  endfor
endfor

end

