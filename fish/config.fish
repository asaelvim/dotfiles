fastfetch
if status is-interactive
    set fish_greeting
end
#hola

function linganguliguliwachalingangulingangu
    command kitten icat ~/Pictures/donpollo.jpg
end

function p
    command paru $argv
end

function i
    command paru -S $argv
end

function ls
    command ls --color=auto $argv
end

function cc
    wl-copy (string trim (pwd))
end

function fd
    set dir (find . -type d -print | fzf)
    if test -n "$dir"
        cd "$dir"
    end
end

function fhd
    niri msg output HDMI-A-1 mode 1920x1080@119.879
    niri msg output HDMI-A-1 scale 1.0
end

function ffhd
    niri msg output HDMI-A-1 mode 1920x1080@288.002
    niri msg output HDMI-A-1 scale 1.0
end

function uhd
    niri msg output HDMI-A-1 mode 3840x2160@144.001
    niri msg output HDMI-A-1 scale 2.0
end

function ns1
    niri msg output eDP-1 scale 1.0
end

function crear_peticion
    while true
        read -P 'Página web o Sistema (web/sis): ' tipo
        if test "$tipo" = web
            read -P 'Ingresa el nombre de la página: ' pagina_web
            set dir "$HOME/projects/toronja/paginas_web/$pagina_web"
        else if test "$tipo" = sis
            read -P 'Ingresa el nombre del laboratorio: ' laboratorio
            set dir "$HOME/projects/toronja/sistemas/$laboratorio"
        else
            echo "Tipo inválido. Usa 'web' o 'sis'."
            continue
        end

        if not test -d "$dir"
            mkdir -p "$dir/modificaciones"
        end

        cd "$dir/modificaciones"

        read -P 'Nombre de la petición: ' peticion
        set dirPeticion (count *)"$peticion"

        set selection (find . -type d -print | fzf --query="$peticion")
        if test -n "$selection"
            cd "$selection"
            echo "Petición ya existente"
            return 0
        end

        mkdir -p "$dirPeticion/respaldo"
        cd "$dirPeticion"
        echo "Petición '$dirPeticion' creada en:"
        pwd
        return 0
    end
end

function na --description "Abrir Nautilus en el directorio actual"
    nohup nautilus "$PWD" >/dev/null 2>&1 &
end

function zp --description "cd al directorio que está en el portapapeles (wl-clipboard)"
    set clip (wl-paste --no-newline 2>/dev/null)

    if test -z "$clip"
        echo "📋 Portapapeles vacío"
        return 1
    end

    # Expande ~ si viene en el path
    set clip (string replace -r '^~' $HOME "$clip")

    if test -d "$clip"
        cd "$clip"
    else
        echo "No es un directorio válido:"
        echo "   $clip"
        return 1
    end
end

function dormir_app
    fg 2>/dev/null
    commandline -f repaint
end

function invocar_scooter --description "Invocar scooter desde Helix"
    # Llamar a la función existente dormir_app
    if functions -q dormir_app
        dormir_app
    end

    # Ejecutar scooter
    scooter

    # Al terminar scooter, volver a foreground con fg
    fg
end

bind \cz dormir_app
bind ctrl-shift-m hx_search_replace # Alt+m

# Created by `pipx` on 2025-08-14 00:36:48
# set PATH $PATH /home/asaelvim/.local/bin

set EDITOR helix

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
end

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    if set -q __zoxide_loop
        builtin echo "zoxide: infinite loop detected"
        builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
        return 1
    end
    __zoxide_loop=1 __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (builtin count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if test $argc -eq 2 -a $argv[1] = --
        __zoxide_cd -- $argv[2]
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (builtin commandline --current-process --tokenize)
    set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

    if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
    else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
        # If the last argument is empty, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and __zoxide_cd $result
        and builtin commandline --function cancel-commandline repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually
# ~/.config/fish/config.fish):
#
# zoxide init fish | source

starship init fish | source
