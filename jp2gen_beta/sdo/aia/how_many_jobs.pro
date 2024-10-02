
function how_many_jobs, uid, string1, string2, string3=string3, cmd=cmd, buff=buff

if not exist(uid) then uid = 'slater'
if not exist (string1) then string1 = '/usr/local/itt/idl/bin/bin.linux.x86/idl'
if not exist (string2) then string2 = 'idl_batch_run'
if not exist(cmd) then cmd = 'ps www -U slater'

; cmd_arr = ['ps', 'www', '-U', uid]
cmd_arr = str2arr(strtrim(cmd,2), delim=' ', /nomult) 
spawn, cmd_arr, buff, /noshell

ss_match1 = where(strpos(buff, string1) ne -1, n_match1)
if n_match1 gt 0 then begin
  buff = buff[ss_match1]
  if exist(string2) then begin
    ss_match2 = where(strpos(buff, string2) ne -1, n_match2)
    if n_match2 gt 0 then begin
      buff = buff[ss_match2]
      if exist(string3) then begin
        ss_match3 = where(strpos(buff, string3) ne -1, n_match3)
        if n_match3 gt 0 then buff = buff[ss_match3]
      endif
    endif
  endif
  n_proc = n_elements(buff)
endif else begin
  buff = -1 & n_proc = 0
endelse

return, n_proc

end

