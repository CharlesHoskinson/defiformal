# Motion Council Log — adding three.js to the packed table

**Bundle:** `motion-bundle.md` · sha256 `e9ce8822e34f5c7d…`
**Date:** 2026-08-04 · six lanes, three provider families · **all six `changes_requested`**
**Framing:** the client directed three.js. The council was asked *how*, not *whether*.

---

## 1. Rulings

| Proposed motion | M1 craft | M2 info | M3 impl | M4 a11y | M5 art | M6 teaching | Outcome |
|---|---|---|---|---|---|---|---|
| **Ambient depth parallax** | cut | cut | — | cut | cut | cut | **CUT, unanimous** |
| **3D arrangement re-form** | cut | cut | — | — | cut | cut | **CUT** |
| **Perpetual reflexive orbit** | replace | cut | — | replace | replace | replace | **CUT — replaced** |
| **Z as standing encoding** | only as climb | cut | — | test-gated | shallow only | cut | **CUT as encoding** |
| **Protocol assembly** | keep, constrained | cut | — | keep, gated | keep, staged | **rebuild as causal chain** | **KEPT, rebuilt** |

---

## 2. Why ambient parallax died unanimously

Five lanes, independently: it teaches nothing that row position and the printed
S-token do not already carry; it is the single clearest signal of "WebGL
showcase" in a world whose entire discipline is that nothing is decorative; and
in a reference tool people keep open while reading, permanent peripheral motion
is an unpaid attention tax.

The accessibility lane went further and rejected the standard defence outright:
*"'respects prefers-reduced-motion' is not sufficient — the OS setting is opt-in
and widely unset, users on managed or borrowed machines cannot set it, and
parallax specifically manufactures a depth cue the inner ear does not
corroborate, which is the classic trigger."* Its ruling: **off by default for
everyone with a visible control**, not on-by-default behind a media query —
and it noted those are not the same ruling.

## 3. Why Z-as-depth died

- **It is redundant, not semantic.** Row position and a printed token already
  encode depth. The brief claimed the mapping was "semantic rather than
  decorative" and named no question a learner could answer in Z that they
  cannot answer today.
- **It inverts the product's own finding.** S3 holds 22 of 48 elements. Pushing
  the deepest strata furthest back makes the mass of DeFi the smallest, dimmest
  thing on screen while S0's three elements dominate the foreground.
- **It corrupts the density comparison.** Different perspective distances make
  S0 and S3 non-comparable by apparent size — which is exactly how the packed
  layout communicates its finding.
- **Occlusion breaks reference access.** In a table every element must be
  reachable and comparable; avoiding occlusion while keeping faces readable
  effectively forces a face-on camera, at which point Z reads as almost nothing.

## 4. The finding that undercuts the whole request

Raised independently by the art-direction and teaching lanes:

> With drift cut, the orbit cut and the arrangement re-form returned to 2D,
> the sole remaining job is a constrained Z translation of DOM nodes at a fixed
> camera with no free rotation — **which is a matrix on a transform, not a
> scene graph.**

The teaching lane converted this into an acceptance condition rather than an
opinion: **gate the three.js import on the two teaching artifacts.** Load it
lazily, only on protocol selection, and do not merge the dependency until the
stepped causal chain and the accelerating loop both work. If either is cut or
deferred, remove three.js from the build — because parallax and re-layout are
the cheapest parts to build and therefore the most likely to ship in place of
the teaching.

## 5. What the council put in place of the cut motions

**The assembly, rebuilt as a causal chain (M6 F2).** The most instructive fact
in the product is that Aave's parts arrive in the order each *became necessary*.
The proposed animation conveyed arrival order — which the static 1..n numbering
already did — but not necessity. Rebuilt: advance one part at a time under user
control, caption each step *"X exists, which now requires Y"*, draw a persistent
connector to the part it forces, and leave the finished chain on screen. **The
static end state is the artifact; the motion is only its delivery.**

**The reflexive loop, rebuilt to accelerate and terminate (M6 F3, M1 F3).** A
constant-velocity orbit communicates equilibrium — the opposite of what killed
Terra. Each traversal must be visibly faster than the last, carry a growing
magnitude, and end in a break: the loop snaps, the number is replaced by the
realised loss, the hazard rule appears, and it holds as a static broken figure.

**The assembly-order list, for everyone (M4 F4).** A persistent ordered list of
members 1..n with element, stratum, family and status. Not a reduced-motion
fallback — shipped to all users, built first, in the 2D document. The lane gave
it teeth: *"if the list is worth building only for reduced-motion users, the
animated version is the lesser product; if it is not worth building, the brief
is claiming the animation carries information it refuses to write down."*

**The retention test (M6 F7), now the acceptance criterion for every animation:**
after it finishes, the frozen end state must contain information the
pre-animation state did not. Parallax fails. Arrangement change fails. Assembly
passes only as rebuilt. The loop passes only as rebuilt.

## 6. If three.js ships anyway — the binding contracts

**Focus will disappear (M4 F1), and this is the finding that would have shipped
broken.** Tiles positioned by `matrix3d` are, to the browser's scroll and
viewport logic, all in the same place — so `scrollIntoView` and the implicit
scroll-to-focus on Tab do nothing. A keyboard user tabs to a tile that is
off-camera or behind another plane and the focus ring is never brought into
view. Every tile still has role, name and tabindex, so **no automated audit
catches it and no screenshot shows it.** Remedy: a `focusin` handler that drives
the camera so the focused tile is face-on and unoccluded, in the first commit
that introduces the scene, or the scene does not ship.

Also binding: CSS3D over WebGL, since WebGL deletes the accessible name, focus,
type-ahead, selectable text and the dialog (M4, M3). Wrap-as-mode, never a
second content tree — the same DOM nodes get re-parented in and out (M3 F2).
DOM order is the single authority for sequence and must be reordered on
arrangement change (M4 F2). All interactive chrome stays outside the transformed
subtree, because a transformed ancestor breaks `position: fixed` and puts the
IME candidate window in the wrong place (M4 F10). Near-orthographic camera,
FOV 12–18°, shallow Z, no horizon, no ground plane, no fog, no gloss (M5 F2).
Depth cued by rule weight and occlusion only, since shadow, colour and lightness
are all already spoken for (M5 F3).

## 7. The feature the council added

**Substitutability (M6 F6).** The product teaches what the elements are and
which protocol contains which, but not *what else could have gone there* —
which is the difference between naming an oracle and understanding that an
oracle is one answer among several with different failure modes. Sixteen
families are already drawn as blocks and nothing lets a learner ask the
question. Needs no 3D, and the lane directed it be built before any motion work.

## 8. Preserved dissent

1. **M1 vs M2 on the assembly.** M1 keeps it as the one motion that earns its
   place; M2 calls it theatre that temporarily removes the depth and family
   context which makes the sequence informative. Resolved toward M6's rebuild,
   which answers M2's objection by keeping the chain on screen — but M2's
   position is not withdrawn.
2. **M5 vs M4 on depth cues.** M5 directs occlusion plus rule weight. M4 wants
   static offset plus shadow. The system forbids shadow, so M5's version wins by
   constraint rather than by argument.
3. **M1's own dissent note** anticipates that a spatial lens would defend
   parallax as necessary to *feel* Z. No lane defended it.
