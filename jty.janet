(import spork/rawterm)

(defn clamp [v min-v max-v]
  (cond
    (< v min-v) min-v
    (> v max-v) max-v
    v))

# write to debug log

(def debug-f (file/open "debug.log" :w))

(defn- print-debug [str]
  (file/write debug-f (string str))
  (file/write debug-f "\n")
  (file/flush debug-f))


# Layout functions

(defn- csi [str] (string "\e[" str))

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

# Cursor movement

(defn move-cursor [row col]
  (prin (csi (string/format "%d;%dH" row col))))

(defn move-cursor-up [&opt n]
  (default n 1)
  (prin (csi (string/format "%dA" n))))

(defn hide-cursor []
  (prin (csi "?25l")))

(defn show-cursor []
  (prin (csi "?25h")))

(defn clear-line []
  (prin (csi "2K")))

(defn clear-screen []
  (prin (csi "2J"))
  (move-cursor 1 1))

# Input Prompts

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

# Renderable Widgets - Experimental and not thread safe

(defn- line-count [str]
  (if (= str "") 0
    (length (string/split "\n" str))))

(defn- clear-view [view]
  (repeat (line-count view)
    (do
      (clear-line)
      (move-cursor-up))))


(def- key-buffer @[])

(defn byte-to-key [byte]
  (cond
    (= byte (chr " "))  :key-space
    (= byte (chr ":"))  :key-colon
    (= byte (chr ";"))  :key-semicolon
    (= byte (chr "\\")) :key-backslash
    (= byte (chr "/"))  :key-slash
    (= byte (chr "\n")) :key-new-line
    (= byte (chr "\r")) :key-return
    (<= 33 byte 126)    (keyword (string "key-" (string/from-bytes byte)))
    nil))

(def key-escape-sequences
  { "[D" :key-left
    "[C" :key-right
    "[A" :key-up
    "[B" :key-down })

(defn read-key-escape-sequence []
  (def [byte] (rawterm/getch))


  (if (= byte (chr "["))
    (do
      (def s (string/from-bytes byte (get (rawterm/getch) 0)))
      (if-let [key (key-escape-sequences s)]
        key
        (do
          (array/push key-buffer (byte-to-key (get s 1)))
          (array/push key-buffer (byte-to-key byte))
          :key-escape)))
    (do
      (array/push key-buffer (byte-to-key byte))
      :key-escape)))

(defn read-key []
  (def [byte] (rawterm/getch))

  (cond
    (= byte 3)          :sigint
    (= byte (chr "\e")) (read-key-escape-sequence)
    (byte-to-key byte)))

(defn get-key []
  (if-let [k (array/pop key-buffer)]
    k
    (read-key)))

(defn run-widget [c]
  (def {:view view :update update :result result} c)

  (var v "")
  
  (defn render [new-view]
    (clear-view v)
    (set v new-view)
    (print v))

  (defn cleanup []
    (rawterm/end)
    (show-cursor))

  (defn quit []
    (do (cleanup) (os/exit 1)))

  (defer (cleanup)
    (rawterm/begin)
    (hide-cursor)
    (forever
      (render (view))
      (def key (get-key))
      (if (= key :sigint) (quit))
      (case (update {:type :key :key key})
        :done (break)
        :quit (quit))))
  
  (result))

(defn select-widget [opts]
  (var i 0)
  (var scroll-top 0)
  (def [rows cols] (rawterm/size))
  (def option-width (- cols 4))
  (def list-height (min (- rows 2) (length opts)))

  (defn view []
    (def scrolled-opts (array/slice opts scroll-top (+ list-height scroll-top)))
    (string/join (map |(if (= (+ $1 scroll-top) i)
                           (bold (string " ⮕ " (fit-width $0 option-width)))
                           (string "   " (fit-width $0 option-width)))
                      scrolled-opts
                      (range (length scrolled-opts)))
                 "\n"))

  (defn update [msg]
    (defn handle-up []
      (set i (clamp (dec i) 0 (dec (length opts))))
      (when (and (> (length opts) list-height)
                 (< i scroll-top))
        (-- scroll-top)))

    (defn handle-down []
      (set i (clamp (inc i) 0 (dec (length opts))))
      (when (and (> (length opts) list-height)
                 (>= i (+ list-height scroll-top)))
        (++ scroll-top)))

    (case (msg :type)
      :key (case (msg :key)
                 :key-q      :quit
                 :key-j      (handle-down)
                 :key-down   (handle-down)
                 :key-k      (handle-up)
                 :key-up     (handle-up)
                 :key-return :done)))
 
  (defn result []
    (opts i))

  {:view view :update update :result result})


(defn select [prompt opts]
  (if (not= prompt "") (print prompt))
  (run-widget (select-widget opts)))
