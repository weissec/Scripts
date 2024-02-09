
percentBar ()  {
    local prct totlen=$((8*$2)) lastchar barstring blankstring;
    printf -v prct %.2f "$1"
    ((prct=10#${prct/.}*totlen/10000, prct%8)) &&
        printf -v lastchar '\\U258%X' $(( 16 - prct%8 )) ||
            lastchar=''
    printf -v barstring '%*s' $((prct/8)) ''
    printf -v barstring '%b' "${barstring// /\\U2588}$lastchar"
    printf -v blankstring '%*s' $(((totlen-prct)/8)) ''
    printf -v "$3" '%s%s' "$barstring" "$blankstring"
}


percentBar 72.1 40 bar
# printf 'Show this: \e[44;33;1m%s\e[0m at %s%%\n' "$bar" 72.1
printf '\r\e[47;32m%s\e[0m%6.2f%%' "$bar" 65
