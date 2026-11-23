import Lean
open Lean Meta

/-- `inductive T : Type → Type | mk : (a : Type) → (y : #1) → T #1` (one parameter).
    The `#1` in the domain of `y` is a LOOSE bound variable at that point. -/
def decl : Declaration :=
  .inductDecl [] 1
    [{ name := `T, type := .forallE `a (.sort 1) (.sort 1) .default,
       ctors := [{ name := `T.mk,
                   type := .forallE `a (.sort 1)
                             (.forallE `y (.bvar 1) (.app (.const `T []) (.bvar 1)) .default) .default }] }]
    false

run_meta do
  try
    addDecl decl
    IO.println "RESULT-16489: ACCEPTED (addDecl succeeded)"
  catch e =>
    IO.println s!"RESULT-16489: REJECTED: {(← e.toMessageData.toString).splitOn "\n" |>.head!}"
