# Calendar dates of date-times. as.Date() on a POSIXct converts through UTC,
# so local midnight east of UTC fell on the previous day: timeline_snake()
# labelled a phase starting 2016-10 as "Sep 2016" in Europe/Helsinki.

with_tz <- function(tz, code) {
  old <- Sys.getenv("TZ", unset = NA)
  Sys.setenv(TZ = tz)
  on.exit(if (is.na(old)) Sys.unsetenv("TZ") else Sys.setenv(TZ = old),
          add = TRUE)
  code
}

describe(".local_date()", {

  it("keeps the calendar date of the date-time's own time zone", {
    east <- as.POSIXct("2016-10-01 00:00:00", tz = "Europe/Helsinki")
    west <- as.POSIXct("2016-10-01 23:30:00", tz = "America/New_York")
    expect_equal(.local_date(east), as.Date("2016-10-01"))
    expect_equal(.local_date(west), as.Date("2016-10-01"))
  })

  it("uses the session time zone for date-times without one", {
    res <- with_tz("Europe/Helsinki", {
      .local_date(as.POSIXct("2016-10-01 00:30:00"))
    })
    expect_equal(res, as.Date("2016-10-01"))
  })

  it("gives the parsed month start for YYYY-MM input east of UTC", {
    res <- with_tz("Europe/Helsinki", {
      .local_date(parse_time(c("2015-01-01", "2016-10-01", "2024-12-01")))
    })
    expect_equal(res, as.Date(c("2015-01-01", "2016-10-01", "2024-12-01")))
  })

  it("preserves length and NA", {
    x <- as.POSIXct(c("2020-02-29 12:00:00", NA), tz = "UTC")
    expect_equal(.local_date(x), as.Date(c("2020-02-29", NA)))
  })

  it("rejects non date-time input", {
    expect_error(.local_date("2020-01-01"), "POSIXt")
  })
})
