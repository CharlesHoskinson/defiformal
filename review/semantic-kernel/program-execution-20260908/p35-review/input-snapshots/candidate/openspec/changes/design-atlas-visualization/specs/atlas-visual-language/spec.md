## ADDED Requirements

### Requirement: Colour carries hazard class and nothing else

The interface SHALL reserve all chromatic (saturated) colour for hazard class.
Stratum, group, status and interactive affordance SHALL NOT be encoded by hue.

#### Scenario: Stratum is requested in colour
- **WHEN** a designer or implementer proposes encoding stratum depth by hue
- **THEN** the proposal is rejected, and stratum is encoded by row position, a printed `S0`–`S4` token, and a monotonic lightness or inset-depth cue instead

#### Scenario: Two semantically distinct swatches are too close
- **WHEN** any two swatches carrying different meanings fall below 1.5:1 luminance separation under a deuteranopia or protanopia simulation
- **THEN** the conformance harness fails the build

### Requirement: Status is carried by text before any visual channel

Every element tile SHALL display a plain-language status badge on its face, and
SHALL include the status word in its accessible name.

#### Scenario: A user cannot perceive fill, border or colour
- **WHEN** a screen-reader user encounters any element tile
- **THEN** its accessible name states, in order: symbol, full name, ID, group, stratum token, status word, asynchrony property, hazard class, and whether a mandatory discriminator is required

#### Scenario: Status badge text
- **WHEN** a tile is rendered
- **THEN** its badge reads exactly one of `core`, `candidate: recurrence evidence short`, `contested: note required`, or `degenerate limit: not an element`

#### Scenario: Border style is used for status
- **WHEN** border style is used to reinforce status
- **THEN** it is a third redundant channel only, is at least 3px wide, and holds at least 3:1 contrast against the tile fill

### Requirement: Status glyph is perceivable at tile scale

Each status SHALL carry a persistent glyph in a fixed tile corner with a
distinct silhouette, rendered at no less than 14px.

#### Scenario: Distinguishing status at a glance
- **WHEN** a low-vision user views the matrix at default zoom
- **THEN** core, candidate, contested and degenerate-limit tiles are distinguishable by glyph silhouette alone, without colour and without reading the badge

### Requirement: The missing-denominator mark

The interface SHALL render every hazard indicator, candidate element and
contested entry as a visibly incomplete form — a fraction rule with a vacant
space where the sample size belongs. This mark SHALL NOT be used for any other
purpose.

#### Scenario: A reader encounters a hazard indicator
- **WHEN** any hazard rule is displayed
- **THEN** it carries the incomplete-form mark, and the mark's meaning — that no exposure or survivor count exists — is reachable from the legend without hover

#### Scenario: The mark is reused decoratively
- **WHEN** the incomplete-form mark appears on an element that is core and carries no hazard membership
- **THEN** that is a defect

### Requirement: Two type families with distinct epistemic roles

The interface SHALL use monospace as the superfamily for all chrome, headings,
symbols, formulas and labels, and SHALL reserve serif strictly for
human-authored assertion.

#### Scenario: Setting a definition or a caveat
- **WHEN** text expresses somebody's judgement — an element definition, a demotion note, the denominator caveat
- **THEN** it is set in the serif

#### Scenario: Setting notation
- **WHEN** text is notation such as `Pl → (Sh|Ix) + exit-liquidity`
- **THEN** it is set in monospace so glyph alignment is preserved

#### Scenario: Serif used for system output
- **WHEN** serif is applied to any text that is not a human claim
- **THEN** that is a defect

### Requirement: Contrast floors

All text SHALL meet a 4.5:1 contrast ratio against its own background at the
size rendered.

#### Scenario: Hazard colour used as text
- **WHEN** hazard chroma is used for small text or a thin glyph on the page ground
- **THEN** that is rejected; hazard text uses ink on a hazard field, or the hazard chroma is confined to marks 3px or thicker
