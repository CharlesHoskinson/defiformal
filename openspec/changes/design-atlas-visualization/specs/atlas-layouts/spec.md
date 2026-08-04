## ADDED Requirements

### Requirement: Layout zero is a 2D document

The canonical view SHALL be a 2D document-flow layout built from semantic
markup. It SHALL be feature complete before any other layout is implemented, and
SHALL NOT be described or scoped as a fallback.

#### Scenario: Feature parity
- **WHEN** layout zero ships
- **THEN** it contains all 68 placed entries, all 16 groups, all 5 strata, the contested register, bond laws, hazard rules, discriminators, the detail surface, search and filtering

#### Scenario: Browser affordances
- **WHEN** a user zooms the browser, uses find-in-page, prints the page, or deep-links to an element
- **THEN** each of those works, because content is real document flow rather than transformed scene objects

### Requirement: The primary layout is a group-by-stratum matrix

The matrix layout SHALL place every element in a fixed 16×5 grid of
group × stratum, in the cell matching its actual group and its actual stratum.

#### Scenario: A cell holds several elements
- **WHEN** a (group, stratum) intersection contains more than one element — up to seven do
- **THEN** the cell is a bounded container holding a consistent small-multiples grid of its elements, and displays an explicit occupancy count

#### Scenario: A cell is empty
- **WHEN** a (group, stratum) intersection contains no elements
- **THEN** the cell renders as visibly empty rather than being collapsed, so absence is legible

#### Scenario: A ragged silhouette is proposed
- **WHEN** any layout offsets a group column to begin at its shallowest stratum, so a tile's row becomes an ordinal rather than its stratum
- **THEN** that layout is rejected, because two tiles at equal height would represent different strata

### Requirement: No 3D scene, no camera

The visualisation SHALL NOT use a 3D scene graph, a perspective or trackball
camera, or per-frame matrix transforms on tiles.

#### Scenario: Layout transition
- **WHEN** the user moves between layouts
- **THEN** positions animate via FLIP or the View Transitions API on ordinary DOM, and tiles return to an untransformed resting state

#### Scenario: Non-semantic layouts are proposed
- **WHEN** a sphere, helix or arbitrary grid packing is proposed
- **THEN** it is rejected unless its position asserts a property present in the data

### Requirement: Layout transitions are brief and unstaggered

Layout transitions SHALL complete within 300ms and SHALL NOT apply a per-tile
stagger by default.

#### Scenario: Repeated use
- **WHEN** a user switches between matrix and strata repeatedly while comparing
- **THEN** each switch completes fast enough not to delay the comparison

#### Scenario: Reduced motion
- **WHEN** the user prefers reduced motion
- **THEN** positional interpolation, stagger and any camera-like movement are all disabled, and the two-up comparison view becomes the default means of moving between layouts

### Requirement: Two-up comparison carries the orthogonality argument

The interface SHALL provide a two-up comparison view showing the matrix and the
stratum bands simultaneously, as a first-class feature for all users.

#### Scenario: Understanding orthogonality without motion
- **WHEN** a user selects an element in the two-up view
- **THEN** it is highlighted in both arrangements at once and a static connector is drawn between its two positions

### Requirement: The contested register is a titled panel, not a pull-out

Contested entries SHALL be presented in a separately framed and explicitly
titled register outside the matrix, and SHALL NOT imitate the visual grammar of
a chemical periodic table's pulled-out series.

#### Scenario: The register is announced
- **WHEN** a user reaches the contested register in any reading order
- **THEN** it is announced as a labelled section stating that its entries are not usable in a formula without a note

#### Scenario: Position as the only encoding
- **WHEN** an entry's contested status is conveyed solely by its position outside the matrix
- **THEN** that is a defect, because separation is imperceptible to a screen-reader user and to anyone magnified past one region
