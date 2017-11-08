lam $ \ as42 ->
lam $ \ z43 ->
lam $ \ t44 ->
lam $ \ docUpdate45 ->
case_ (size z43 == size t44 &&
       docUpdate45 < size z43 &&
       z43 ! docUpdate45 < size as42)
      [branch ptrue
              ((pose (prob_ 2
                      ** (nat2real (size t44) * real_ (-1/2) +
                          nat2real (size as42) * real_ (1/2)) *
                      exp (summate (nat_ 0) (size t44) (\ _a46 -> t44 ! _a46 ^ nat_ 2) *
                           real_ (-1/2)) *
                      pi ** (nat2real (size t44) * real_ (-1/2)) *
                      product (nat_ 0)
                              (size as42)
                              (\ _b47 ->
                               product (nat_ 0)
                                       (let_ (bucket (nat_ 0)
                                                     (size t44)
                                                     ((r_index (\ () -> size as42)
                                                               (\ (_a50,()) -> z43 ! _a50)
                                                               (r_add (\ (_a50,(_b51,())) ->
                                                                       nat_ 1))))) $ \ summary49 ->
                                        unsafeNat (nat2int (case_ (_b47 == z43 ! docUpdate45)
                                                                  [branch ptrue (nat_ 1),
                                                                   branch pfalse (nat_ 0)]) *
                                                   int_ -1 +
                                                   nat2int (summary49 ! _b47)))
                                       (\ j48 -> nat2prob j48 + as42 ! _b47)) *
                      recip (product (nat_ 0)
                                     (summate (nat_ 0)
                                              (size t44)
                                              (\ _a53 ->
                                               case_ (_a53 == docUpdate45)
                                                     [branch ptrue (nat_ 0),
                                                      branch pfalse (nat_ 1)]))
                                     (\ _b52 ->
                                      nat2prob _b52 +
                                      summate (nat_ 0) (size as42) (\ _a54 -> as42 ! _a54))) *
                      recip (nat2prob (summate (nat_ 0)
                                               (size t44)
                                               (\ _a55 ->
                                                case_ (_a55 == docUpdate45)
                                                      [branch ptrue (nat_ 0),
                                                       branch pfalse (nat_ 1)])) +
                             summate (nat_ 0) (size as42) (\ _a56 -> as42 ! _a56))) $
                     (categorical (array (size as42) $
                                         \ zNewb57 ->
                                         unsafeProb (fromProb (exp (summate (nat_ 0)
                                                                            (size as42)
                                                                            (\ _a58 ->
                                                                             (let_ (bucket (nat_ 0)
                                                                                           (size t44)
                                                                                           ((r_index (\ () ->
                                                                                                      size as42)
                                                                                                     (\ (i60,()) ->
                                                                                                      z43
                                                                                                      ! i60)
                                                                                                     (r_add (\ (i60,(_a61,())) ->
                                                                                                             t44
                                                                                                             ! i60))))) $ \ summary59 ->
                                                                              case_ (_a58
                                                                                     == zNewb57)
                                                                                    [branch ptrue
                                                                                            (t44
                                                                                             ! docUpdate45),
                                                                                     branch pfalse
                                                                                            (real_ 0)] +
                                                                              case_ (_a58
                                                                                     == z43
                                                                                        ! docUpdate45)
                                                                                    [branch ptrue
                                                                                            (t44
                                                                                             ! docUpdate45),
                                                                                     branch pfalse
                                                                                            (real_ 0)] *
                                                                              real_ (-1) +
                                                                              summary59 ! _a58)
                                                                             ^ nat_ 2 *
                                                                             recip (fromInt (int_ 1 +
                                                                                             (let_ (bucket (nat_ 0)
                                                                                                           (size t44)
                                                                                                           ((r_index (\ () ->
                                                                                                                      size as42)
                                                                                                                     (\ (i63,()) ->
                                                                                                                      z43
                                                                                                                      ! i63)
                                                                                                                     (r_add (\ (i63,(_a64,())) ->
                                                                                                                             nat_ 1))))) $ \ summary62 ->
                                                                                              nat2int (case_ (_a58
                                                                                                              == zNewb57)
                                                                                                             [branch ptrue
                                                                                                                     (nat_ 1),
                                                                                                              branch pfalse
                                                                                                                     (nat_ 0)]) +
                                                                                              nat2int (case_ (_a58
                                                                                                              == z43
                                                                                                                 ! docUpdate45)
                                                                                                             [branch ptrue
                                                                                                                     (nat_ 1),
                                                                                                              branch pfalse
                                                                                                                     (nat_ 0)]) *
                                                                                              int_ -1 +
                                                                                              nat2int (summary62
                                                                                                       ! _a58))))) *
                                                                    real_ (1/2))) *
                                                     fromProb (recip (nat_ 2
                                                                      `thRootOf` (nat2prob (unsafeNat (product (nat_ 0)
                                                                                                               (size as42)
                                                                                                               (\ _b65 ->
                                                                                                                int_ 2 +
                                                                                                                (let_ (bucket (nat_ 0)
                                                                                                                              (size t44)
                                                                                                                              ((r_index (\ () ->
                                                                                                                                         size as42)
                                                                                                                                        (\ (_a67,()) ->
                                                                                                                                         z43
                                                                                                                                         ! _a67)
                                                                                                                                        (r_add (\ (_a67,(_b68,())) ->
                                                                                                                                                nat_ 1))))) $ \ summary66 ->
                                                                                                                 nat2int (case_ (_b65
                                                                                                                                 == zNewb57)
                                                                                                                                [branch ptrue
                                                                                                                                        (nat_ 1),
                                                                                                                                 branch pfalse
                                                                                                                                        (nat_ 0)]) +
                                                                                                                 nat2int (case_ (_b65
                                                                                                                                 == z43
                                                                                                                                    ! docUpdate45)
                                                                                                                                [branch ptrue
                                                                                                                                        (nat_ 1),
                                                                                                                                 branch pfalse
                                                                                                                                        (nat_ 0)]) *
                                                                                                                 int_ -1 +
                                                                                                                 nat2int (summary66
                                                                                                                          ! _b65)) *
                                                                                                                int_ 2)))))) *
                                                     (fromInt (let_ (bucket (nat_ 0)
                                                                            (size t44)
                                                                            ((r_index (\ () ->
                                                                                       size as42)
                                                                                      (\ (_a70,()) ->
                                                                                       z43
                                                                                       ! _a70)
                                                                                      (r_add (\ (_a70,(zNewb71,())) ->
                                                                                              nat_ 1))))) $ \ summary69 ->
                                                               nat2int (case_ (zNewb57
                                                                               == z43 ! docUpdate45)
                                                                              [branch ptrue
                                                                                      (nat_ 1),
                                                                               branch pfalse
                                                                                      (nat_ 0)]) *
                                                               int_ -1 +
                                                               nat2int (summary69 ! zNewb57)) +
                                                      fromProb (as42 ! zNewb57))))))),
       branch pfalse
              (case_ (not (size z43 == size t44))
                     [branch ptrue (reject),
                      branch pfalse
                             (case_ (not (docUpdate45 < size z43))
                                    [branch ptrue (reject), branch pfalse (reject)])])]
