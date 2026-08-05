module sqrtHarness {
  import sqrt.* from "./sqrt"
  var tick: int
  action init = { tick' = 0 }
  action step = { tick' = tick + 1 }
  val inv = sqrtOk
}
