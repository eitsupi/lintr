test_that("spaces_inside_linter skips allowed usages", {
  linter <- spaces_inside_linter()

  expect_lint("blah", NULL, linter)
  expect_lint("print(blah)", NULL, linter)
  expect_lint("base::print(blah)", NULL, linter)
  expect_lint("a[, ]", NULL, linter)
  expect_lint("a[1]", NULL, linter)
  expect_lint("fun(\na[1]\n  )", NULL, linter)
  expect_lint("a(, )", NULL, linter)
  expect_lint("a(,)", NULL, linter)
  expect_lint("a(1)", NULL, linter)
  expect_lint('"a( 1 )"', NULL, linter)

  # trailing comments are OK (#636)
  expect_lint(
    trim_some("
      or( #code
        x, y
      )
    "),
    NULL,
    linter
  )

  expect_lint(
    trim_some("
      fun(      # this is another comment
        a = 42, # because 42 is always the answer
        b = Inf
      )
    "),
    NULL,
    linter
  )
})

test_that("spaces_inside_linter blocks diallowed usages", {
  linter <- spaces_inside_linter()

  expect_lint(
    "a[1 ]",
    list(
      message = "Do not place spaces before square brackets",
      line_number = 1L,
      column_number = 4L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "a[[1 ]]",
    list(
      message = "Do not place spaces before square brackets",
      line_number = 1L,
      column_number = 5L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "\n\na[ 1]",
    list(
      message = "Do not place spaces after square brackets",
      line_number = 3L,
      column_number = 3L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "a[ 1 ]",
    list(
      list(
        message = "Do not place spaces after square brackets",
        line_number = 1L,
        column_number = 3L,
        type = "style"
      ),
      list(
        message = "Do not place spaces before square brackets",
        line_number = 1L,
        column_number = 5L,
        type = "style"
      )
    ),
    linter
  )

  expect_lint(
    "a(1 )",
    list(
      message = "Do not place spaces before parentheses",
      line_number = 1L,
      column_number = 4L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "a[[ 1]]",
    list(
      message = "Do not place spaces after square brackets",
      line_number = 1L,
      column_number = 4L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "a( 1)",
    list(
      message = "Do not place spaces after parentheses",
      line_number = 1L,
      column_number = 3L,
      type = "style"
    ),
    linter
  )

  expect_lint(
    "x[[ 1L ]]",
    list(
      list(
        message = "Do not place spaces after square brackets",
        line_number = 1L,
        column_number = 4L,
        type = "style"
      ),
      list(
        message = "Do not place spaces before square brackets",
        line_number = 1L,
        column_number = 7L,
        type = "style"
      )
    ),
    linter
  )

  expect_lint(
    "a( 1 )",
    list(
      list(
        message = "Do not place spaces after parentheses",
        line_number = 1L,
        column_number = 3L,
        type = "style"
      ),
      list(
        message = "Do not place spaces before parentheses",
        line_number = 1L,
        column_number = 5L,
        type = "style"
      )
    ),
    linter
  )

  # range covers all whitespace
  expect_lint(
    "a(  blah  )",
    list(
      list(
        message = "Do not place spaces after parentheses",
        line_number = 1L,
        column_number = 3L,
        ranges = list(c(3L, 4L)),
        type = "style"
      ),
      list(
        message = "Do not place spaces before parentheses",
        line_number = 1L,
        column_number = 9L,
        ranges = list(c(9L, 10L)),
        type = "style"
      )
    ),
    linter
  )
})

test_that("mutli-line expressions have good markers", {
  expect_lint(
    trim_some("
      ( x |
        y )
    "),
    list(
      list(line_number = 1L, ranges = list(c(2L, 2L)), message = "Do not place spaces after parentheses"),
      list(line_number = 2L, ranges = list(c(4L, 4L)), message = "Do not place spaces before parentheses")
    ),
    spaces_inside_linter()
  )
})

test_that("spaces_inside_linter blocks disallowed usages with a pipe", {
  skip_if_not_r_version("4.1.0")

  linter <- spaces_inside_linter()

  expect_lint(
    "letters[1:3] %>% paste0( )",
    list(
      list(
        message = "Do not place spaces after parentheses",
        line_number = 1L,
        column_number = 25L,
        type = "style"
      ),
      list(
        message = "Do not place spaces before parentheses",
        line_number = 1L,
        column_number = 25L,
        type = "style"
      )
    ),
    linter
  )

  expect_lint(
    "letters[1:3] |> paste0( )",
    list(
      list(
        message = "Do not place spaces after parentheses",
        line_number = 1L,
        column_number = 24L,
        type = "style"
      ),
      list(
        message = "Do not place spaces before parentheses",
        line_number = 1L,
        column_number = 24L,
        type = "style"
      )
    ),
    linter
  )
})

test_that("terminal missing keyword arguments are OK", {
  expect_lint("alist(missing_arg = )", NULL, spaces_inside_linter())
})
