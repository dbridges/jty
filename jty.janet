# Layout functions

(def- escape-sequence '(sequence "\e[" (some (set "0123456789;")) "m"))

(defn width [s]
  "Returns the length of the string with escape sequences removed"
  (length (peg/replace-all escape-sequence "" s)))

(defn- pad [s len dir &opt char]
  (default char " ")
  (if (< (width s) len) (pad (if (= dir :left) (string char s) (string s char))
                              len dir char)
    s))

(defn pad-right
  "Pads s to the right with char (default space) until s has visual length len"
  [s len &opt char]
  (default char " ")
  (pad s len :right char))

(defn pad-left 
  "Pads s to the left with char (default space) until s has visual length len"
  [s len &opt char]
  (default char " ")
  (pad s len :left char))

(defn fit-width
  "Fits s to visual width len by padding with space characters or truncating s. align can be :left or :right."
  [s len &opt align]
  (default align :left)
  (def pad (if (= align :left) pad-right pad-left))
  (cond
    (< (width s) len) (pad s len)
    (> (width s) len) (string (string/slice s 0 (- len 1)) "…")
    s))

# Formatting functions

(defn bold "Formats s as bold text" [s] (string "\e[1m" s "\e[22m"))
(defn dim "Formats s as dim text" [s] (string "\e[2m" s "\e[22m"))
(defn italic "Formats s as italic text" [s] (string "\e[3m" s "\e[23m"))
(defn underline "Formats s as underline text" [s] (string "\e[4m" s "\e[24m"))
(defn blink "Formats s as blinking text" [s] (string "\e[5m" s "\e[25m"))
(defn inverse "Formats s as inverse text" [s] (string "\e[7m" s "\e[27m"))
(defn strikethrough "Formats s as strikethrough text" [s] (string "\e[9m" s "\e[29m"))

# Colors
(def fg-colors {:black "30"
                :red "31"
                :green "32"
                :yellow "33"
                :blue "34"
                :magenta "35"
                :cyan "36"
                :white "37"
                :default "39"})

(def bg-colors {:black "40"
                :red "41"
                :green "42"
                :yellow "43"
                :blue "44"
                :magenta "45"
                :cyan "46"
                :white "47"
                :default "49"})

(defn- parse-hex [hex]
  (let [s (if (string/has-prefix? "#" hex) (string/slice hex 1 -1) hex)]
    (map |(scan-number $0 16)
         [(string/slice s 0 2)
          (string/slice s 2 4)
          (string/slice s 4 6)])))

(defn fg
  "Sets text foreground color. Accepts a keyword corresponding to the traditional 8 colors, a number between 0-255 specifying an 8 bit color, a tuple of 3 numbers or an html hex code for 24 bit color."
  [col s]
  (case (type col)
    :string (fg (parse-hex col) s)
    :number (string "\e[38;5;" col "m" s "\e[39m")
    :tuple (string "\e[38;2;" (col 0) ";" (col 1) ";" (col 2) "m" s "\e[39m")
    :array (string "\e[38;2;" (col 0) ";" (col 1) ";" (col 2) "m" s "\e[39m")
    :keyword (string "\e[" (get fg-colors col "39") "m" s "\e[39m")
    s))

(defn bg
  "Sets text background color. Accepts a keyword corresponding to the traditional 8 colors, a number between 0-255 specifying an 8 bit color, a tuple of 3 numbers or an html hex code for 24 bit color."
  [col s]
  (case (type col)
    :string (bg (parse-hex col) s)
    :number (string "\e[48;5;" col "m" s "\e[49m")
    :tuple (string "\e[48;2;" (col 0) ";" (col 1) ";" (col 2) "m" s "\e[49m")
    :array (string "\e[48;2;" (col 0) ";" (col 1) ";" (col 2) "m" s "\e[49m")
    :keyword (string "\e[" (get bg-colors col "39") "m" s "\e[49m")
    s))

# Getting input
(defn prompt [question &opt dflt]
  (default dflt "")
  (def default-msg (if (= dflt "") "" (string " [" dflt "]")))
  (def msg (string question default-msg ": "))
  (def resp (string/trim (getline msg)))
  (if (= resp "") (string dflt) resp))

(defn prompt-number [question &opt dflt]
  (or (scan-number (prompt question dflt))
      (prompt-number question dflt)))

(defn confirm [question &opt dflt]
  (default dflt true)
  (def dflt-string (if (= dflt true) "y" "n"))
  (def resp (prompt question dflt-string))
  (= resp "y"))
