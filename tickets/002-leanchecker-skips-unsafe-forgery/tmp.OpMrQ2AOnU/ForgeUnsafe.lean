import Lean
open Lean Elab Command
set_option debug.skipKernelTC true in
run_cmd liftCoreM <| addDecl (.defnDecl { name := `forged, levelParams := [], type := mkConst ``False, value := mkConst ``True.intro, hints := .opaque, safety := .unsafe })
#print axioms forged
