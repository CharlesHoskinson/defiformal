import DefiKernel.Nary.Tree.Shape

/-! Path schedules: resolve, encode, decode. Decode validates every submitted path
before any financial execution. First invalid token keeps its full path and index. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

inductive Direction where
  | left
  | right
  deriving DecidableEq, Repr

abbrev Path := List Direction

structure PathFailure where
  tokenIndex : Nat
  fullPath : Path
  deriving DecidableEq, Repr

variable {B : Type} [DecidableEq B]

/-- One-site constructor choice used by resolve, leafOf and encode. -/
def chooseChild (left right : Tree B) (dir : Direction) : Tree B :=
  if dir = Direction.left then left else right

/-- Resolve one path to exactly a leaf. Fork/empty stop and overshoot fail. -/
def resolve (tree : Tree B) : Path → Except Path Unit
  | [] =>
    match tree with
    | .leaf _ => .ok ()
    | _ => .error []
  | dir :: rest =>
    match tree with
    | .fork left right =>
      (resolve (chooseChild left right dir) rest).mapError (fun p => dir :: p)
    | _ => .error [dir]

def leafOf (tree : Tree B) : Path → Option B
  | [] =>
    match tree with
    | .leaf b => some b
    | _ => none
  | dir :: rest =>
    match tree with
    | .fork left right => leafOf (chooseChild left right dir) rest
    | _ => none

def encodeOne (tree : Tree B) (b : B) : Path :=
  match tree with
  | .empty => []
  | .leaf _ => []
  | .fork left right =>
    if decide (b ∈ Tree.leaves left) then Direction.left :: encodeOne left b
    else Direction.right :: encodeOne right b

def encodePaths (tree : Tree B) (schedule : Schedule B) : List Path :=
  schedule.map (encodeOne tree)

def consDecoded (b : B) (decoded : List B) : List B :=
  b :: decoded

def decodeFrom (tree : Tree B) : Nat → List Path → Except PathFailure (List B)
  | _, [] => .ok []
  | idx, path :: rest =>
    match resolve tree path, leafOf tree path with
    | .ok _, some b =>
      match decodeFrom tree (idx + 1) rest with
      | .error err => .error err
      | .ok decoded => .ok (consDecoded b decoded)
    | _, _ => .error ⟨idx, path⟩

def decodePaths (tree : Tree B) (paths : List Path) :
    Except PathFailure (List B) :=
  decodeFrom tree 0 paths

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.dupNamespace false

theorem chooseChild_left (left right : Tree B) :
    chooseChild left right Direction.left = left := by
  simp [chooseChild]

theorem chooseChild_right (left right : Tree B) :
    chooseChild left right Direction.right = right := by
  simp [chooseChild]

theorem resolve_nil_leaf (b : B) :
    resolve (Tree.leaf b) [] = .ok () := rfl

theorem resolve_nil_empty :
    resolve (Tree.empty : Tree B) [] = .error [] := rfl

theorem resolve_nil_fork (left right : Tree B) :
    resolve (left.fork right) [] = .error [] := rfl

theorem leafOf_nil_leaf (b : B) : leafOf (Tree.leaf b) [] = some b := rfl

theorem leafOf_nil_empty : leafOf (Tree.empty : Tree B) [] = none := rfl

theorem decodeFrom_nil (tree : Tree B) (idx : Nat) :
    decodeFrom tree idx [] = .ok [] := rfl

theorem decodePaths_nil (tree : Tree B) :
    decodePaths tree [] = .ok [] := rfl

theorem encodeOne_leaf (b x : B) : encodeOne (Tree.leaf x) b = [] := rfl

theorem encodeOne_empty (b : B) : encodeOne (Tree.empty : Tree B) b = [] := rfl

theorem encodePaths_nil (tree : Tree B) : encodePaths tree [] = [] := rfl

theorem encodePaths_cons (tree : Tree B) (b : B) (rest : Schedule B) :
    encodePaths tree (b :: rest) = encodeOne tree b :: encodePaths tree rest := rfl

theorem decodeFrom_cons_resolve_error (tree : Tree B) (idx : Nat) (path : Path)
    (rest : List Path) (p : Path) (h : resolve tree path = .error p) :
    decodeFrom tree idx (path :: rest) = .error ⟨idx, path⟩ := by
  simp [decodeFrom, h]

theorem decodeFrom_cons_leaf_none (tree : Tree B) (idx : Nat) (path : Path)
    (rest : List Path) (hres : resolve tree path = .ok ()) (hleaf : leafOf tree path = none) :
    decodeFrom tree idx (path :: rest) = .error ⟨idx, path⟩ := by
  simp [decodeFrom, hres, hleaf]

end DefiKernel.Nary.Tree
