# Snake Plot Family — Specification for R Package Implementation

## Overview

The “snake plot” family is a set of survey and activity visualizations
that use a **serpentine (boustrophedon) layout**: horizontal bands that
alternate direction row-by-row, connected by U-turn arcs at alternating
edges. This creates a continuous, flowing ribbon that the eye follows
naturally from top to bottom.

There are **9 plot types** total in the survey visualization suite.
Three of them use the snake/serpentine layout:

| Plot                    | Layout               | Data Input                     | Purpose                                                                                                    |
|-------------------------|----------------------|--------------------------------|------------------------------------------------------------------------------------------------------------|
| Survey Snake            | Serpentine bands     | Likert survey responses        | Show response distributions as tick marks on a flowing ribbon, with inter-item correlations at the U-turns |
| Survey Sequence         | Serpentine bands     | Likert survey responses        | 100% stacked color segments on a flowing ribbon, one band per item                                         |
| Sequential Distribution | Serpentine bands     | Likert survey responses        | Like Survey Sequence but with sequential (monochrome) coloring instead of diverging                        |
| **Activity Snake**      | **Serpentine bands** | **Timestamped events per day** | **Timeline of daily activity — each band is one day, events are colored ticks on a dark ribbon**           |

The other 5 (Survey Bar, Heatmap, Dot Strip, Cumulative, Rug) use
standard non-serpentine layouts and are not covered here.

------------------------------------------------------------------------

## 1. Survey Snake (`renderSurveySnake`)

### What it shows

Each survey item is a horizontal band. The band’s body is shaded by mean
response (warm = low, cool = high). Individual responses are shown as
tick marks (lines or dots) positioned along the band at their response
level. Mean and median markers sit on top. At each U-turn, the
correlation between adjacent items is displayed as a tinted arc.

### Data input

    SurveyData {
      items: [{ label: "Q1 text", counts: [n1, n2, n3, n4, n5] }, ...]
      levels: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]
      testResult?: { formatted: "χ²(4) = 12.3, p = .015" }  // optional subtitle
    }

- `items[i].counts` — frequency counts for each response level (length
  must match `levels`)
- `levels` — ordered from most negative to most positive

### Layout

      ┌─────────────────────────────────────┐
      │ Q1 ████████████████████████████████ │──┐
      │    |  | || |   |  ||  | |  ||| |   │  │ ← ticks
      └─────────────────────────────────────┘  │
                                        r=.72  ╰──┐  ← correlation at U-turn
      ┌─────────────────────────────────────┐  ╭──╯
      │ ████████████████████████████████ Q2 │──┘
      │  || | |   ||  |  | | ||  |  |  |   │
      └─────────────────────────────────────┘
      ╭──╮                                     ← U-turn on left side
      │  │  r=.45
      ╰──╯
      ┌─────────────────────────────────────┐
      │ Q3 ████████████████████████████████ │
      ...

- Odd rows (0, 2, 4…) read left→right
- Even rows (1, 3, 5…) read right→left
- U-turns alternate sides: right after row 0, left after row 1, etc.
- Correlation arc color: positive correlation = warm tint, negative =
  cool tint

### Key config options

| Option            | Type                        | Default   | Description                                            |
|-------------------|-----------------------------|-----------|--------------------------------------------------------|
| `bandHeight`      | number                      | 32        | Band height in px                                      |
| `bandGap`         | number                      | 34        | Gap between bands (space for labels)                   |
| `tickShape`       | `'line' \| 'dot'`           | `'line'`  | Shape of individual response marks                     |
| `tickOpacity`     | number                      | 0.55      | Opacity of tick marks                                  |
| `colorMode`       | `'level' \| 'individual'`   | `'level'` | Color ticks by response level or unique per respondent |
| `shadeByMean`     | boolean                     | true      | Shade band body by item mean (warm→cool)               |
| `showMean`        | boolean                     | true      | Diamond marker at mean position                        |
| `showMedian`      | boolean                     | false     | Vertical line at median position                       |
| `showCorrelation` | boolean                     | true      | Show Pearson r at U-turns                              |
| `foldTintOpacity` | number                      | 0.25      | Opacity of correlation color overlay on arcs           |
| `jitterRange`     | number                      | 0.22      | Vertical jitter as fraction of level spacing           |
| `sortBy`          | `'none' \| 'mean' \| 'net'` | `'none'`  | Sort items by mean or net score                        |
| `showLegend`      | boolean                     | true      | Show legend below plot                                 |

### Tick mark positioning

- The x-axis spans the response levels (1 to K)
- Each tick is placed at its response level (e.g., level 3 = center for
  5-point)
- Jitter is applied vertically (within the band height) to avoid overlap
- For `colorMode='level'`, ticks are colored by the diverging palette
- For `colorMode='individual'`, each respondent gets a unique hue

------------------------------------------------------------------------

## 2. Survey Sequence (`renderSurveySequence`)

### What it shows

Each survey item is a 100% stacked horizontal bar (like a stacked bar
chart), but arranged in the serpentine layout with U-turn arcs
connecting them. Each color segment represents a response level.
Percentages are shown inside segments when they are wide enough.

### Data input

Same `SurveyData` as Survey Snake.

### Layout

      ┌──────────────────────────────────────┐
      │ Q1 [SD 8%][D 15%][N 22%][A 35%][SA 20%] │──╮
      └──────────────────────────────────────┘    │
                                             ╭────╯  ← gradient arc blending adjacent colors
      ┌──────────────────────────────────────┐╯
      │ [SA 25%][A 30%][N 20%][D 18%][SD 7%] Q2 │
      └──────────────────────────────────────┘
      ╭─╮
      │ │ ← arc on left
      ╰─╯
      ┌──────────────────────────────────────┐
      │ Q3 [SD 5%][D 12%]...                │
      ...

- Each band is a 100% stacked bar divided into colored segments
- Even rows are reversed (right-to-left) so colors flow continuously
  through the arcs
- Arcs blend the end color of one band into the start color of the next
  (`arcMode: 'gradient'`) or use a neutral gray (`arcMode: 'neutral'`)

### Key config options

| Option            | Type                        | Default           | Description                                |
|-------------------|-----------------------------|-------------------|--------------------------------------------|
| `bandHeight`      | number                      | 28                | Band height in px                          |
| `bandGap`         | number                      | 14                | Gap between bands                          |
| `colors`          | string\[\]                  | diverging palette | One color per response level               |
| `showPercentages` | boolean                     | true              | Show % inside segments                     |
| `minSegmentPx`    | number                      | 34                | Hide % label if segment narrower than this |
| `arcMode`         | `'gradient' \| 'neutral'`   | `'gradient'`      | Arc coloring strategy                      |
| `arcOpacity`      | number                      | 0.5               | Arc opacity                                |
| `showLegend`      | boolean                     | true              | Show legend below                          |
| `sortBy`          | `'none' \| 'net' \| 'mean'` | `'none'`          | Sort items                                 |
| `shadowSize`      | number                      | 4                 | Drop shadow blur                           |

------------------------------------------------------------------------

## 3. Sequential Distribution (`renderSequentialDist`)

### What it shows

Identical layout to Survey Sequence, but uses a **sequential
(monochrome) palette** instead of diverging colors. Good for ordinal
scales where there is no natural midpoint (e.g., frequency: “Never”,
“Rarely”, “Sometimes”, “Often”, “Always”).

### Data input

Same `SurveyData`.

### Key differences from Survey Sequence

- `colorScheme: 'sequential'` (default) uses a single-hue ramp from
  light to dark
- `hue` option (0–360) controls the base color (default 210 = blue)
- Can also be set to `colorScheme: 'diverging'` to use the standard
  diverging palette
- `colors` array overrides the scheme entirely
- Arc opacity defaults to 0.85 (higher than Sequence’s 0.5)

------------------------------------------------------------------------

## 4. Activity Snake (`renderActivitySnake`) — THE MAIN ONE

### What it shows

A daily activity timeline where **each band is one day** and **colored
ticks/blocks on the dark ribbon represent events**. The serpentine
layout connects days via U-turn arcs (representing overnight/sleep
transitions). Hour gridlines and labels provide time reference.

This is fundamentally different from the survey snake plots: instead of
Likert response data, it takes **timestamped events**.

### Data input

    ActivityDay {
      label: string          // "Mon", "Tuesday", "2024-01-15", "Day 1", etc.
      events: ActivityEvent[]
    }

    ActivityEvent {
      start: number       // Start time in MINUTES FROM MIDNIGHT (0–1440)
      duration: number    // Duration in minutes (0 = rug tick / point event)
      label?: string      // Optional event label (shown in tooltip)
    }

**Time convention**: All times are in minutes from midnight. - 0 = 12:00
AM (midnight) - 360 = 6:00 AM - 720 = 12:00 PM (noon) - 1080 = 6:00 PM -
1440 = 12:00 AM (next midnight)

**Two event modes**: 1. **Duration blocks** (`duration > 0`): Event
width is proportional to duration. Good for screen time, work sessions,
exercise periods. 2. **Rug ticks** (`duration = 0`): Thin vertical ticks
at the event timestamp. Good for point events like messages, landings,
heartbeats. Set `minTickWidth: 1.5` for thin rug style.

### Layout

      dayStart (6AM)                    dayEnd (midnight)
      ┌─────────────────────────────────────┐
      │ Mon  ██dark██ ▐evt▌ ██ ▐evt▌ ██████ │──╮
      └─────────────────────────────────────┘  │
                                        12AM   ╰──╮  ← overnight arc, "12AM" label at tip
      ┌─────────────────────────────────────┐  ╭──╯
      │ ██████ ▐evt▌ ██ ▐▐▐ ██████████ Tue │──┘
      └─────────────────────────────────────┘
      ╭──╮
      │  │ 12AM
      ╰──╯
      ┌─────────────────────────────────────┐
      │ Wed  ████████ ▐evt▌ ████ ▐evt▌ ██  │
      ...

      Legend: [■ Timeline] [■ Screen time]

- **Dark bands** = the day timeline ribbon (configurable color)
- **Colored ticks/blocks** = events on top of the dark band
- **Arcs** = overnight transitions with “12AM” label at the arc tip
- **Hour gridlines** = white vertical lines at each hour across all
  bands
- **Labels** = day names in the gap area (first day above its band, rest
  between bands)
- **Day total** = optional total duration shown after the label (e.g.,
  “Mon 2h 15m”)

### Use cases and data patterns

#### Weekly view (7 days)

``` r
days <- list(
  list(label = "Mon", events = list(
    list(start = 420, duration = 30),   # 7:00 AM, 30 min
    list(start = 720, duration = 60),   # 12:00 PM, 1 hour
    list(start = 1260, duration = 90)   # 9:00 PM, 1.5 hours
  )),
  list(label = "Tue", events = list(...)),
  ...
)
```

#### Monthly view (28–31 days)

Same structure, just more days. Use smaller `bandHeight` (12–14) and
`bandGap` (8–10) and `labelFontSize` (9–10) for compact display.

#### Multi-week view (4 separate plots)

For a month split into weeks: create 4 separate activity snake plots,
each with 7 days. Display them in a 2×2 grid or vertically stacked.

#### By factor/group

Split data by a factor (e.g., weekday vs weekend, treatment vs control)
and render separate activity snakes for each group for comparison.

#### Rug ticks (point events)

Set all `duration = 0` and use `minTickWidth: 1.5`. Good for: - Server
request logs - Message timestamps - Heartbeat / sensor events - Airport
landings

### Full config reference

| Option           | Type                                 | Default                    | Description                                        |
|------------------|--------------------------------------|----------------------------|----------------------------------------------------|
| **General**      |                                      |                            |                                                    |
| `title`          | string                               | —                          | Plot title                                         |
| `caption`        | string                               | —                          | Caption below plot                                 |
| `width`          | number                               | container width            | SVG width                                          |
| `height`         | number                               | auto-computed              | SVG height                                         |
| **Layout**       |                                      |                            |                                                    |
| `bandHeight`     | number                               | 28                         | Height of each day band in px                      |
| `bandGap`        | number                               | 18                         | Gap between bands (arc space)                      |
| `dayStart`       | number                               | 360                        | Day start time in minutes (360 = 6AM)              |
| `dayEnd`         | number                               | 1440                       | Day end time in minutes (1440 = midnight)          |
| `showHourGrid`   | boolean                              | true                       | White vertical gridlines at each hour              |
| `showTotal`      | boolean                              | true                       | Show total duration after day label                |
| `labelAlign`     | `'left' \| 'center' \| 'right'`      | `'left'`                   | Day label alignment                                |
| `labelFontSize`  | number                               | 13                         | Label font size                                    |
| `shadowSize`     | number                               | 5                          | Drop shadow blur radius                            |
| `minTickWidth`   | number                               | 2                          | Minimum event tick width in px (1.5 for rug style) |
| **Colors**       |                                      |                            |                                                    |
| `bandColor`      | `string \| string[]`                 | `'#3d2518'`                | Band ribbon color. Array = per-day (cycles).       |
| `bandOpacity`    | number                               | 0.85                       | Band opacity                                       |
| `arcColor`       | string                               | `'#1a1a2e'`                | Overnight arc color                                |
| `arcOpacity`     | number                               | 0.85                       | Arc opacity                                        |
| `eventColor`     | `string \| string[]`                 | `'#e09480'`                | Event tick color. Array = per-day (cycles).        |
| `eventOpacity`   | number                               | 0.8                        | Event tick opacity                                 |
| `shadowColor`    | string                               | `'#adb5bd'`                | Drop shadow color                                  |
| `shadowOpacity`  | number                               | 0.12                       | Drop shadow opacity                                |
| `labelColor`     | string                               | theme text                 | Day label color                                    |
| `gridColor`      | string                               | `'rgba(255,255,255,0.25)'` | Hour gridline color                                |
| `hourLabelColor` | string                               | theme muted                | Hour label color (“12AM” at arcs)                  |
| **Legend**       |                                      |                            |                                                    |
| `legend`         | `{ label: string, color: string }[]` | —                          | Legend items below plot                            |

### Per-day color arrays

Both `bandColor` and `eventColor` accept arrays for per-day coloring:

``` r
# 7 colors, one per day of week
eventColor = c("#e74c3c", "#e67e22", "#f1c40f", "#2ecc71", "#3498db", "#9b59b6", "#e91e63")

# Weekday/weekend contrast (cycles if fewer than days)
bandColor = c(rep("#2d2d3d", 5), rep("#1a3a3a", 2))  # 5 weekday + 2 weekend
eventColor = c(rep("#e09480", 5), rep("#00cec9", 2))
```

If the array is shorter than the number of days, it **cycles** (day
index modulo array length).

### Rendering algorithm (for implementer)

1.  **Compute layout**: `rowStep = bandHeight + bandGap`. Each day
    occupies one row. `turnRadius = rowStep / 2`. The turning pad on
    left and right = `turnRadius + bandHeight/2 + 8`.

2.  **Time-to-X mapping**: Linear mapping from `[dayStart, dayEnd]` to
    `[xLeft, xRight]`.

3.  **Draw shadow rectangles**: Semi-transparent rectangles behind each
    band for depth.

4.  **Draw bands and arcs**:

    - Each band is a `rect` at `(xLeft, y - bandH/2, plotWidth, bandH)`
      with the band color.
    - Each arc connects band `i` to band `i+1`. Odd-indexed arcs go
      right, even go left.
    - Arc shape: semicircular path from one band’s edge to the next
      band’s edge.
    - “12AM” label at the arc tip (the outermost point of the
      semicircle).

5.  **Draw hour gridlines**: Vertical white lines at each whole hour
    across all bands.

6.  **Draw event ticks**: For each day, for each event:

    - Convert `event.start` to x position via time-to-X mapping
    - Width = `max(minTickWidth, (duration / daySpan) * plotWidth)`
    - Clamp to stay within `[xLeft, xRight]`
    - Draw colored rectangle on top of the dark band

7.  **Draw labels**: Day labels in the gap between bands. First day’s
    label goes above its band.

8.  **Draw legend**: Colored swatches with labels below the plot area.

### Tooltip behavior

- Hovering over an event tick shows: Day label, Time range (start –
  end), Duration (e.g., “1h 30m”), Activity label (if provided)
- Event tick brightens to full opacity on hover

------------------------------------------------------------------------

## Design Principles (for all snake plots)

1.  **Boustrophedon flow**: Odd rows left→right, even rows right→left.
    The U-turn arcs create visual continuity.

2.  **Dark-on-light for Activity Snake**: The bands are dark (like a
    film strip), events are light/colored ticks on top. This makes the
    activity “pop” against the timeline.

3.  **Light-on-dark for Survey Snake**: Band body has a gradient shading
    by mean. Tick marks and markers sit on top.

4.  **Proportional representation**: In all snake types, position or
    width encodes the data value (response level, time, duration).

5.  **Serpentine reading order**: Labels, percentages, and data all
    respect the alternating direction. Even rows in Survey Sequence have
    reversed segment order so colors flow continuously through arcs.

6.  **Minimal chrome**: Light gridlines, subtle shadows, clean
    typography. The data should dominate.

------------------------------------------------------------------------

## R Package Implementation Notes

### Recommended approach

- Use **grid** graphics (not base R) for the complex path/arc rendering,
  or **ggplot2 + custom geoms**
- The serpentine layout is custom — no existing ggplot2 geom does this
- Consider a `geom_snake()` or standalone `snake_plot()` function

### Key R data structures

``` r
# For Activity Snake
activity_data <- data.frame(
  day = c("Mon", "Mon", "Mon", "Tue", "Tue", ...),
  start = c(420, 720, 1260, 450, 780, ...),        # minutes from midnight
  duration = c(30, 60, 90, 15, 45, ...),            # minutes (0 for rug)
  label = c("Email", "Lunch", "Netflix", ...)        # optional
)

# OR as a list of lists (closer to the JS API)
activity_days <- list(
  list(label = "Mon", events = data.frame(start = c(420, 720), duration = c(30, 60))),
  list(label = "Tue", events = data.frame(start = c(450, 780), duration = c(15, 45))),
  ...
)

# For Survey Snake / Sequence / Sequential Dist
survey_data <- list(
  items = data.frame(
    label = c("Q1: I enjoy...", "Q2: The course...", ...),
    # counts as a matrix: rows = items, cols = levels
  ),
  counts = matrix(c(5, 12, 20, 35, 28,    # Q1
                     3,  8, 15, 40, 34,    # Q2
                     ...), nrow = n_items, byrow = TRUE),
  levels = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
)
```

### Arc rendering

The U-turn arcs are semicircular SVG paths. In R/grid, use
[`grid::curveGrob()`](https://rdrr.io/r/grid/grid.curve.html) or
construct the arc manually with
[`grid::xsplineGrob()`](https://rdrr.io/r/grid/grid.xspline.html). The
arc connects the right (or left) edge of one band to the right (or left)
edge of the next band, with the curve bulging outward.

### Color cycling

For per-day colors, use modular indexing:
`color_vec[(day_index - 1) %% length(color_vec) + 1]`

### Output format

- Primary: SVG (via `svglite` or `grid` with SVG device)
- Secondary: PNG at 300 DPI for publication
- Consider `htmlwidgets` for interactive version with tooltips
