test_that("returns the correct linting", {
  linter <- commas_linter()
  msg_after <- rex::rex("Commas should always have a space after.")
  msg_before <- rex::rex("Commas should never have a space before.")

  expect_lint("blah", NULL, linter)
  expect_lint("fun(1, 1)", NULL, linter)
  expect_lint("fun(1,\n  1)", NULL, linter)
  expect_lint("fun(1,\n1)", NULL, linter)
  expect_lint("fun(1\n,\n1)", NULL, linter)
  expect_lint("fun(1\n  ,\n1)", NULL, linter)

  expect_lint("fun(1\n,1)", msg_after, linter)
  expect_lint("fun(1,1)", msg_after, linter)
  expect_lint("\nfun(1,1)", msg_after, linter)
  expect_lint(
    "fun(1 ,1)",
    list(
      msg_before,
      msg_after
    ),
    linter
  )

  expect_lint("\"fun(1 ,1)\"", NULL, linter)
  expect_lint("a[1, , 2]", NULL, linter)
  expect_lint("a[1, , 2, , 3]", NULL, linter)

  expect_lint("switch(op, x = foo, y = bar)", NULL, linter)
  expect_lint("switch(op, x = , y = bar)", NULL, linter)
  expect_lint("switch(op, \"x\" = , y = bar)", NULL, linter)
  expect_lint("switch(op, x = ,\ny = bar)", NULL, linter)

  expect_lint("switch(op, x = foo , y = bar)", msg_before, linter)
  expect_lint("switch(op, x = foo , y = bar)", msg_before, linter)
  expect_lint("switch(op , x = foo, y = bar)", msg_before, linter)
  expect_lint("switch(op, x = foo, y = bar(a = 4 , b = 5))", msg_before, linter)
  expect_lint("fun(op, x = foo , y = switch(bar, a = 4, b = 5))", msg_before, linter)

  expect_lint(
    "fun(op    ,bar)",
    list(
      list(message = msg_before, column_number = 7L, ranges = list(c(7L, 10L))),
      list(message = msg_after, column_number = 12L, ranges = list(c(12L, 12L)))
    ),
    linter
  )
})
