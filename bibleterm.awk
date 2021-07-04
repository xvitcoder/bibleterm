function  BLACK(X)             { return "\033[30m"   X "\033[0m" }
function  RED(X)               { return "\033[31m"   X "\033[0m" }
function  GREEN(X)             { return "\033[32m"   X "\033[0m" }
function  YELLOW(X)            { return "\033[33m"   X "\033[0m" }
function  BLUE(X)              { return "\033[34m"   X "\033[0m" }
function  MAGENTA(X)           { return "\033[35m"   X "\033[0m" }
function  CYAN(X)              { return "\033[36m"   X "\033[0m" }
function  WHITE(X)             { return "\033[37m"   X "\033[0m" }
function  BRIGHT_BLACK(X)      { return "\033[90m"   X "\033[0m" }
function  BRIGHT_RED(X)        { return "\033[91m"   X "\033[0m" }
function  BRIGHT_GREEN(X)      { return "\033[92m"   X "\033[0m" }
function  BRIGHT_YELLOW(X)     { return "\033[93m"   X "\033[0m" }
function  BRIGHT_BLUE(X)       { return "\033[94m"   X "\033[0m" }
function  BRIGHT_MAGENTA(X)    { return "\033[95m"   X "\033[0m" }
function  BRIGHT_CYAN(X)       { return "\033[96m"   X "\033[0m" }
function  BRIGHT_WHITE(X)      { return "\033[97m"   X "\033[0m" }
function  BG_BLACK(X)          { return "\033[40m"   X "\033[0m" }
function  BG_RED(X)            { return "\033[41m"   X "\033[0m" }
function  BG_GREEN(X)          { return "\033[42m"   X "\033[0m" }
function  BG_YELLOW(X)         { return "\033[43m"   X "\033[0m" }
function  BG_BLUE(X)           { return "\033[44m"   X "\033[0m" }
function  BG_MAGENTA(X)        { return "\033[45m"   X "\033[0m" }
function  BG_CYAN(X)           { return "\033[46m"   X "\033[0m" }
function  BG_WHITE(X)          { return "\033[47m"   X "\033[0m" }
function  BG_BRIGHT_BLACK(X)   { return "\033[100m"  X "\033[0m" }
function  BG_BRIGHT_RED(X)     { return "\033[101m"  X "\033[0m" }
function  BG_BRIGHT_GREEN(X)   { return "\033[102m"  X "\033[0m" }
function  BG_BRIGHT_YELLOW(X)  { return "\033[103m"  X "\033[0m" }
function  BG_BRIGHT_BLUE(X)    { return "\033[104m"  X "\033[0m" }
function  BG_BRIGHT_MAGENTA(X) { return "\033[105m"  X "\033[0m" }
function  BG_BRIGHT_CYAN(X)    { return "\033[106m"  X "\033[0m" }
function  BG_BRIGHT_WHITE(X)   { return "\033[107m"  X "\033[0m" }
function  SKYBLUE(X)           { return "\033[38;2;40;177;249m" X "\033[0m" }
function  BOLD(X)              { return "\033[1m" X "\033[22m" }
function  DIM(X)               { return "\033[2m" X "\033[0m" }
function  ITALIC(X)            { return "\033[3m" X "\033[23m" }
function  UNDERLINE(X)         { return "\033[4m" X "\033[24m" }
function  BLINK(X)             { return "\033[5m" X "\033[0m" }

BEGIN {
	#  $1 Book name
	#  $2 Book abbreviation
	#  $3 Book number
	#  $4 Chapter number
	#  $5 Verse number
	#  $6 Verse
	FS = "\t"

    IGNORECASE=1

    # less = "export LESS='-PsSometext'"
    # system(less)

	if (cmd == "ref") {
		mode = parseref(ref, p)
        p["book"] = cleanbook(p["book"])
	}
}

cmd == "list" {
	if (!($2 in seen_books)) {
		printf("%s (%s)\n", $1, $2)
		seen_books[$2] = 1
	}
}

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

function parseref(ref, arr) {
	# 1. <book>
	# 2. <book>:?<chapter>
	# 3. <book>:?<chapter>:<verse>
	# 3a. <book>:?<chapter>:<verse>[,<verse>]...
	# 4. <book>:?<chapter>-<chapter>
	# 5. <book>:?<chapter>:<verse>-<verse>
	# 6. <book>:?<chapter>:<verse>-<chapter>:<verse>
	# 7. /<search>
	# 8. <book>/search
	# 9. <book>:?<chapter>/search

    # TODO: Implement the following
	# 4. <book>:?<chapter>-<chapter>/search
	# 3a. <book>:?<chapter>:<verse>[,<verse>].../search
	# 5. <book>:?<chapter>:<verse>-<verse>
	# 6. <book>:?<chapter>:<verse>-<chapter>:<verse>/search

    if (match(ref, "^[1-9]?[A-Za-zĂÂÎȘȚăâîşţА-Яа-яЁё ]+")) {
		# 1, 2, 3, 3a, 4, 5, 6, 8, 9
		arr["book"] = substr(ref, 1, RLENGTH)
		ref = substr(ref, RLENGTH + 1)
	} else if (match(ref, "^/")) {
		# 7
		arr["search"] = substr(ref, 2)
		return "search"
	} else {
        return "unknown"
	}

	if (match(ref, "^:?[1-9]+[0-9]*")) {
		# 2, 3, 3a, 4, 5, 6, 9
		if (sub("^:", "", ref)) {
			arr["chapter"] = int(substr(ref, 1, RLENGTH - 1))
			ref = substr(ref, RLENGTH)
		} else {
			arr["chapter"] = int(substr(ref, 1, RLENGTH))
			ref = substr(ref, RLENGTH + 1)
		}
	} else if (match(ref, "^/")) {
		# 8
		arr["search"] = substr(ref, 2)
		return "search"
	} else if (ref == "") {
		# 1
		return "exact"
	} else {
        return "unknown"
	}

	if (match(ref, "^:[1-9]+[0-9]*")) {
		# 3, 3a, 5, 6
		arr["verse"] = int(substr(ref, 2, RLENGTH - 1))
		ref = substr(ref, RLENGTH + 1)
	} else if (match(ref, "^-[1-9]+[0-9]*$")) {
		# 4
		arr["chapter_end"] = int(substr(ref, 2))
		return "range"
	} else if (match(ref, "^/")) {
		# 9
		arr["search"] = substr(ref, 2)
		return "search"
	} else if (ref == "") {
		# 2
		return "exact"
	} else {
        return "unknown"
	}

	if (match(ref, "^-[1-9]+[0-9]*$")) {
		# 5
		arr["verse_end"] = int(substr(ref, 2))
		return "range"
	} else if (match(ref, "-[1-9]+[0-9]*")) {
		# 6
		arr["chapter_end"] = int(substr(ref, 2, RLENGTH - 1))
		ref = substr(ref, RLENGTH + 1)
	} else if (ref == "") {
		# 3
		return "exact"
	} else if (match(ref, "^,[1-9]+[0-9]*")) {
		# 3a
		arr["verse", arr["verse"]] = 1
		delete arr["verse"]
		do {
			arr["verse", substr(ref, 2, RLENGTH - 1)] = 1
			ref = substr(ref, RLENGTH + 1)
		} while (match(ref, "^,[1-9]+[0-9]*"))

		if (ref != "") {
			return "unknown"
		}

		return "exact_set"
	} else {
        return "unknown"
	}

	if (match(ref, "^:[1-9]+[0-9]*$")) {
		# 6
		arr["verse_end"] = int(substr(ref, 2))
		return "range_ext"
	} else {
        return "unknown"
	}
}

function cleanbook(book) {
	book = tolower(book)
	gsub(" +", "", book)
	return book
}

function bookmatches(book, bookabbr, query) {
	book = cleanbook(book)
	if (book == query) {
		return book
	}

	bookabbr = cleanbook(bookabbr)
	if (bookabbr == query) {
		return book
	}

	if (substr(book, 1, length(query)) == query) {
		return book
	}
}

function printverse(verse, word_count, characters_printed) {
    comments = ""
    links = ""
    refs = ""

	verse_parts_count = split(verse, verse_parts, "#")

    if (verse_parts_count == 2) {
        verse = verse_parts[1]

        # Extract references
        if (match(verse_parts[2], /\((.*)\)/, parts)) {
            refs = parts[1]
        }

        # Extract links
        if (match(verse_parts[2], /\[(.*)\]/, parts)) {
            links = parts[1]
        }

        # Extract comments
        if (match(verse_parts[2], /\{(.*)\}/, parts)) {
            comments = parts[1]
        }
    }


	word_count = split(verse, words, " ")
    formatted_verse = ""

	for (i = 1; i <= word_count; i++) {
        clean_word = words[i]

        formatted_verse = formatted_verse " " words[i]
		characters_printed += length(clean_word)
	}

    formatted_verse = highlightText(formatted_verse)
    formatted_verse = highlightSearch(formatted_verse)
    formatted_verse = highlightStrongNumbers(formatted_verse)
    formatted_verse = highlightReferences(formatted_verse)

    if (refs != "") {
        formatted_verse = formatted_verse "\n" SPACING "\033[90m " refs "\033[0m"
    }
    if (links != "") {
        formatted_verse = formatted_verse "\n" SPACING "\033[90m " links "\033[0m"
    }
    if (comments != "") {
        formatted_verse = formatted_verse "\n" SPACING "\033[90m  " comments "\033[0m"
    }

    formatted_verse = formatted_verse "\n\n"

    printf(formatted_verse)
}

function searchText(text) {
    if (p["search"] == "") {
        return text
    }

    result = match(tolower(text), "\\s" p["search"], sres)

    return result
}

function highlightSearch(verse) {
    if (p["search"] != "" && match(verse, p["search"])) {
        value = substr(verse, RSTART, RLENGTH)
        gsub(p["search"], "\033[7m" value "\033[27m", verse)
    }

    return verse
}

function highlightStrongNumbers(verse) {
    return gensub(/{\(*(H[0-9]+)\)*}/, "\033[2m\033[3m\\1\033[0m", "g", verse)
}

function highlightReferences(verse) {
    color = "\033[90m\\1\033[0m"
    verse = gensub(/(①)/, color, "g", verse)
    verse = gensub(/(②)/, color, "g", verse)
    verse = gensub(/(③)/, color, "g", verse)
    verse = gensub(/(④)/, color, "g", verse)
    verse = gensub(/(⑤)/, color, "g", verse)
    verse = gensub(/(⑥)/, color, "g", verse)
    verse = gensub(/(⑦)/, color, "g", verse)
    verse = gensub(/(⑧)/, color, "g", verse)
    verse = gensub(/(⑨)/, color, "g", verse)
    return gensub(/(⑩)/, color, "g", verse)
}

function highlightText(verse) {
    # Text Bold
    gsub(/<b>/, "\033[1m", verse)
    gsub(/<\/b>/, "\033[22m", verse)

    # Text Italic
    gsub(/<i>/, "\033[3m", verse)
    gsub(/<\/i>/, "\033[23m", verse)

    # Text Underline
    gsub(/<u>/, "\033[4m", verse)
    gsub(/<\/u>/, "\033[24m", verse)

    # Text Reverse
    gsub(/<r>/, "\033[7m", verse)
    gsub(/<\/r>/, "\033[27m", verse)

    # Highlight Yellow
    gsub(/<hy>/, "\033[103m\033[30m", verse)

    # Highlight Red
    gsub(/<hr>/, "\033[101m\033[30m", verse)

    # Highlight Green
    gsub(/<hg>/, "\033[102m\033[30m", verse)

    # Highlight Blue
    gsub(/<hb>/, "\033[104m\033[30m", verse)

    # Highlight Magenta
    gsub(/<hm>/, "\033[105m\033[30m", verse)

    # Highlight Cyan
    gsub(/<hc>/, "\033[106m\033[30m", verse)

    # Highlight Cyan
    gsub(/<hw>/, "\033[107m\033[30m", verse)



    # Text Black
    # gsub(/<tb>/, "\033[90m", verse)

    # Text Red
    gsub(/<tr>/, "\033[91m", verse)

    # Text Green
    gsub(/<tg>/, "\033[92m", verse)

    # Text Yellow
    gsub(/<ty>/, "\033[93m", verse)

    # Text Blue
    gsub(/<tb>/, "\033[94m", verse)

    # Text Magenta
    gsub(/<tm>/, "\033[95m", verse)

    # Text Cyan
    gsub(/<tc>/, "\033[96m", verse)

    # Text SkyBlue
    gsub(/<ts>/, "\033[38;2;40;177;249m", verse)

    # Text White
    gsub(/<tw>/, "\033[97m", verse)


    # Reset colors
    gsub(/<reset>/, "\033[0m", verse)

    return verse "\033[0m"
}

function processline() {
	if (last_book_printed != $2) {
		print BLUE(BOLD(UNDERLINE($1 "\n")))
		last_book_printed = $2
	}

    if (!p["search"])
        if (last_chapter_printed != $4)
            print BLUE(BOLD(UNDERLINE("[" $1 " - " $4 "]\n")))
            last_chapter_printed = $4

    verseNumber = $4 ":" $5

    printf(BOLD(YELLOW(verseNumber)))
    printverse($6)
	outputted_records++
}


cmd == "ref" && 
    mode == "exact" && 
    bookmatches($1, $2, p["book"]) && 
    (p["chapter"] == "" || $4 == p["chapter"]) && 
    (p["verse"] == "" || $5 == p["verse"]) {

	processline()
}

cmd == "ref" && 
    mode == "exact_set" && 
    bookmatches($1, $2, p["book"]) && 
    (p["chapter"] == "" || $4 == p["chapter"]) && 
    p["verse", $5] {
        
	processline()
}

cmd == "ref" && 
    mode == "range" && 
    bookmatches($1, $2, p["book"]) && 
    ((p["chapter_end"] == "" && $4 == p["chapter"]) || ($4 >= p["chapter"] && $4 <= p["chapter_end"])) && 
    (p["verse"] == "" || $5 >= p["verse"]) && 
    (p["verse_end"] == "" || $5 <= p["verse_end"]) {
	processline()
}

cmd == "ref" && 
    mode == "range_ext" && 
    bookmatches($1, $2, p["book"]) && 
    (($4 == p["chapter"] && $5 >= p["verse"] && p["chapter"] != p["chapter_end"]) || 
        ($4 > p["chapter"] && $4 < p["chapter_end"]) || 
        ($4 == p["chapter_end"] && $5 <= p["verse_end"] && p["chapter"] != p["chapter_end"]) || 
        (p["chapter"] == p["chapter_end"] && $4 == p["chapter"] && $5 >= p["verse"] && $5 <= p["verse_end"])) {
	processline()
}

cmd == "ref" &&
    mode == "search" &&
    (p["book"] == "" || bookmatches($1, $2, p["book"])) &&
    (p["chapter"] == "" || $4 == p["chapter"]) &&
    searchText($6) {
    processline()
}

END {
	if (cmd == "ref" && outputted_records == 0) {
		print "Unknown Reference: " ref
	}
}
