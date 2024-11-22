compile_opt idl2

set_logenv, 'HV_JP2GEN', '/home/nabil/Git/iris_hv_jpegs/jp2gen'
ssw_path, get_logenv('HV_JP2GEN'), /prepend

files_iris = file_search(['/home/nabil/DATA/IRIS/**/*SJI*.fits'])
; files_iris = files_iris[-4 : -1]
; files_iris = file_search(['/home/nabil/DATA/IRIS/20210905_001833_3620258102/*SJI*.fits'])
for i = 0, n_elements(files_iris) - 1 do begin
  print, '########'
  print, 'STARTED ', files_iris[i]
  hv_iris_fits2jp2k, files_iris[i], details_file = './hvs_default_iris.pro', dir_obs_wave_out_iris = './output', log_latest_file_time = 0
  print, 'FINSIHED ', files_iris[i]
  print, '########'
endfor
print, '*******************'
print, 'Completed all files'
print, '*******************'
end