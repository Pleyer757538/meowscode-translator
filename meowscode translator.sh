#!/bin/bash

# --- SELF-LAUNCH INTO NEW TERMINAL ---
if [ -z "$MEOWSCODE_LAUNCHED" ]; then
    export MEOWSCODE_LAUNCHED=1

    for term in gnome-terminal konsole xfce4-terminal xterm; do
        if command -v "$term" >/dev/null 2>&1; then
            case $term in
                gnome-terminal)
                    gnome-terminal -- bash -c "\"$0\"; exec bash"
                    exit;;
                konsole)
                    konsole -e bash -c "\"$0\"; exec bash"
                    exit;;
                xfce4-terminal)
                    xfce4-terminal --command="bash -c '$0; exec bash'"
                    exit;;
                xterm)
                    xterm -e bash -c "\"$0\"; exec bash"
                    exit;;
            esac
        fi
    done

    echo "No supported terminal emulator found."
    echo "Running in current shell."
fi

# --- MEOWSCODE MAPPINGS ---
# meow = -
# mrrp = .
# mrow = /
# mrew = space

to_meows() {
    echo "$1" \
    | sed -e 's/-/meow/g' \
          -e 's/\./mrrp/g' \
          -e 's/\//mrow/g' \
          -e 's/ /mrew/g'
}

from_meows() {
    echo "$1" \
    | sed -e 's/meow/-/g' \
          -e 's/mrrp/\./g' \
          -e 's/mrow/\//g' \
          -e 's/mrew/ /g'
}

# --- ENGLISH → MORSE ---
english_to_morse() {
    declare -A MORSE=(
        ["A"]=".-"   ["B"]="-..." ["C"]="-.-." ["D"]="-.."  ["E"]="."
        ["F"]="..-." ["G"]="--."  ["H"]="...." ["I"]=".."   ["J"]=".---"
        ["K"]="-.-"  ["L"]=".-.." ["M"]="--"   ["N"]="-."   ["O"]="---"
        ["P"]=".--." ["Q"]="--.-" ["R"]=".-."  ["S"]="..."  ["T"]="-"
        ["U"]="..-"  ["V"]="...-" ["W"]=".--"  ["X"]="-..-" ["Y"]="-.--"
        ["Z"]="--.." ["0"]="-----" ["1"]=".----" ["2"]="..---"
        ["3"]="...--" ["4"]="....-" ["5"]="....." ["6"]="-...."
        ["7"]="--..." ["8"]="---.." ["9"]="----."

        # Punctuation
        ["."]=".-.-.-" [","]="--..--" ["?"]="..--.." ["'"]=".----."
        ["!"]="-.-.--" ["/"]="-..-."  ["("]="-.--."  [")"]="-.--.-"
        ["&"]=".-..."  [":"]="---..." [";"]="-.-.-." ["="]="-...-"
        ["+"]=".-.-."  ["-"]="-....-" ["_"]="..--.-" ["\""]=".-..-."
        ["$"]="...-..-" ["@"]=".--.-."

        # Extended letters
        ["Ä"]=".-.-" ["Á"]=".-.-" ["Å"]=".-.-"
        ["É"]="..-.." ["Ñ"]="--.--" ["Ö"]="---." ["Ü"]="..--"
    )

    input=$(echo "$1" | tr 'a-z' 'A-Z')
    output=""

    for ((i=0; i<${#input}; i++)); do
        char="${input:$i:1}"
        if [[ "$char" == " " ]]; then
            output="$output / "
        else
            code="${MORSE[$char]}"
            if [[ -n "$code" ]]; then
                output="$output $code "
            else
                output="$output ? "
            fi
        fi
    done

    echo "$output"
}

# --- MORSE → ENGLISH ---
morse_to_english() {
    declare -A MORSE=(
        [".-"]="A"   ["-..."]="B" ["-.-."]="C" ["-.."]="D"  ["."]="E"
        ["..-."]="F" ["--."]="G"  ["...."]="H" [".."]="I"   [".---"]="J"
        ["-.-"]="K"  [".-.."]="L" ["--"]="M"   ["-."]="N"   ["---"]="O"
        [".--."]="P" ["--.-"]="Q" [".-."]="R"  ["..."]="S"  ["-"]="T"
        ["..-"]="U"  ["...-"]="V" [".--"]="W"  ["-..-"]="X" ["-.--"]="Y"
        ["--.."]="Z" ["-----"]="0" [".----"]="1" ["..---"]="2"
        ["...--"]="3" ["....-"]="4" ["....."]="5" ["-...."]="6"
        ["--..."]="7" ["---.."]="8" ["----."]="9"

        # Punctuation
        [".-.-.-"]="." ["--..--"]="," ["..--.."]="?" [".----."]="'"
        ["-.-.--"]="!" ["-..-."]="/"  ["-.--."]="("  ["-.--.-"]=")"
        [".-..."]="&"  ["---..."]=":" ["-.-.-."]=";" ["-...-"]="="
        [".-.-."]="+"
        ["-....-"]="-"
        ["..--.-"]="_"
        [".-..-."]="\""
        ["...-..-"]="$"
        [".--.-."]="@"

        # Extended letters
        [".-.-"]="Ä"
        ["..-.."]="É"
        ["--.--"]="Ñ"
        ["---."]="Ö"
        ["..--"]="Ü"

        # Prosign / special
        ["...---..."]="SOS"
    )

    output=""
    for code in $1; do
        if [[ "$code" == "/" ]]; then
            output="$output "
        else
            char="${MORSE[$code]}"
            if [[ -n "$char" ]]; then
                output="$output$char"
            else
                output="$output?"
            fi
        fi
    done

    echo "$output"
}

# --- MENU ---
menu() {
    echo ":3 Meowscode Translator"
    echo "1) English → Meowscode"
    echo "2) Meowscode → English"
    echo "3) Morse → Meowscode"
    echo "4) Meowscode → Morse"
    echo "5) Exit"
    echo -n "Choose: "
}

# --- MAIN LOOP ---
while true; do
    menu
    read choice

    case $choice in
        1)
            echo -n "Enter English: "
            read text
            morse=$(english_to_morse "$text")
            to_meows "$morse"
            ;;
        2)
            echo -n "Enter Meowscode: "
            read text
            morse=$(from_meows "$text")
            morse_to_english "$morse"
            ;;
        3)
            echo -n "Enter Morse: "
            read text
            to_meows "$text"
            ;;
        4)
            echo -n "Enter Meowscode: "
            read text
            from_meows "$text"
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done

