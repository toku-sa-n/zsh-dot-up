dot_up__regex='^\s*(\.){2,}\s*$'

function _dot_up_convert_to_slash_dots() {
        local dots="${BUFFER//[[:space:]]}"
        local count="${#dots}"

        local target=".."
        for ((i = 2; i < count; i++))
        do
                target="$target/.."
        done

        echo $target
}

function _dot_up_show_destination() {
        if [[ "$BUFFER" =~ $dot_up__regex ]]
        then
                local absolute_path=$(readlink -f $(_dot_up_convert_to_slash_dots))
                zle -M "Destination: $absolute_path"
        else
                zle -M ""
        fi
}

function _dot_up_move() {
        if [[ "$BUFFER" =~ $dot_up__regex ]]
        then
                BUFFER="cd $(_dot_up_convert_to_slash_dots)"
        fi
}

zle -N zle-line-pre-redraw _dot_up_show_destination
zle -N zle-line-finish _dot_up_move
