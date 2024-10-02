compile_opt idl2

set_logenv, 'HV_JP2GEN', '/home/nabil/Dropbox/iris_jp2k/jp2gen_beta'
ssw_path, get_logenv('HV_JP2GEN'), /prepend

files_iris = file_search(["/home/nabil/DATA/IRIS/**/*.fits"])

for i=0, n_elements(files_iris)-1 do begin
  read_iris_l2, files_iris[i], index, data
  hv_iris_fits2jp2k, index, data, files_iris[i], obsid = 'LMAO', details_file = './hvs_default_iris.pro', dir_obs_wave_out_iris = './output', dir_obs_out_cruiser = './crusier'
  endfor

