import Lean
open Lean Elab Command
-- A declaration whose stated type does not match its value, emitted with the
-- kernel check skipped so `lean` still writes the .olean. Plain `leanchecker`
-- and `leanchecker --fresh` both reject this module.
set_option debug.skipKernelTC true in
run_cmd liftCoreM <| addDecl (.thmDecl
  { name := `mismatched, levelParams := [], type := mkConst ``False,
    value := mkConst ``True.intro, all := [`mismatched] })
