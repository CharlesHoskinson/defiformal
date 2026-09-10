import DefiKernel.Vault.Examples

open DefiKernel.Vault
open DefiKernel.Vault.Examples

def formatRow (id : String) (res : Except DefiKernel.Vault.Failure (Ledger × DefiKernel.Arithmetic.Word 256)) : String :=
  match res with
  | .ok (st, w) =>
    s!"{id} status=ok value={w.value} initialized=true chi={st.chi.value} ssr={st.ssr.value} rho={st.rho} timestamp={st.timestamp} susds_totalSupply={st.totalSupply.value} susds_balance_S={st.susds .S} susds_balance_R={st.susds .R} susds_balance_O={st.susds .O} susds_balance_P={st.susds .P} susds_allowance_O_P={st.susdsAllow .O .P} usds_totalSupply={st.usdsSupply} usds_balance_S={st.usds .S} usds_balance_R={st.usds .R} usds_balance_O={st.usds .O} usds_balance_P={st.usds .P} usds_balance_vault={st.usds .vault} usds_allowance_S_vault={st.usdsAllow .S .vault} usds_allowance_O_vault={st.usdsAllow .O .vault}"
  | .error e => s!"{id} status=error failure={DefiKernel.Vault.sourceLabel e}"

def main : IO UInt32 := do
  let dep0 := deposit fundedDeposit wad .R .S
  let mint0 := mint fundedDeposit wad .R .S
  let red0 := redeem fundedRedeem wad .R .O .O
  let wd0 := withdraw fundedRedeem wad .R .O .O
  let dep1 := deposit fundedDepositD1 wad .R .S
  let mint1 := mint fundedMintD1 wad .R .S
  let red1 := redeem fundedRedeemD1 wad .R .O .O
  let wd1 := withdraw fundedRedeemD1 wad .R .O .O
  let zero := deposit emptyLedger ⟨0, Nat.succ_pos _⟩ .R .S
  let bad := deposit fundedDeposit wad .zero .S
  let self := deposit fundedDeposit wad .vault .S
  let tfBal := deposit emptyLedger wad .R .S
  let tfAllow := deposit { emptyLedger with
    usds := fun a => if a = .S then WAD else 0
    usdsSupply := WAD } wad .R .S
  let redBal := redeem emptyLedger ⟨1, by decide⟩ .R .O .O
  let redAllow := redeem fundedRedeem wad .R .O .P
  let ovf := deposit emptyLedger ovfAssets .R .S
  let del := redeem fundedDelegated wad .R .O .P

  let rows := [
    formatRow "P17-DEP-D0" dep0,
    formatRow "P17-MINT-D0" mint0,
    formatRow "P17-RED-D0" red0,
    formatRow "P17-WD-D0" wd0,
    formatRow "P17-DEP-D1" dep1,
    formatRow "P17-MINT-D1" mint1,
    formatRow "P17-RED-D1" red1,
    formatRow "P17-WD-D1" wd1,
    formatRow "P17-DEP-ZERO" zero,
    formatRow "P17-DEP-BAD-RECV" bad,
    formatRow "P17-DEP-SELF" self,
    formatRow "P17-DEP-TF-BAL" tfBal,
    formatRow "P17-DEP-TF-ALLOW" tfAllow,
    formatRow "P17-RED-BAL" redBal,
    formatRow "P17-RED-ALLOW" redAllow,
    formatRow "P17-DEP-MUL-OVF" ovf,
    formatRow "P17-RED-DELEGATED" del
  ]
  for line in rows do
    IO.println line
  return 0

#eval main
