#!/bin/sh
# bibleterm: Read the Bible from your terminal
# License: Public domain

SELF="$0"
BIBLE="$1"
BIBLE_TITLE=
BIBLE_TEXT_PATH=$HOME/documents/Church/bible-texts
# PAGER="less --tilde -I -R"
PAGER="less --tilde -j 10 -# 4 -C -I -R --incsearch"
# PAGER="most"
# PAGER="view"
# PAGER="nvim -R +AnsiEsc -c 'set nonumber; set norelativenumber'"
# PAGER="nvimpager -p -R +AnsiEsc"
# PAGER="nvim  -u NONE"

# Colors for less search
# export LESS_TERMCAP_so=$(echo -e '\033[103m\033[30m')
# export LESS_TERMCAP_se=$(echo -e '\e[0m')
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
# export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

get_data() {
	sed '1,/^#EOF$/d' < "$SELF" | tar xz -O "$1"
}

update_less_prompt() {
    BIBLE_TITLE=""

    case $BIBLE in
      de-lut)
        BIBLE_TITLE="Deutsch Luther"
        ;;
      en-asv)
        BIBLE_TITLE="American Standard Version"
        ;;
      en-kjv)
        BIBLE_TITLE="King James Version"
        ;;
      en-kjv-strong)
        BIBLE_TITLE="King James Version - Strong"
        ;;
      en-tyn)
        BIBLE_TITLE="Tyndale"
        ;;
      en-gen)
        BIBLE_TITLE="GEN"
        ;;
      en-esv)
        BIBLE_TITLE="English Standard Version"
        ;;
      gr)
        BIBLE_TITLE="Greek"
        ;;
      gr-tr)
        BIBLE_TITLE="Greek"
        ;;
      gr-tr-strong)
        BIBLE_TITLE="Greek - Strong"
        ;;
      hb-wlc)
        BIBLE_TITLE="Hebrew - Westminster Leningrad Codex"
        ;;
      ro-cor)
        BIBLE_TITLE="Cornilescu"
        ;;
      ro-fid)
        BIBLE_TITLE="Fidela"
        ;;
      ru-sin)
        BIBLE_TITLE="Синодальный"
        ;;
    esac

    LESS="-Ps$BIBLE_TITLE"
}

show_help() {
	exec >&2
	echo "usage: $(basename "$0") language [flags] [reference...]"
	echo
	echo "  -b      list books"
	echo "  -l      list bible languages"
	echo "  -W      no line wrap"
	echo "  -h      show help"
	echo
    show_reference
	exit 2
}

show_reference() {
	echo "Reference types:"
	echo "    <Book>"
	echo "        Individual book"
	echo "    <Book>:<Chapter>"
	echo "        Individual chapter of a book"
	echo "    <Book>:<Chapter>:<Verse>[,<Verse>]..."
	echo "        Individual verse(s) of a specific chapter of a book"
	echo "    <Book>:<Chapter>-<Chapter>"
	echo "        Range of chapters in a book"
	echo "    <Book>:<Chapter>:<Verse>-<Verse>"
	echo "        Range of verses in a book chapter"
	echo "    <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>"
	echo "        Range of chapters and verses in a book"
	echo
	echo "    /<Search>"
	echo "        All verses that match a pattern"
	echo "    <Book>/<Search>"
	echo "        All verses in a book that match a pattern"
	echo "    <Book>:<Chapter>/<Search>"
	echo "        All verses in a chapter of a book that match a pattern"
}

show_commands() {
	echo "Commands:"
	echo "    \b - Show the list of Bible books"
	echo "    \v - Show available Bible versions"
	echo "    \h - Show this help"
	echo "    \q - Quit"
	echo
	echo "    @<version> - Change Bible version"
	echo
}

while [ $# -gt 0 ]; do
	isFlag=0
	firstChar="${1%"${1#?}"}"
	if [ "$firstChar" = "-" ]; then
		isFlag=1
	fi

	if [ "$2" = "--" ]; then
		shift
		break
	elif [ "$2" = "-b" ]; then
		# List all book names with their abbreviations
        cat "$BIBLE_TEXT_PATH/$1.tsv" | awk -v cmd=list "$(cat bibleterm.awk)"
		exit
	elif [ "$1" = "-l" ]; then
		# List all languages
        echo "Available Bible languages: "
        for file in $BIBLE_TEXT_PATH/*
        do
            if [[ -f $file ]]; then
                echo " -" `basename $file .tsv`
            fi
        done
		exit
	elif [ "$2" = "-p" ]; then
        BIBLE_TEXT_PATH=$3
        break
	elif [ "$1" = "-h" ] || [ "$isFlag" -eq 1 ]; then
		show_help
	else
		break
	fi
done

if [ $# -eq 1 ]; then
	if [ ! -t 0 ]; then
		show_help
	fi

	# Interactive mode
	while true; do
        read -r -e -p " 🕮  [${BIBLE^^}]  " ref
        if [[ -z $ref ]]; then
            continue
        fi
        if [[ $ref == "\q" ]]; then
            exit 0
        fi
        if [[ $ref == "\h" ]]; then
            show_commands
            continue
        fi
        if [[ $ref == "\b" ]]; then
            cat "$BIBLE_TEXT_PATH/$1.tsv" | awk -v cmd=list "$(cat bibleterm.awk)"
            continue
        fi
        if [[ $ref == "\v" ]]; then
            echo "Available Bible Versions: "
            for file in $BIBLE_TEXT_PATH/*
            do
                if [[ -f $file ]]; then
                    echo " -" `basename $file .tsv`
                fi
            done
            continue
        fi
        if [[ $ref == @* ]]; then
            BIBLE=${ref:1}
            history -s "$ref"
            continue
        fi
        history -s "$ref"

        update_less_prompt
		cat "$BIBLE_TEXT_PATH/$BIBLE.tsv" | awk -v cmd=ref -v bibleTitle=$BIBLE_TITLE -v ref="$ref" "$(get_data bibleterm.awk)" | ${PAGER}
	done
	exit 0
fi

update_less_prompt
cat "$BIBLE_TEXT_PATH/$BIBLE.tsv" | awk -v cmd=ref -v bibleTitle=$BIBLE_TITLE -v ref="${@:2}" "$(get_data bibleterm.awk)" | ${PAGER}
