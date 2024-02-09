# Bash Progress Bar (created by F. Hauri - https://stackoverflow.com/users/1765658/f-hauri-give-up-github)
# To use, just copy the function below in your code.
# Call the function and attach the values to your variables.
# $1 = percentage, $2 = size of bar on screen, $3 = used to display the bar correctly (don't change).

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

# Calling the function (both lines needed to display the bar):
percentBar 72.1 40 bar
printf 'Progress: \r\e[47;32m%s\e[0m%6.2f%%' "$bar" 65
