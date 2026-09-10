import type * as __compactRuntime from '@midnight-ntwrk/compact-runtime';

export type MulHint = { aLo: bigint;
                        aHi: bigint;
                        bLo: bigint;
                        bHi: bigint;
                        lo: bigint;
                        carry: bigint
                      };

export type Witnesses<PS> = {
}

export type ImpureCircuits<PS> = {
}

export type ProvableCircuits<PS> = {
}

export type PureCircuits = {
  checkedAdd(a_0: bigint, b_0: bigint): bigint;
  checkedSub(a_0: bigint, b_0: bigint): bigint;
  checkedMul(a_0: bigint, b_0: bigint, h_0: MulHint): bigint;
  checkedDiv(n_0: bigint, d_0: bigint, q_0: bigint, r_0: bigint, h_0: MulHint): bigint;
}

export type Circuits<PS> = {
  checkedAdd(context: __compactRuntime.CircuitContext<PS>,
             a_0: bigint,
             b_0: bigint): __compactRuntime.CircuitResults<PS, bigint>;
  checkedSub(context: __compactRuntime.CircuitContext<PS>,
             a_0: bigint,
             b_0: bigint): __compactRuntime.CircuitResults<PS, bigint>;
  checkedMul(context: __compactRuntime.CircuitContext<PS>,
             a_0: bigint,
             b_0: bigint,
             h_0: MulHint): __compactRuntime.CircuitResults<PS, bigint>;
  checkedDiv(context: __compactRuntime.CircuitContext<PS>,
             n_0: bigint,
             d_0: bigint,
             q_0: bigint,
             r_0: bigint,
             h_0: MulHint): __compactRuntime.CircuitResults<PS, bigint>;
}

export type Ledger = {
}

export type ContractReferenceLocations = any;

export declare const contractReferenceLocations : ContractReferenceLocations;

export declare class Contract<PS = any, W extends Witnesses<PS> = Witnesses<PS>> {
  witnesses: W;
  circuits: Circuits<PS>;
  impureCircuits: ImpureCircuits<PS>;
  provableCircuits: ProvableCircuits<PS>;
  constructor(witnesses: W);
  initialState(context: __compactRuntime.ConstructorContext<PS>): __compactRuntime.ConstructorResult<PS>;
}

export declare function ledger(state: __compactRuntime.StateValue | __compactRuntime.ChargedState): Ledger;
export declare const pureCircuits: PureCircuits;
