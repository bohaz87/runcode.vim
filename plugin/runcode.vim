" 检查是否存在名为 g:loaded_runcode 的全局变量
if exists('g:loaded_runcode')
  " 如果变量存在，立即结束脚本的执行
  finish
endif

" 设置全局变量 g:loaded_runcode 的值为 1，表示脚本已加载
let g:loaded_runcode = 1

" 定义一个名为 DoRunCode 的函数
fu! DoRunCode()
  " 获取当前缓冲区的名称
  let curfile = bufname("%")

  " 检查当前文件是否已命名
  if curfile == ''
    " 如果当前文件未命名，提示用户保存文件并终止函数
    echo "请先保存文件再运行代码。"
    return
  else
    " 否则，保存当前缓冲区内容
    execute "w"
  endif

  " 强制关闭预览窗口（如果有的话）
  pclose!

  " 根据当前文件类型选择适当的命令来运行代码
  if &ft == "coffee"
    " 如果文件类型是 coffee，命令是 coffee
    let ex = "coffee"
  elseif &ft == "javascript"
    " 如果文件类型是 javascript，命令是 node
    let ex = "node"
  elseif &ft == "applescript"
    " 如果文件类型是 applescript，命令是 osascript
    let ex = "osascript"
  elseif &ft == "python"
    " 尝试使用 python3 命令，如果不可用则使用 python
    if executable('python3')
      let ex = "python3"
    else
      let ex = "python"
    endif
  elseif &ft == "typescript"
    " 如果文件类型是 typescript，先编译再执行
    silent execute "!tsc ".expand("%:p")
    if v:shell_error
      echo "TypeScript 编译失败"
      return
    endif
    let build_file = substitute(expand("%:p"), '\v(.+)\.ts$', 'build/\1.js', '')
    if !filereadable(build_file)
      echo "编译后的文件未找到: ".build_file
      return
    endif
    let ex = "node"
    let curfile = build_file
  elseif &ft == "vim"
    " 如果文件类型是 vim，执行 source %，重新加载当前 Vim 脚本文件并返回
    source %
    return
  else
    " 对于其他文件类型，命令是 bash
    let ex = "bash"
  endif

  " 在当前窗口下方打开一个新窗口并调整高度
  botright 10new

  " 在新窗口中执行命令 ex（前面根据文件类型设置的命令）并传入当前文件名 curfile
  " %! 表示将命令输出重定向到当前缓冲区
  silent execute "%!".ex." ".curfile

  " 将新窗口设置为预览窗口，并将其设为只读、不可修改
  setlocal previewwindow ro nomodifiable nomodified
  " 将新窗口的缓冲区类型设为 nofile，表示这个缓冲区不对应任何文件
  setlocal buftype=nofile

  set wrap

  " 滚动到预览窗口底部
  normal! G

  " 切换回上一个窗口
  winc p
endfu

" 定义一个名为 RunCode 的命令，调用 DoRunCode 函数
command! RunCode call DoRunCode()
