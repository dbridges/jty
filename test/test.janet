(import ../jty)

(assert (= (jty/pad-right "test" 6) "test  ") "pad-right default char")
(assert (= (jty/pad-right "test" 6 ".") "test..") "pad-right custom char")

(assert (= (jty/pad-left "test" 6) "  test") "pad-left default char")
(assert (= (jty/pad-left "test" 6 ".") "..test") "pad-left custom char")

(assert (= (jty/fit-width "test" 3) "te…") "fit-width truncate")
(assert (= (jty/fit-width "test" 6) "test  ") "fit-width align left")
(assert (= (jty/fit-width "test" 6 :right) "  test") "fit-width align right")

(assert (= (jty/fg "#4080c0" "test") "\e[38;2;64;128;192mtest\e[39m") "fg hex")
(assert (= (jty/fg [64 128 192] "test") "\e[38;2;64;128;192mtest\e[39m") "fg tuple")

(assert (= (jty/bg "#4080c0" "test") "\e[48;2;64;128;192mtest\e[49m") "bg hex")
(assert (= (jty/bg [64 128 192] "test") "\e[48;2;64;128;192mtest\e[49m") "bg tuple")

(assert (= (jty/width (jty/bold "test")) 4) "width bold text")
(assert (= (jty/width (jty/fg "#4080c0" "m color")) 7) "width colored text")
(assert (= (jty/width (jty/italic (jty/fg "#4080c0" "m color"))) 7) "width combined")
