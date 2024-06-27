if exists('g:loaded_runcode')
  finish
endif
let g:loaded_runcode= 1

fu! DoRunCode()  
  execute "w"
  pclose! " force preview window closed

  if &ft == "coffee"
    let ex = "coffee"
  elseif &ft == "javascript"
    let ex = "node"
  elseif &ft == "applescript"
    let ex = "osascript"
  elseif &ft == "python"
    let ex = "python"
  elseif &ft == "vim"
    execute "source %"
    return
  else
    let ex = "bash"
  end

  let f = expand("%:p")

  let curfile = bufname("%")
  below new
  resize 15

  execute "%!".ex." ".curfile
  "call delete(tmpfile)

  setlocal previewwindow ro nomodifiable nomodified
  setlocal buftype=nofile

  winc p
endfu
command! RunCode call DoRunCode()
