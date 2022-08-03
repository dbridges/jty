# jty

Utility functions for rich console output in the [Janet Language](https://janet-lang.org).

## Installation

`jpm install https://github.com/dbridges/jty`

## Usage

### Caveats

`jty` currently does not support unicode.

### Layout

`jty` includes functions for basic single line string layouts:

```janet
(jty/pad-right "test" 6) ; => "test  "
(jty/pad-right "test" 6 ".") ; => "test.."

(jty/pad-left "test" 6) ; => "  test"
(jty/pad-left "test" 6 ".") ; => "..test"

(jty/fit-width "test" 3) ; => "te…"
(jty/fit-width "test" 6) ; => "test  "
(jty/fit-width "test" 6 :right) ; => "  test"
```

### Formatting

`jty` includes functions for basic text formatting:
```janet
(print (jty/bold "bold") " "
       (jty/dim "dim") " "
       (jty/italic "italic") " "
       (jty/underline "underline") " "
       (jty/blink "blink") " "
       (jty/reverse "reverse") " "
       (jty/strikethrough "strikethrough"))
```

### Colors

`jty` includes functions for foreground and background coloring with the standard 8 named colors, or using 8 bit or 24 bit coloring.

```janet
# Standard 8 foreground colors
(print (jty/fg :black "black") " "
       (jty/fg :red "red") " "
       (jty/fg :green "green") " "
       (jty/fg :yellow "yellow") " "
       (jty/fg :blue "blue") " "
       (jty/fg :magenta "magenta") " "
       (jty/fg :cyan "cyan") " "
       (jty/fg :white "white") " ")

# 8 bit foreground colors
(print (jty/fg 210 "J")
       (jty/fg 214 "a")
       (jty/fg 217 "n")
       (jty/fg 220 "e")
       (jty/fg 223 "t"))

# 24 bit foreground colors in RGB or hex
(print (jty/fg [9 165 184] "J")
       (jty/fg [7 149 175] "a")
       (jty/fg [7 123 165] "n")
       (jty/fg [7 113 155] "e")
       (jty/fg [7 101 145] "t") " "
       (jty/fg "#de6418" "L")
       (jty/fg "#de9518" "a")
       (jty/fg "#dec718" "n")
       (jty/fg "#d1de18" "g"))

# Standard 8 background colors
(print (jty/bg :black "black") " "
       (jty/bg :red "red") " "
       (jty/bg :green "green") " "
       (jty/bg :yellow "yellow") " "
       (jty/bg :blue "blue") " "
       (jty/bg :magenta "magenta") " "
       (jty/bg :cyan "cyan") " "
       (jty/bg :white "white") " ")

# 8 bit background colors
(print (jty/bg 210 " ")
       (jty/bg 214 " ")
       (jty/bg 217 " ")
       (jty/bg 220 " ")
       (jty/bg 223 " "))

# 24 bit background colors in RGB or hex
(print (jty/bg [9 165 184] " ")
       (jty/bg [7 149 175] " ")
       (jty/bg [7 123 165] " ")
       (jty/bg [7 113 155] " ")
       (jty/bg "#de6418" " ")
       (jty/bg "#de9518" " ")
       (jty/bg "#dec718" " ")
       (jty/bg "#d1de18" " "))
```
