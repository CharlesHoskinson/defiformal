## ADDED Requirements

### Requirement: The user chooses the reading order

Because neither groups nor strata are canonical, DOM order SHALL be set by an
explicit user-facing reading-order control offering at least: by group, by
stratum, and by ID.

#### Scenario: Changing reading order
- **WHEN** the user changes the reading order
- **THEN** DOM order is rebuilt to match, and the change is announced

#### Scenario: Changing layout
- **WHEN** the user changes layout
- **THEN** only transforms move; DOM order is unchanged

### Requirement: Full keyboard traversal without a pointer

Every entry SHALL be reachable, focusable, activatable and readable using the
keyboard alone.

#### Scenario: Entering and moving through the grid
- **WHEN** a keyboard user tabs to the grid
- **THEN** the grid takes a single tab stop via roving tabindex, arrow keys move within the current reading order, Home and End jump to the ends, and type-ahead matches on symbol

#### Scenario: Opening detail
- **WHEN** the user presses Enter on a focused tile
- **THEN** the detail surface opens as a focus-trapped dialog and returns focus to the originating tile on close

#### Scenario: Focus during transition
- **WHEN** a tile receives focus while a layout transition is in flight
- **THEN** the transition completes immediately rather than animating the focused tile

### Requirement: Search is the primary find path

The interface SHALL provide a text search over symbol, name and ID, with results
as a navigable list.

#### Scenario: Finding one element among 68
- **WHEN** the user types into search and presses Enter
- **THEN** the matching element is focused and selected without a multi-second animation

#### Scenario: Highlight-only results
- **WHEN** search results are conveyed only by highlighting tiles in the layout
- **THEN** that is a defect, because a highlight a user cannot see is not a result

### Requirement: Element and rule selection is bidirectional

Selecting a law or hazard rule SHALL identify its member elements, and selecting
an element SHALL list the laws naming it, its hazard memberships, and its bond
requirements.

#### Scenario: Interrogating a hazard
- **WHEN** the user selects a hazard rule
- **THEN** member and non-member elements are distinguished in the current layout, and the member list is available as text

#### Scenario: Interrogating an element
- **WHEN** the user opens an element's detail surface
- **THEN** it lists every law naming that element, every hazard rule naming it, and its required bonds

### Requirement: State changes are announced

Layout changes, reading-order changes, filter application and search result
counts SHALL be announced through a polite live region.

#### Scenario: Applying a filter
- **WHEN** a filter reduces the visible set
- **THEN** the live region announces the filter and the resulting count, for example "Filter: stratum S3. 11 of 68 elements shown"

#### Scenario: Focused element is filtered away
- **WHEN** the currently focused tile is removed by a filter
- **THEN** focus moves deterministically to the nearest remaining tile in reading order and that tile is announced

### Requirement: Detail content is rendered in the document plane

Definitions and body text SHALL be rendered as ordinary 2D DOM.

#### Scenario: Reading a definition
- **WHEN** the user opens any detail surface
- **THEN** its text participates in normal text sizing, zoom and selection, and is not subject to any transform that resamples glyphs

### Requirement: Tile sizing follows text size

Tile dimensions SHALL derive from a text measure in relative units and SHALL
reflow when the root font size changes.

#### Scenario: User sets a large text size
- **WHEN** a user sets text to 200%
- **THEN** tiles grow and the layout reflows, rather than clipping content or ignoring the setting
