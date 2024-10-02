compile_opt idl2

set_logenv, 'HV_JP2GEN', '/home/nabil/Git/iris_hv_jpegs/jp2gen'
ssw_path, get_logenv('HV_JP2GEN'), /prepend

files_iris = file_search(['/home/nabil/DATA/IRIS/**/*SJI*.fits'])
;files_iris = files_iris[-4 : -1]
;files_iris = file_search(['/home/nabil/DATA/IRIS/20140917_050324_3860356063/*SJI*.fits'])
for i = 0, n_elements(files_iris) - 1 do begin
  print, 'working on', files_iris[i]
  hv_iris_fits2jp2k, files_iris[i], details_file = './hvs_default_iris.pro', dir_obs_wave_out_iris = './output', log_latest_file_time = 0, do_cruiser = 0, dir_obs_out_cruiser = './crusier'
  print, 'finsihed', files_iris[i]
endfor
print, 'Completed all files'
end