dot_up__regex='^\s*(\.){2,}\s*$'
dot_up__showing=false

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

function _dot_up_calculate_destination() {
        local dots="${BUFFER//[[:space:]]}"
        local count="${#dots}"
        local destination="$PWD"

        local levels=$((count - 1))
        local i
        for ((i = 0; i < levels; i++))
        do
                destination="${destination:h}"
        done

        print -r -- "$destination"
}

function _dot_up_show_destination() {
        if [[ "$BUFFER" =~ $dot_up__regex ]]
        then
                local destination
                if destination=$(_dot_up_calculate_destination)
                then
                        zle -M "Destination: $destination"
                        dot_up__showing=true
                else
                        zle -M ""
                        dot_up__showing=false
                fi
        elif [ "$dot_up__showing" = true ]
        then
                zle -M ""
                dot_up__showing=false
        fi
}

function _dot_up_move() {
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

if ! _dot_up_try_hook_registration
then
        zle -N zle-line-pre-redraw _dot_up_show_destination
        zle -N zle-line-finish _dot_up_move
fi
