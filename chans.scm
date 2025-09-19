(list (channel
       (name 'guix)
       (url "https://codeberg.org/guix/guix")
       (branch "master")
       (commit "48fea09d68d575e82c986c93785786165bd95f82")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
       (name 'rde)
       (url "https://git.sr.ht/~kyurivlis/rde")
       (branch "master")
       (introduction
        (make-channel-introduction
         "ca6ebe2f6c77f69f1afaad74bd850102b3c3cf61"
         (openpgp-fingerprint
          "DA6F 6AE9 536A 4489 C697 BED6 F9E4 8A9E 639F 1DCD"
          ))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "bca7b7f6edf28ca56846dab208f49ad1a479af5e")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
