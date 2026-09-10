import * as __compactRuntime from '@midnight-ntwrk/compact-runtime';
__compactRuntime.checkRuntimeVersion('0.16.0');

const _descriptor_0 = new __compactRuntime.CompactTypeUnsignedInteger(340282366920938463463374607431768211455n, 16);

const _descriptor_1 = new __compactRuntime.CompactTypeUnsignedInteger(18446744073709551615n, 8);

class _MulHint_0 {
  alignment() {
    return _descriptor_1.alignment().concat(_descriptor_1.alignment().concat(_descriptor_1.alignment().concat(_descriptor_1.alignment().concat(_descriptor_1.alignment().concat(_descriptor_1.alignment())))));
  }
  fromValue(value_0) {
    return {
      aLo: _descriptor_1.fromValue(value_0),
      aHi: _descriptor_1.fromValue(value_0),
      bLo: _descriptor_1.fromValue(value_0),
      bHi: _descriptor_1.fromValue(value_0),
      lo: _descriptor_1.fromValue(value_0),
      carry: _descriptor_1.fromValue(value_0)
    }
  }
  toValue(value_0) {
    return _descriptor_1.toValue(value_0.aLo).concat(_descriptor_1.toValue(value_0.aHi).concat(_descriptor_1.toValue(value_0.bLo).concat(_descriptor_1.toValue(value_0.bHi).concat(_descriptor_1.toValue(value_0.lo).concat(_descriptor_1.toValue(value_0.carry))))));
  }
}

const _descriptor_2 = new _MulHint_0();

const _descriptor_3 = __compactRuntime.CompactTypeBoolean;

const _descriptor_4 = new __compactRuntime.CompactTypeBytes(32);

class _Either_0 {
  alignment() {
    return _descriptor_3.alignment().concat(_descriptor_4.alignment().concat(_descriptor_4.alignment()));
  }
  fromValue(value_0) {
    return {
      is_left: _descriptor_3.fromValue(value_0),
      left: _descriptor_4.fromValue(value_0),
      right: _descriptor_4.fromValue(value_0)
    }
  }
  toValue(value_0) {
    return _descriptor_3.toValue(value_0.is_left).concat(_descriptor_4.toValue(value_0.left).concat(_descriptor_4.toValue(value_0.right)));
  }
}

const _descriptor_5 = new _Either_0();

class _ContractAddress_0 {
  alignment() {
    return _descriptor_4.alignment();
  }
  fromValue(value_0) {
    return {
      bytes: _descriptor_4.fromValue(value_0)
    }
  }
  toValue(value_0) {
    return _descriptor_4.toValue(value_0.bytes);
  }
}

const _descriptor_6 = new _ContractAddress_0();

const _descriptor_7 = new __compactRuntime.CompactTypeUnsignedInteger(255n, 1);

export class Contract {
  witnesses;
  constructor(...args_0) {
    if (args_0.length !== 1) {
      throw new __compactRuntime.CompactError(`Contract constructor: expected 1 argument, received ${args_0.length}`);
    }
    const witnesses_0 = args_0[0];
    if (typeof(witnesses_0) !== 'object') {
      throw new __compactRuntime.CompactError('first (witnesses) argument to Contract constructor is not an object');
    }
    this.witnesses = witnesses_0;
    this.circuits = {
      checkedAdd(context, ...args_1) {
        return { result: pureCircuits.checkedAdd(...args_1), context };
      },
      checkedSub(context, ...args_1) {
        return { result: pureCircuits.checkedSub(...args_1), context };
      },
      checkedMul(context, ...args_1) {
        return { result: pureCircuits.checkedMul(...args_1), context };
      },
      checkedDiv(context, ...args_1) {
        return { result: pureCircuits.checkedDiv(...args_1), context };
      }
    };
    this.impureCircuits = {};
    this.provableCircuits = {};
  }
  initialState(...args_0) {
    if (args_0.length !== 1) {
      throw new __compactRuntime.CompactError(`Contract state constructor: expected 1 argument (as invoked from Typescript), received ${args_0.length}`);
    }
    const constructorContext_0 = args_0[0];
    if (typeof(constructorContext_0) !== 'object') {
      throw new __compactRuntime.CompactError(`Contract state constructor: expected 'constructorContext' in argument 1 (as invoked from Typescript) to be an object`);
    }
    if (!('initialZswapLocalState' in constructorContext_0)) {
      throw new __compactRuntime.CompactError(`Contract state constructor: expected 'initialZswapLocalState' in argument 1 (as invoked from Typescript)`);
    }
    if (typeof(constructorContext_0.initialZswapLocalState) !== 'object') {
      throw new __compactRuntime.CompactError(`Contract state constructor: expected 'initialZswapLocalState' in argument 1 (as invoked from Typescript) to be an object`);
    }
    const state_0 = new __compactRuntime.ContractState();
    let stateValue_0 = __compactRuntime.StateValue.newArray();
    state_0.data = new __compactRuntime.ChargedState(stateValue_0);
    const context = __compactRuntime.createCircuitContext(__compactRuntime.dummyContractAddress(), constructorContext_0.initialZswapLocalState.coinPublicKey, state_0.data, constructorContext_0.initialPrivateState);
    const partialProofData = {
      input: { value: [], alignment: [] },
      output: undefined,
      publicTranscript: [],
      privateTranscriptOutputs: []
    };
    state_0.data = new __compactRuntime.ChargedState(context.currentQueryContext.state.state);
    return {
      currentContractState: state_0,
      currentPrivateState: context.currentPrivateState,
      currentZswapLocalState: context.currentZswapLocalState
    }
  }
  _checkedAdd_0(a_0, b_0) {
    return ((t1) => {
             if (t1 > 340282366920938463463374607431768211455n) {
               throw new __compactRuntime.CompactError('arithmetic.compact line 14 char 10: cast from Field or Uint value to smaller Uint value failed: ' + t1 + ' is greater than 340282366920938463463374607431768211455');
             }
             return t1;
           })(a_0 + b_0);
  }
  _checkedSub_0(a_0, b_0) {
    __compactRuntime.assert(a_0 >= b_0, 'UINT_UNDERFLOW');
    __compactRuntime.assert(a_0 >= b_0,
                            'result of subtraction would be negative');
    return a_0 - b_0;
  }
  _checkedMul_0(a_0, b_0, h_0) {
    __compactRuntime.assert(this._equal_0(a_0,
                                          h_0.aHi * 18446744073709551616n
                                          +
                                          h_0.aLo),
                            'MUL_A_SPLIT');
    __compactRuntime.assert(this._equal_1(b_0,
                                          h_0.bHi * 18446744073709551616n
                                          +
                                          h_0.bLo),
                            'MUL_B_SPLIT');
    __compactRuntime.assert(this._equal_2(h_0.aLo * h_0.bLo,
                                          h_0.carry * 18446744073709551616n
                                          +
                                          h_0.lo),
                            'MUL_PRODUCT_SPLIT');
    __compactRuntime.assert(this._equal_3(h_0.aHi * h_0.bHi, 0n),
                            'UINT_OVERFLOW_HIGH');
    const middle_0 = h_0.aLo * h_0.bHi + h_0.aHi * h_0.bLo + h_0.carry;
    __compactRuntime.assert(middle_0 < 18446744073709551616n,
                            'UINT_OVERFLOW_MIDDLE');
    return ((t1) => {
             if (t1 > 340282366920938463463374607431768211455n) {
               throw new __compactRuntime.CompactError('arithmetic.compact line 29 char 10: cast from Field or Uint value to smaller Uint value failed: ' + t1 + ' is greater than 340282366920938463463374607431768211455');
             }
             return t1;
           })(middle_0 * 18446744073709551616n + h_0.lo);
  }
  _checkedDiv_0(n_0, d_0, q_0, r_0, h_0) {
    __compactRuntime.assert(d_0 > 0n, 'DIVISION_BY_ZERO');
    __compactRuntime.assert(r_0 < d_0, 'DIVISION_REMAINDER');
    __compactRuntime.assert(this._equal_4(this._checkedAdd_0(this._checkedMul_0(d_0,
                                                                                q_0,
                                                                                h_0),
                                                             r_0),
                                          n_0),
                            'DIVISION_EQUATION');
    return q_0;
  }
  _equal_0(x0, y0) {
    if (x0 !== y0) { return false; }
    return true;
  }
  _equal_1(x0, y0) {
    if (x0 !== y0) { return false; }
    return true;
  }
  _equal_2(x0, y0) {
    if (x0 !== y0) { return false; }
    return true;
  }
  _equal_3(x0, y0) {
    if (x0 !== y0) { return false; }
    return true;
  }
  _equal_4(x0, y0) {
    if (x0 !== y0) { return false; }
    return true;
  }
}
export function ledger(stateOrChargedState) {
  const state = stateOrChargedState instanceof __compactRuntime.StateValue ? stateOrChargedState : stateOrChargedState.state;
  const chargedState = stateOrChargedState instanceof __compactRuntime.StateValue ? new __compactRuntime.ChargedState(stateOrChargedState) : stateOrChargedState;
  const context = {
    currentQueryContext: new __compactRuntime.QueryContext(chargedState, __compactRuntime.dummyContractAddress()),
    costModel: __compactRuntime.CostModel.initialCostModel()
  };
  const partialProofData = {
    input: { value: [], alignment: [] },
    output: undefined,
    publicTranscript: [],
    privateTranscriptOutputs: []
  };
  return {
  };
}
const _emptyContext = {
  currentQueryContext: new __compactRuntime.QueryContext(new __compactRuntime.ContractState().data, __compactRuntime.dummyContractAddress())
};
const _dummyContract = new Contract({ });
export const pureCircuits = {
  checkedAdd: (...args_0) => {
    if (args_0.length !== 2) {
      throw new __compactRuntime.CompactError(`checkedAdd: expected 2 arguments (as invoked from Typescript), received ${args_0.length}`);
    }
    const a_0 = args_0[0];
    const b_0 = args_0[1];
    if (!(typeof(a_0) === 'bigint' && a_0 >= 0n && a_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedAdd',
                                 'argument 1',
                                 'arithmetic.compact line 13 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 a_0)
    }
    if (!(typeof(b_0) === 'bigint' && b_0 >= 0n && b_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedAdd',
                                 'argument 2',
                                 'arithmetic.compact line 13 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 b_0)
    }
    return _dummyContract._checkedAdd_0(a_0, b_0);
  },
  checkedSub: (...args_0) => {
    if (args_0.length !== 2) {
      throw new __compactRuntime.CompactError(`checkedSub: expected 2 arguments (as invoked from Typescript), received ${args_0.length}`);
    }
    const a_0 = args_0[0];
    const b_0 = args_0[1];
    if (!(typeof(a_0) === 'bigint' && a_0 >= 0n && a_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedSub',
                                 'argument 1',
                                 'arithmetic.compact line 17 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 a_0)
    }
    if (!(typeof(b_0) === 'bigint' && b_0 >= 0n && b_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedSub',
                                 'argument 2',
                                 'arithmetic.compact line 17 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 b_0)
    }
    return _dummyContract._checkedSub_0(a_0, b_0);
  },
  checkedMul: (...args_0) => {
    if (args_0.length !== 3) {
      throw new __compactRuntime.CompactError(`checkedMul: expected 3 arguments (as invoked from Typescript), received ${args_0.length}`);
    }
    const a_0 = args_0[0];
    const b_0 = args_0[1];
    const h_0 = args_0[2];
    if (!(typeof(a_0) === 'bigint' && a_0 >= 0n && a_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedMul',
                                 'argument 1',
                                 'arithmetic.compact line 22 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 a_0)
    }
    if (!(typeof(b_0) === 'bigint' && b_0 >= 0n && b_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedMul',
                                 'argument 2',
                                 'arithmetic.compact line 22 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 b_0)
    }
    if (!(typeof(h_0) === 'object' && typeof(h_0.aLo) === 'bigint' && h_0.aLo >= 0n && h_0.aLo <= 18446744073709551615n && typeof(h_0.aHi) === 'bigint' && h_0.aHi >= 0n && h_0.aHi <= 18446744073709551615n && typeof(h_0.bLo) === 'bigint' && h_0.bLo >= 0n && h_0.bLo <= 18446744073709551615n && typeof(h_0.bHi) === 'bigint' && h_0.bHi >= 0n && h_0.bHi <= 18446744073709551615n && typeof(h_0.lo) === 'bigint' && h_0.lo >= 0n && h_0.lo <= 18446744073709551615n && typeof(h_0.carry) === 'bigint' && h_0.carry >= 0n && h_0.carry <= 18446744073709551615n)) {
      __compactRuntime.typeError('checkedMul',
                                 'argument 3',
                                 'arithmetic.compact line 22 char 1',
                                 'struct MulHint<aLo: Uint<0..18446744073709551616>, aHi: Uint<0..18446744073709551616>, bLo: Uint<0..18446744073709551616>, bHi: Uint<0..18446744073709551616>, lo: Uint<0..18446744073709551616>, carry: Uint<0..18446744073709551616>>',
                                 h_0)
    }
    return _dummyContract._checkedMul_0(a_0, b_0, h_0);
  },
  checkedDiv: (...args_0) => {
    if (args_0.length !== 5) {
      throw new __compactRuntime.CompactError(`checkedDiv: expected 5 arguments (as invoked from Typescript), received ${args_0.length}`);
    }
    const n_0 = args_0[0];
    const d_0 = args_0[1];
    const q_0 = args_0[2];
    const r_0 = args_0[3];
    const h_0 = args_0[4];
    if (!(typeof(n_0) === 'bigint' && n_0 >= 0n && n_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedDiv',
                                 'argument 1',
                                 'arithmetic.compact line 32 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 n_0)
    }
    if (!(typeof(d_0) === 'bigint' && d_0 >= 0n && d_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedDiv',
                                 'argument 2',
                                 'arithmetic.compact line 32 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 d_0)
    }
    if (!(typeof(q_0) === 'bigint' && q_0 >= 0n && q_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedDiv',
                                 'argument 3',
                                 'arithmetic.compact line 32 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 q_0)
    }
    if (!(typeof(r_0) === 'bigint' && r_0 >= 0n && r_0 <= 340282366920938463463374607431768211455n)) {
      __compactRuntime.typeError('checkedDiv',
                                 'argument 4',
                                 'arithmetic.compact line 32 char 1',
                                 'Uint<0..340282366920938463463374607431768211456>',
                                 r_0)
    }
    if (!(typeof(h_0) === 'object' && typeof(h_0.aLo) === 'bigint' && h_0.aLo >= 0n && h_0.aLo <= 18446744073709551615n && typeof(h_0.aHi) === 'bigint' && h_0.aHi >= 0n && h_0.aHi <= 18446744073709551615n && typeof(h_0.bLo) === 'bigint' && h_0.bLo >= 0n && h_0.bLo <= 18446744073709551615n && typeof(h_0.bHi) === 'bigint' && h_0.bHi >= 0n && h_0.bHi <= 18446744073709551615n && typeof(h_0.lo) === 'bigint' && h_0.lo >= 0n && h_0.lo <= 18446744073709551615n && typeof(h_0.carry) === 'bigint' && h_0.carry >= 0n && h_0.carry <= 18446744073709551615n)) {
      __compactRuntime.typeError('checkedDiv',
                                 'argument 5',
                                 'arithmetic.compact line 32 char 1',
                                 'struct MulHint<aLo: Uint<0..18446744073709551616>, aHi: Uint<0..18446744073709551616>, bLo: Uint<0..18446744073709551616>, bHi: Uint<0..18446744073709551616>, lo: Uint<0..18446744073709551616>, carry: Uint<0..18446744073709551616>>',
                                 h_0)
    }
    return _dummyContract._checkedDiv_0(n_0, d_0, q_0, r_0, h_0);
  }
};
export const contractReferenceLocations =
  { tag: 'publicLedgerArray', indices: { } };
//# sourceMappingURL=index.js.map
