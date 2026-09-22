test_that("G-theory slow validation requires an explicit affirmative value", {
  expect_true(mfrmr_gtheory_slow_enabled("1"))
  expect_true(mfrmr_gtheory_slow_enabled(" TRUE "))
  expect_true(mfrmr_gtheory_slow_enabled("yes"))
  expect_false(mfrmr_gtheory_slow_enabled(""))
  expect_false(mfrmr_gtheory_slow_enabled("false"))
  expect_false(mfrmr_gtheory_slow_enabled("0"))
})
