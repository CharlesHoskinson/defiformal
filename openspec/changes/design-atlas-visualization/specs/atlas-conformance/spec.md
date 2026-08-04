## ADDED Requirements

### Requirement: Palette conformance runs at build time

The build SHALL simulate deuteranopia and protanopia over the final swatch set
and SHALL fail if any two semantically distinct swatches fall below 1.5:1
luminance separation.

#### Scenario: A regression reintroduces a hue collision
- **WHEN** a change makes any hazard swatch and any stratum swatch indistinguishable under simulation
- **THEN** the build fails with the offending pair named

#### Scenario: Text contrast regression
- **WHEN** any text-on-background pair falls below 4.5:1 at its rendered size
- **THEN** the build fails

### Requirement: Payload budget is enforced

The single-file deliverable SHALL NOT exceed 150 KB gzipped.

#### Scenario: A dependency pushes past budget
- **WHEN** a build produces a file above the budget
- **THEN** the build fails and reports the largest contributors

#### Scenario: A 3D or scene-graph library is reintroduced
- **WHEN** a scene-graph or 3D rendering dependency appears in the dependency tree
- **THEN** the build fails

### Requirement: Keyboard traversal is tested, not asserted

The harness SHALL verify that every entry is reachable and activatable by
keyboard in each reading order.

#### Scenario: An entry becomes unreachable
- **WHEN** a change leaves any element unreachable by keyboard in any reading order
- **THEN** the harness fails and names the element

#### Scenario: Focus is lost
- **WHEN** applying a filter removes the focused element and focus falls to the document body
- **THEN** the harness fails

### Requirement: Reduced motion is verified

The harness SHALL assert that under `prefers-reduced-motion: reduce` no
positional interpolation, stagger or auto-movement occurs.

#### Scenario: Motion leaks through
- **WHEN** any element animates position under reduced motion
- **THEN** the harness fails

#### Scenario: Reduced-motion parity
- **WHEN** reduced motion is active
- **THEN** the two-up comparison view is available and no feature is absent relative to the default experience

### Requirement: Accessible names follow the fixed template

The harness SHALL assert every element tile's accessible name contains all nine
required fields.

#### Scenario: A field is missing
- **WHEN** any tile's accessible name omits status, stratum token, hazard class or discriminator requirement
- **THEN** the harness fails and names the tile

### Requirement: The data export stays in sync with the document

The harness SHALL compare the typed data export against
`docs/UNIFIED-DEFI-ELEMENT-TABLE.md`.

#### Scenario: Counts drift
- **WHEN** the export's core, candidate or contested counts disagree with the document
- **THEN** the build fails with the differing counts reported

#### Scenario: A status changes in one place only
- **WHEN** an element's status differs between the export and the document
- **THEN** the build fails and names the element
