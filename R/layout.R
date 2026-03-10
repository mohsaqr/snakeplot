#' Compute serpentine (snake) layout geometry
#'
#' Calculates band positions, arc geometry, and canvas dimensions for
#' the boustrophedon layout shared by all snake plot types.
#'
#' @param n_bands Integer, number of bands.
#' @param band_height Numeric, height (or width for vertical) of each band.
#' @param band_gap Numeric, gap between bands.
#' @param plot_width Numeric, length of the time axis.
#' @param margin Named numeric vector with top, right, bottom, left margins.
#' @param orientation Character, "horizontal" or "vertical".
#' @param start_from Character, "left" or "right". Controls which side
#'   the first band reads from.
#' @param flow Character, "snake" or "natural". Controls block/content
#'   ordering within bands. "snake" = boustrophedon (alternating
#'   direction); "natural" = all bands read in the same direction.
#' @return A list with components: bands, arcs, canvas, plot_area, orientation.
#' @noRd
compute_snake_layout <- function(n_bands, band_height = 28, band_gap = 18,
                                 plot_width = 500,
                                 margin = c(top = 30, right = 10,
                                            bottom = 50, left = 80),
                                 orientation = "horizontal",
                                 start_from = "left",
                                 flow = c("snake", "natural")) {
  flow <- match.arg(flow)
  stopifnot(n_bands >= 1L)

  row_step  <- band_height + band_gap
  outer_r   <- (row_step + band_height) / 2
  inner_r   <- band_gap / 2
  arc_pad   <- outer_r + 6

  if (orientation == "horizontal") {
    # Canvas dimensions
    canvas_w <- margin["left"] + arc_pad + plot_width + arc_pad + margin["right"]
    canvas_h <- margin["top"] + n_bands * band_height +
      max(0, n_bands - 1L) * band_gap + margin["bottom"]

    # Plot area
    x_left  <- margin["left"] + arc_pad
    x_right <- x_left + plot_width

    # Band positions
    bands <- data.frame(
      i        = seq_len(n_bands) - 1L,
      y_center = margin["top"] + (seq_len(n_bands) - 1L) * row_step +
        band_height / 2,
      stringsAsFactors = FALSE
    )
    bands$y_top    <- bands$y_center - band_height / 2
    bands$y_bottom <- bands$y_center + band_height / 2
    bands$x_left   <- x_left
    bands$x_right  <- x_right

    # Directions: start_from controls first band direction
    if (start_from == "left") {
      bands$direction <- ifelse(bands$i %% 2 == 0, "ltr", "rtl")
    } else {
      bands$direction <- ifelse(bands$i %% 2 == 0, "rtl", "ltr")
    }

    # Read direction: "snake" = boustrophedon (follows fold),
    # "natural" = all same direction (natural reading order)
    if (flow == "snake") {
      bands$read_direction <- bands$direction
    } else {
      bands$read_direction <- if (start_from == "left") "ltr" else "rtl"
    }

    # Arc geometry
    arcs <- if (n_bands > 1L) {
      lapply(seq_len(n_bands - 1L), function(k) {
        i <- k
        # Arc side depends on which end band k finishes at
        dir_k <- bands$direction[k]
        side <- if (dir_k == "ltr") "right" else "left"
        cx <- if (side == "right") x_right else x_left
        cy <- (bands$y_center[i] + bands$y_center[i + 1L]) / 2
        pts <- arc_polygon(cx, cy, outer_r, inner_r, side)
        list(
          from = i - 1L, to = i, side = side,
          cx = cx, cy = cy, outer_r = outer_r, inner_r = inner_r,
          tip_x = if (side == "right") cx + outer_r else cx - outer_r,
          tip_y = cy, pts = pts
        )
      })
    } else {
      list()
    }

    plot_area <- list(x_left = unname(x_left), x_right = unname(x_right))

  } else {
    # Vertical: bands are columns, time runs top-to-bottom
    col_step <- band_height + band_gap

    canvas_w <- margin["left"] + n_bands * band_height +
      max(0, n_bands - 1L) * band_gap + margin["right"]
    canvas_h <- margin["top"] + arc_pad + plot_width + arc_pad + margin["bottom"]

    y_top    <- margin["top"] + arc_pad
    y_bottom <- y_top + plot_width

    bands <- data.frame(
      i = seq_len(n_bands) - 1L,
      stringsAsFactors = FALSE
    )
    x_centers <- margin["left"] + bands$i * col_step + band_height / 2
    bands$x_left   <- x_centers - band_height / 2
    bands$x_right  <- x_centers + band_height / 2
    bands$x_center <- x_centers
    bands$y_top    <- y_top
    bands$y_bottom <- y_bottom
    bands$y_center <- (y_top + y_bottom) / 2

    if (start_from == "left") {
      bands$direction <- ifelse(bands$i %% 2 == 0, "ttb", "btt")
    } else {
      bands$direction <- ifelse(bands$i %% 2 == 0, "btt", "ttb")
    }

    if (flow == "snake") {
      bands$read_direction <- bands$direction
    } else {
      bands$read_direction <- if (start_from == "left") "ttb" else "btt"
    }

    # Arcs: horizontal semicircles at top/bottom
    arcs <- if (n_bands > 1L) {
      lapply(seq_len(n_bands - 1L), function(k) {
        dir_k <- bands$direction[k]
        side <- if (dir_k == "ttb") "bottom" else "top"
        cy <- if (side == "bottom") y_bottom else y_top
        cx <- (bands$x_center[k] + bands$x_center[k + 1L]) / 2
        pts <- arc_polygon(cx, cy, outer_r, inner_r, side)
        list(
          from = k - 1L, to = k, side = side,
          cx = cx, cy = cy, outer_r = outer_r, inner_r = inner_r,
          tip_x = cx,
          tip_y = if (side == "bottom") cy + outer_r else cy - outer_r,
          pts = pts
        )
      })
    } else {
      list()
    }

    plot_area <- list(y_top = unname(y_top), y_bottom = unname(y_bottom))
  }

  structure(
    list(
      bands       = bands,
      arcs        = arcs,
      canvas      = list(width = unname(canvas_w), height = unname(canvas_h)),
      plot_area   = plot_area,
      orientation = orientation,
      flow        = flow,
      params      = list(band_height = band_height, band_gap = band_gap,
                         plot_width = plot_width, margin = margin,
                         outer_r = outer_r, inner_r = inner_r,
                         arc_pad = arc_pad)
    ),
    class = "snake_layout"
  )
}

#' Compute polygon coordinates for a half-annulus arc
#'
#' @param cx,cy Numeric, center of the arc.
#' @param outer_r Numeric, outer radius.
#' @param inner_r Numeric, inner radius.
#' @param side Character: "right", "left", "top", or "bottom".
#' @param n_pts Integer, number of points per semicircle.
#' @return List with x, y numeric vectors forming a closed polygon.
#' @noRd
arc_polygon <- function(cx, cy, outer_r, inner_r, side = "right",
                        n_pts = 50L) {
  if (side %in% c("right", "left")) {
    theta <- seq(-pi / 2, pi / 2, length.out = n_pts)
    sign_x <- if (side == "right") 1 else -1
    outer_x <- cx + sign_x * outer_r * cos(theta)
    outer_y <- cy + outer_r * sin(theta)
    inner_x <- cx + sign_x * inner_r * cos(rev(theta))
    inner_y <- cy + inner_r * sin(rev(theta))
  } else {
    # top/bottom: horizontal semicircles
    sign_y <- if (side == "bottom") 1 else -1
    theta <- seq(-pi / 2, pi / 2, length.out = n_pts)
    outer_x <- cx + outer_r * sin(theta)
    outer_y <- cy + sign_y * outer_r * cos(theta)
    inner_x <- cx + inner_r * sin(rev(theta))
    inner_y <- cy + sign_y * inner_r * cos(rev(theta))
  }
  list(x = c(outer_x, inner_x), y = c(outer_y, inner_y))
}

#' Compute polygon coordinates for one half of a half-annulus arc
#'
#' Splits the arc at the midpoint (theta = 0). For horizontal arcs (right/left),
#' "upper" gives the half closer to the upper band, "lower" the half closer to
#' the lower band. For vertical arcs (top/bottom), "upper" gives the from-band
#' half, "lower" the to-band half.
#'
#' @param cx,cy Numeric, center of the arc.
#' @param outer_r Numeric, outer radius.
#' @param inner_r Numeric, inner radius.
#' @param side Character: "right", "left", "top", or "bottom".
#' @param half Character: "upper" or "lower".
#' @param n_pts Integer, number of points per quarter-circle.
#' @return List with x, y numeric vectors forming a closed polygon.
#' @noRd
half_arc_polygon <- function(cx, cy, outer_r, inner_r, side = "right",
                             half = "upper", n_pts = 25L) {
  theta <- if (half == "upper") {
    seq(-pi / 2, 0, length.out = n_pts)
  } else {
    seq(0, pi / 2, length.out = n_pts)
  }

  if (side %in% c("right", "left")) {
    sign_x <- if (side == "right") 1 else -1
    outer_x <- cx + sign_x * outer_r * cos(theta)
    outer_y <- cy + outer_r * sin(theta)
    inner_x <- cx + sign_x * inner_r * cos(rev(theta))
    inner_y <- cy + inner_r * sin(rev(theta))
  } else {
    sign_y <- if (side == "bottom") 1 else -1
    outer_x <- cx + outer_r * sin(theta)
    outer_y <- cy + sign_y * outer_r * cos(theta)
    inner_x <- cx + inner_r * sin(rev(theta))
    inner_y <- cy + sign_y * inner_r * cos(rev(theta))
  }
  list(x = c(outer_x, inner_x), y = c(outer_y, inner_y))
}

#' Compute polygon coordinates for an annular sector (wedge)
#'
#' Draws a slice of a half-annulus between two theta angles.
#' Used by \code{sequence_snake} to render colored blocks inside arcs.
#'
#' @param cx,cy Numeric, center of the arc.
#' @param outer_r Numeric, outer radius.
#' @param inner_r Numeric, inner radius.
#' @param theta1,theta2 Numeric, start and end angles in radians
#'   (within the -pi/2 to pi/2 range).
#' @param side Character: "right", "left", "top", or "bottom".
#' @param n_pts Integer, number of points per arc edge.
#' @return List with x, y numeric vectors forming a closed polygon.
#' @noRd
arc_sector_polygon <- function(cx, cy, outer_r, inner_r, theta1, theta2,
                                side = "right", n_pts = 20L) {
  theta <- seq(theta1, theta2, length.out = n_pts)
  if (side %in% c("right", "left")) {
    sign_x <- if (side == "right") 1 else -1
    outer_x <- cx + sign_x * outer_r * cos(theta)
    outer_y <- cy + outer_r * sin(theta)
    inner_x <- cx + sign_x * inner_r * cos(rev(theta))
    inner_y <- cy + inner_r * sin(rev(theta))
  } else {
    sign_y <- if (side == "bottom") 1 else -1
    outer_x <- cx + outer_r * sin(theta)
    outer_y <- cy + sign_y * outer_r * cos(theta)
    inner_x <- cx + inner_r * sin(rev(theta))
    inner_y <- cy + sign_y * inner_r * cos(rev(theta))
  }
  list(x = c(outer_x, inner_x), y = c(outer_y, inner_y))
}

#' Compute polygon coordinates for a semicircular end cap
#'
#' @param x Numeric, x- or center coordinate of the band edge.
#' @param y Numeric, y-center or edge coordinate.
#' @param radius Numeric, half the band height.
#' @param side Character: "left", "right", "top", or "bottom".
#' @param n_pts Integer, number of points.
#' @return List with x, y numeric vectors.
#' @noRd
end_cap_polygon <- function(x, y, radius, side = "left", n_pts = 40L) {
  if (side %in% c("left", "right")) {
    theta <- seq(-pi / 2, pi / 2, length.out = n_pts)
    sign_x <- if (side == "left") -1 else 1
    list(
      x = x + sign_x * radius * cos(theta),
      y = y + radius * sin(theta)
    )
  } else {
    sign_y <- if (side == "top") -1 else 1
    theta <- seq(-pi / 2, pi / 2, length.out = n_pts)
    list(
      x = x + radius * sin(theta),
      y = y + sign_y * radius * cos(theta)
    )
  }
}
