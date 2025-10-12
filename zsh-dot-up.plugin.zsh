dot_up__regex='^\s*(\.){2,}\s*$'
dot_up__showing=false

function _dot_up_should_skip() {
        if (( ${+widgets} && ${+widgets[double-dot-expand]} ))
        then
                return 0
        fi

        if zstyle -t ':zim:input' double-dot-expand 2>/dev/null
        then
                return 0
        fi

        return 1
}

function _dot_up_convert_to_slash_dots() {
        local dots="${BUFFER//[[:space:]]}"
        local count="${#dots}"

        local target=".."
        for ((i = 2; i < count; i++))
        do
                target="$target/.."
        done

        echo "$target"
}

function _dot_up_show_destination() {
        if _dot_up_should_skip
        then
                if [ "$dot_up__showing" = true ]
                then
                        zle -M ""
                        dot_up__showing=false
                fi
                return
        fi

        if [[ "$BUFFER" =~ $dot_up__regex ]]
        then
                local absolute_path=$(readlink -f "$(_dot_up_convert_to_slash_dots)")
                zle -M "Destination: $absolute_path"
                dot_up__showing=true
        elif [ "$dot_up__showing" = true ]
        then
                zle -M ""
                dot_up__showing=false
        fi
}

function _dot_up_move() {
        if _dot_up_should_skip
        then
                return
        fi

        if [[ "$BUFFER" =~ $dot_up__regex ]]
        then
                BUFFER="cd $(_dot_up_convert_to_slash_dots)"
        fi
}

function _dot_up_try_hook_registration() {
        autoload -Uz add-zle-hook-widget 2>/dev/null || return 1
        autoload -Uz remove-zle-hook-widget 2>/dev/null

        if ! (( ${+functions[add-zle-hook-widget]} ))
        then
                return 1
        fi

        if (( ${+functions[remove-zle-hook-widget]} ))
        then
                remove-zle-hook-widget line-pre-redraw _dot_up_show_destination 2>/dev/null
                remove-zle-hook-widget line-finish _dot_up_move 2>/dev/null
        fi

        add-zle-hook-widget line-pre-redraw _dot_up_show_destination 2>/dev/null || return 1
        add-zle-hook-widget line-finish _dot_up_move 2>/dev/null || return 1

        return 0
}

zle -N _dot_up_show_destination
zle -N _dot_up_move

if _dot_up_try_hook_registration
then
        dot_up__hook_strategy=hook
else
        zle -N zle-line-pre-redraw _dot_up_show_destination
        zle -N zle-line-finish _dot_up_move
        dot_up__hook_strategy=fallback
fi
