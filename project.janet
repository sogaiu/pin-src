(declare-project
  :name ""
  :author "sogaiu"
  :license "MIT"
  :url "https://github.com/sogaiu/pin-src"
  :repo "git+https://github.com/sogaiu/pin-src.git"
  :dependencies [
    "https://github.com/andrewchambers/janet-jdn"
    "https://github.com/andrewchambers/janet-sh"
    "https://github.com/janet-lang/path"
    "https://github.com/sogaiu/janet-walk-dir"
  ])

(declare-executable
  :name "pin-src"
  :entry "pin-src.janet")
