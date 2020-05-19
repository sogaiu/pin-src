(import jdn)
(import path)
(import sh)
(import walk-dir)

# for: (defsrc some-src ...)
#              ^^^^^^^^
# extract some-src
(defn- extract-defsrc-names
  [forms-str]
  (keep |(when (and (= :tuple (type $))
                    (not= :brackets (tuple/type $))
                    (= 'defsrc (get $ 0)))
           (when-let [name (get $ 1)]
             name))
        (jdn/decode-values forms-str)))

(comment

 (extract-defsrc-names ``
(use ../prelude)
(import ../core)

(defsrc bash-src
  :url "https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz"
  :hash "sha256:b4a80f2ac66170b2913efbfb9f2594f1f76c7b1afd11f799e22035d63077fb4d")

(defpkg bash
  :builder
  (fn []
    (core/link-/bin/sh)
    (os/setenv "PATH" (pkg-path "/bin" core/build-env))
    (unpack-src bash-src)
    (sh/$ ./configure --without-bash-malloc "--prefix=" ^ (dyn :pkg-out))
    (sh/$ make -j (dyn :parallelism))
    (sh/$ make install)))
``)

 (extract-defsrc-names (slurp (path/join (os/getenv "HOME")
                                         "src/hpkgs/core.hpkg")))

 )

(defn- usage
  []
  (eprint ``
usage: pin-src <dir-path>

  <dir-path> - a path to a directory with .hpkg files
``))

(defn main
  [& args]
  (when (= 1 (length args))
    (usage)
    (os/exit 1))
  #
  (def path
    (os/realpath (or (get args 1)
                     ".")))
  (unless (walk-dir/is-dir? path)
    (usage)
    (os/exit 1))
  #
  (walk-dir/visit-files
   path
   (fn [file-path]
     (when (= ".hpkg" (path/ext file-path))
       # XXX: check for failure
       (let [src-str (slurp file-path)]
         (each name (extract-defsrc-names src-str)
           (sh/$ hermes
                 build -m ,file-path
                 -e ,name -o ,name)))))))
