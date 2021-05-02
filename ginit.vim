if has("unix")
    Guifont! Sarasa Mono SC Nerd:h14
elseif has("win32")
    Guifont! 更纱黑体 Mono SC Nerd:h13
endif
GuiPopupmenu v:false
GuiTabline v:false
if has(":GuiRenderLigatures")
    GuiRenderLigatures v:true
endif

