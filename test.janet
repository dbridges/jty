(import ./jty)

(def lorem "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair.")

(defn wrap-simple
  [txt width]
  (var n 0)
  (reduce (fn [acc char]
            (+= n 1)
            (if (= (mod n width) 0)
              (string acc "\n" (string/from-bytes char))
              (string acc (string/from-bytes char))))
          ""
          txt))

(defn wrap-complex
  [txt width]
  (def {:current current :lines lines} 
    (reduce (fn [{ :current current :lines lines} word]
              (if 
                (> (+ (length current) 1 (length word))
                   width)
                (do
                  (array/push lines current)
                  {:current word :lines lines})
                (let [sep (if (= (length current) 0) "" " ")]
                     {:current (string current sep word) :lines lines})
              ))
            {:current "" :lines @[]}
            (string/split " " txt)))
  (array/push lines current)
  (string/join lines "\n"))

(defn wrap
  [txt width]
  (if (< width 20)
    (wrap-simple txt width)
    (wrap-complex txt width)))

(print (wrap lorem 40))
