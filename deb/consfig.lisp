(in-package :ouah.ml.consfig)
(in-consfig "ouah.ml.consfig")
(named-readtables:in-readtable :consfigurator)

(defhost localhost
    (:deploy ((:ssh :user "kyurivlis") :sudo :sbcl))
  "Work VM"
  (os:debian-stable "bookworm" :amd64)
  (user:has-account "kyurivlis")
 
  (apt:standard-sources.list)
  (apt:installed "fasttrack-archive-keyring")
  (apt:additional-sources "fasttrack"
                          '("deb http://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib"
                            "deb http://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib"))
   (apt:unattended-upgrades)
   (git:installed)

   (file:directory-exists "/home/kyurivlis/s/dist")
   (file:directory-exists "/home/kyurivlis/s/s")
   (file:directory-exists "/home/kyurivlis/s/r")
   (file:directory-exists "/home/kyurivlis/s/l")
   (file:directory-exists "/home/kyurivlis/s/e")
   (file:directory-exists "/home/kyurivlis/s/m")
   (file:directory-exists "/home/kyurivlis/s/n")
   (file:directory-exists "/home/kyurivlis/s/c")
   (file:directory-exists "/home/kyurivlis/.local/bin")
   (file:directory-exists "/home/kyurivlis/.local/share/fonts")
   (git:pulled "https://github.com/kyurivlis/config" "/home/kyurivlis/c")
;;  (git:pulled "https://github.com/protesilaos/iosevka-comfy" "/home/kyurivlis/s/dist/iosevka-comfy")
   (file:symlinked :from "/home/kyurivlis/.local/share/fonts/iosevka-comfy" :to "/home/kyurivlis/s/dist/iosevka-comfy")
   (file:symlinked :from "/home/kyurivlis/.local/bin/gt" :to "/home/kyurivlis/s/dist/gt/bin/GlamorousToolkit")

  
   ;; (apt:backports-installed "emacs-gtk" "emacs-el")
   (apt:installed "i3" "dmenu" "xinit" "stterm" "firefox-esr" "build-essential" "unzip"
                  "virtualbox-guest-x11")
   (apt:removed "rxvt-unicode"))
 
