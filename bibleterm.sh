#!/bin/sh
# bibleterm: Read the Bible from your terminal
# License: Public domain

SELF="$0"
BIBLE="$1"
BIBLE_TEXT_PATH=$HOME/.bible-texts
PAGER="less --tilde -I -R"
# PAGER="most"
# PAGER="view"
# PAGER="nvim -R +AnsiEsc -c 'set nonumber; set norelativenumber'"
# PAGER="nvimpager -p -R +AnsiEsc"
# PAGER="nvim  -u NONE"

# Colors for less search
# export LESS_TERMCAP_so=$(echo -e '\033[103m\033[30m')
# export LESS_TERMCAP_se=$(echo -e '\e[0m')

get_data() {
	sed '1,/^#EOF$/d' < "$SELF" | tar xz -O "$1"
}

# LESS='-Pslines %lt-%lb (%Pt-%Pb \%) bytes %bt-%bb'
# export LESS

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
	elif [ "$2" = "-W" ]; then
		export BIBLETERM_NOLINEWRAP=1
		shift
	elif [ "$2" = "-p" ]; then
        BIBLE_TEXT_PATH=$3
        break
	elif [ "$1" = "-h" ] || [ "$isFlag" -eq 1 ]; then
		show_help
	else
		break
	fi
done

cols=$(tput cols 2>/dev/null)
if [ $? -eq 0 ]; then
	export BIBLETERM_MAX_WIDTH="$cols"
fi

if [ $# -eq 1 ]; then
	if [ ! -t 0 ]; then
		show_help
	fi

	# Interactive mode
	while true; do
        read -e -p " 🕮  [${BIBLE^^}]  " ref
        if [[ -z $ref ]]; then
            continue
        fi
        if [[ $ref == \q ]]; then
            exit 0
        fi
        if [[ $ref == \h ]]; then
            show_commands
            continue
        fi
        if [[ $ref == \b ]]; then
            cat "$BIBLE_TEXT_PATH/$1.tsv" | awk -v cmd=list "$(cat bibleterm.awk)"
            continue
        fi
        if [[ $ref == \v ]]; then
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
        # if [[ $ref == @* ]]; then
        #     BIBLE=`ls bible-texts | sed -e 's/\.tsv$//' | fzf --height 40% --layout=reverse`
        #     continue
        # fi
        history -s "$ref"

		cat "$BIBLE_TEXT_PATH/$BIBLE.tsv" | awk -v cmd=ref -v ref="$ref" "$(get_data bibleterm.awk)" | ${PAGER}
	done
	exit 0
fi

cat "$BIBLE_TEXT_PATH/$BIBLE.tsv" | awk -v cmd=ref -v ref="${@:2}" "$(get_data bibleterm.awk)" | ${PAGER}
