
pro go_mk_jp2k, sttim, entim, wave=wave, cadence=cadence, $
  hrs_forward=hrs_forward, minutes_backoff=minutes_backoff, hrs_chunk=hrs_chunk, $
  test=test, verbose=verbose, debug=debug

if not exist(wave) then wave = 171
wave_string = strtrim(wave, 2)
if not exist(cadence) then cadence = 36 ; seconds
if not exist(hrs_forward) then hrs_forward = 1
if not exist(minutes_backoff) then minutes_backoff = 5
if not exist(hrs_chunk) then hrs_chunk = 1

if not exist(t0) then begin
  if not exist(dir_logs) then dir_logs = concat_dir('$HOME', 'logs/jp2k')
  file_t_last = concat_dir(dir_logs, 'last_file_' + wave_string + '.txt')
  if file_exist(file_t_last) then $
    rd_tfile, file_t_last, buff else $
      return

  t_create_ut     = buff[0]
  t_create_ut_sec = buff[1]
  t_obs_ut        = buff[2]
  t_obs_ut_sec    = anytim(t_obs_ut)
  t_obs_lag_sec   = buff[4]

  t_now_ut = anytim(ut_time(!stime), /ccsds)
  t_now_ut_sec = anytim(t_now_ut)
  t_create_lag_sec = t_now_ut_sec - t_create_ut_sec
  sttim = anytim(t_obs_ut_sec -  minutes_backoff*60d0, /ccsds)
endif

spawn, 'ps -jdalf | grep slater', buff_jobs
n_jobs = n_elements(buff_jobs)
patt = 'go_aia_' + strtrim(wave)
ss_match = where(strpos(buff_jobs, patt) ne -1, n_match)
if n_match gt 0 then begin
  for i=0, n_match do begin
    s0_arr = str2arr(strtrim(buff_jobs[i],2), delim=' ', /npmult)
    pgid = s0_arr[5]
    for j=0,n_jobs-1 do begin
      s1_arr = str2arr(strtrim(buff_jobs[j],2), delim=' ', /npmult)
      pgid0 = s0_arr[5]
      if pgid0 eq pgid then begin
        pid0 = s1_arr[3]
        print, ' killing PID ' + pid0
;        spawn, 'kill ' + pid0
      endif
    endfor
  endfor
endif

if not exist(entim) then entim = anytim(t_file_last_sec + hrs_forward*3600d0, /ccsds)

if keyword_set(verbose) then begin
  print, 't_last = ' + strtrim(t_last,2)
  print, 'sttim = ' + strtrim(sttim,2)
  print, 'entim = ' + strtrim(entim,2)
endif

t_grid = timegrid(sttim, entim, hour=hrs_chunk)
n_tim = n_elements(t_grid)

for i=0,n_tim-2 do begin
    files_struct = ssw_aia_gridfiles( t_grid[i], t_grid[i+1], waves=wave_string, level=1.5, sec_grid=cadence, $
      /array, debug=debug, _extra=_extra)
    list = files_struct.(2)
    if list[0] ne '' then begin
      list = list[uniq(list)]
STOP
;      if ((wave_string eq 'blos') or (wave_string eq 'cont')) then $
;        hv_hmi_list2jp2_gs, list, details_file=details_file else $
;        hv_aia_list2jp2_gs2, list, details_file='hvs_version5_aia'
    endif

    print, 'Finished wave ' + strtrim(wave_arr[j],2) + ' for ' + anytim(t_grid[i], /yoh)
endfor

end
