if status is-interactive
    set fish_greeting
end

function ls
    command ls --color=auto $argv
end

function ctc
    command pwd | wl-copy
end
