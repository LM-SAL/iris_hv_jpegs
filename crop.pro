compile_opt idl3

files_iris = ['/home/nabil/Downloads/iris_l2_20240408_061915_3680201977_SJI_2796_t000.fits']
read_iris_l2, files_iris[0], index, data

img = reform(data[*, *, 0])
for i=0, n_elements(data[0,0,*]) do begin
  
endfor
; I need to find the corners of the actual data
; Non data is -200
; I can loop over each column, find the first and last column where all of the data is not -200 (this crops the data box a tad but does that matter?)
; Then repeat this for the row.
; I can then hard crop the box of data
; Since I have the offsets from the full data array, I can work out the shift in CRPIX(?) or CRVAL(?) to account for crop in the WCS now.
; Then update all WCS keywords left, NAXISi and the others (???)

;??? total(img[*,0]) EQ -200*n_elements(img[*,0])

idx = array_indices(img, where(img NE -200))
bottom_left = idx[*,0]
top_right = idx[*,-1]

iimage,img[bottom_left[0]:top_right[0],bottom_left[1]:top_right[1]]
end