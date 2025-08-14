if status is-interactive
    set fish_greeting
end

function ls
    command ls --color=auto $argv
end

function ctc
    command pwd | wl-copy
end

# Created by `pipx` on 2025-08-14 00:36:48
set PATH $PATH /home/asaelvim/.local/bin
