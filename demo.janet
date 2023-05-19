(import ./jty)

(print (jty/bold "bold") " "
       (jty/dim "dim") " "
       (jty/italic "italic") " "
       (jty/underline "underline") " "
       (jty/blink "blink") " "
       (jty/inverse "inverse") " "
       (jty/strikethrough "strikethrough"))

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

# 24 bit foreground colors
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

# 24 bit background colors
(print (jty/bg [9 165 184] " ")
       (jty/bg [7 149 175] " ")
       (jty/bg [7 123 165] " ")
       (jty/bg [7 113 155] " ")
       (jty/bg "#de6418" " ")
       (jty/bg "#de9518" " ")
       (jty/bg "#dec718" " ")
       (jty/bg "#d1de18" " "))

(print (string "Hello " (jty/prompt "Name")))
(def age (jty/prompt-number "Age"))
(print (string age " years is a long time"))
(print (string (jty/prompt-number "Year born" (- ((os/date) :year) age))
               " was a good year"))

(print (jty/confirm "Should we proceed?" true))
(print (jty/confirm "Should we proceed?" false))

(print (jty/select "Select an option (j/k to move)" ["red" "blue" "green"]))
