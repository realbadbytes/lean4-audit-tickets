import Lean
open Lean Meta
def mkBlock (ns c2 : Name) : Declaration :=
  let I1 := ns ++ `I1; let I2 := ns ++ `I2; let i2 := mkConst I2
  let pTy := mkForall `_ .default i2 (mkSort Level.zero)
  let fty := mkForall `P .default pTy (mkForall `x .default i2 (mkForall `y .default i2
               (mkForall `h .default (mkApp (mkBVar 2) (mkBVar 1)) (mkApp (mkBVar 3) (mkBVar 1)))))
  let fn := mkLambda `_ .default fty (mkConst ``Nat.zero)
  let arg := mkLambda `P .default pTy (mkLambda `x .default i2 (mkLambda `y .default i2
               (mkLambda `h .default (mkApp (mkBVar 2) (mkBVar 1)) (mkBVar 0))))
  let mk1 := mkApp (mkConst I1) (mkApp fn arg)
  .inductDecl [] 0 [{ name := I1, type := mkForall `n .default (mkConst ``Nat) (mkSort Level.one),
                      ctors := [{ name := I1 ++ `mk, type := mk1 }] },
                    { name := I2, type := mkSort Level.one, ctors := [{ name := c2, type := i2 }] }] false
run_meta do
  try addDecl (mkBlock `case3 ``PUnit.unit); IO.println "RESULT-16649: ACCEPTED (block validated)"
  catch e => IO.println s!"RESULT-16649: {(← e.toMessageData.toString).splitOn "\n" |>.head!}"
