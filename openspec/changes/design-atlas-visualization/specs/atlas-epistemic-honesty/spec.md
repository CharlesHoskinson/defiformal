## ADDED Requirements

### Requirement: The interface does not claim periodicity

The interface SHALL NOT present the atlas as a periodic table, and SHALL NOT
imply that position predicts properties.

#### Scenario: Naming the object
- **WHEN** the product is titled anywhere in chrome, navigation or metadata
- **THEN** it is named on its own terms — "State-Transition Atlas" — and the phrase "periodic table" does not appear as a title, nav item or layout-button label

#### Scenario: The disavowal
- **WHEN** the phrase "periodic table" is used at all
- **THEN** it appears exactly once, inside the sentence that denies the analogy, set in the serif as a human claim, and reachable on the first screen without interaction

#### Scenario: Naming the primary layout
- **WHEN** the primary layout is labelled
- **THEN** it is named for what it does — a group-by-stratum matrix — not "table" or "period"

### Requirement: Every layout states its own mapping

Each layout SHALL carry a persistent mapping statement in its header declaring
what position means and what it does not.

#### Scenario: Viewing the matrix
- **WHEN** the matrix layout is shown
- **THEN** its header states that column means substitutability family, band means prerequisite category, and position predicts nothing else

#### Scenario: Stack order within a cell
- **WHEN** several elements share a cell
- **THEN** the interface states that their order within the cell is not semantic

### Requirement: Hazards are categorical, never quantitative

Hazard rules SHALL be encoded by membership and class only.

#### Scenario: Displaying hazards
- **WHEN** hazard rules are rendered
- **THEN** each is an equal-sized non-quantitative card carrying its class in text, and no gradient, gauge, percentage, ranked bar, area encoding or severity ordering is used

#### Scenario: The denominator statement
- **WHEN** any hazard is displayed, in any view
- **THEN** the statement "case-only evidence; exposure and survivors not collected; probability not estimated" is present and persistent, not behind a tooltip

#### Scenario: Likelihood language
- **WHEN** copy describes a hazard using probability or likelihood terms
- **THEN** that is a defect

### Requirement: Stratum is not presented as risk

The interface SHALL present stratum as a category of prerequisite.

#### Scenario: Legend copy
- **WHEN** the stratum legend is shown
- **THEN** it states that stratum is prerequisite category and not a risk score

#### Scenario: A temperature ramp is proposed
- **WHEN** stratum is encoded on a cool-to-hot ramp
- **THEN** that is rejected, because it asserts that deep-stratum elements are more dangerous — a claim the atlas does not make

### Requirement: Graded status is never flattened

The interface SHALL distinguish core, candidate, contested and degenerate-limit
entries everywhere they appear, including in search results, filter results and
the detail surface.

#### Scenario: A contested entry appears in results
- **WHEN** a contested entry is returned by search or filter
- **THEN** its status and its usage restriction travel with it, rather than depending on its position in a layout

#### Scenario: Degenerate limit
- **WHEN** the degenerate-limit entry is displayed
- **THEN** it is marked as not an element and not a variant of one

### Requirement: The classification has a visible history

The interface SHALL show the atlas version and review date globally, and SHALL
expose prior status and rationale for entries whose status changed.

#### Scenario: An element was demoted
- **WHEN** a user opens the detail surface for an element demoted during review
- **THEN** its prior status and the reason for the change are shown

#### Scenario: Revision marks in the main layout
- **WHEN** revision history is surfaced
- **THEN** it appears in the detail surface and an expandable change log, not as marks cluttering the primary layout
