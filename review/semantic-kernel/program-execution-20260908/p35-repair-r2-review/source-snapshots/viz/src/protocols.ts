/* Real protocols, decomposed. Selecting one projects it onto the table —
   this is how you learn to read the table, and how you use it to think. */

export interface Protocol {
  id: string;
  name: string;
  kind: string;
  dead?: boolean;
  syms: string[];              // elements, in the order they become necessary
  formula: string;
  reading: string;             // plain English: what this protocol IS
  build?: { sym: string; why: string }[];   // why each part had to arrive
  residue: string;             // what the formula could not express
  broke?: {                    // for the ones that died
    what: string;
    hazard: string;
    loss: string;
    cycle?: string[];          // reflexive loop, if that is the shape
  };
}

export const PROTOCOLS: Protocol[] = [
  {
    id: "aave",
    name: "Aave v3",
    kind: "Pooled lending",
    syms: ["Pl", "Ix", "Ct", "Ex", "Li", "Bs", "Im", "Up", "Tg", "Gp"],
    formula: "Pl + Ix + Ct + Ex{push} + Li{partial} + Bs + Im{isolation} + Up + Tg + Gp",
    reading:
      "Many lenders share one pool; interest accrues through a global index; a solvency test priced by an external oracle decides who is underwater; third parties are paid to close those positions; staked capital covers what liquidation misses.",
    build: [
      { sym: "Pl", why: "Start here. Many lenders, one pool, many borrowers. On its own it just holds value." },
      { sym: "Ix", why: "Interest must accrue for thousands of accounts without touching thousands of accounts. One global index does it." },
      { sym: "Ct", why: "The moment borrowing exists, a position can be worth less than its debt. This was forced, not chosen." },
      { sym: "Ex", why: "The solvency test needs a price, and the price lives off-chain. First dependency the protocol does not control." },
      { sym: "Li", why: "A failed test is only a number until somebody is paid to act on it." },
      { sym: "Bs", why: "In a fast crash liquidation may not recover the debt. Slashable capital absorbs the rest." },
      { sym: "Im", why: "A thin, volatile asset endangers everyone in a shared pool. Give it its own fence." },
      { sym: "Up", why: "Code needs fixing." },
      { sym: "Tg", why: "But not instantly — a delay lets people see the change coming." },
      { sym: "Gp", why: "And something has to be able to stop it. Three separate elements, three separate ways to fail." },
    ],
    residue: "e-mode correlation assumptions, supply and borrow caps, asset adapters.",
  },
  {
    id: "uniswapv3",
    name: "Uniswap v3",
    kind: "Spot exchange",
    syms: ["Sh", "Cl", "Tp", "Fl"],
    formula: "Sh + Cl{feeTier,tickSpacing} + Tp + Fl*",
    reading:
      "Liquidity providers hold shares in a pool that prices trades from its own inventory, but only across a range each provider chooses. A cumulative price series is exposed for others to read as an oracle.",
    residue: "NFT position-manager behaviour, exact tick math.",
  },
  {
    id: "maker",
    name: "Maker / Sky",
    kind: "CDP stablecoin",
    syms: ["Cd", "Ix", "Ct", "Ex", "Li", "Ps", "Sh", "Up", "Tg", "Gp"],
    formula: "Cd + Ix + Ct + Ex + Li{auction} + Ps + Sh{DSR} + Up + Tg + Gp",
    reading:
      "Lock collateral, mint a liability against it. The same solvency test and liquidation machinery as a lending market, plus a peg-swap module that trades the stablecoin one-for-one against reserves.",
    residue: "surplus and bad-debt auctions, real-world-asset legal structure.",
  },
  {
    id: "liquity",
    name: "Liquity v1",
    kind: "CDP stablecoin",
    syms: ["Cd", "Ct", "Ex", "Li", "Rd", "Bs"],
    formula: "Cd + Ct + Ex + Li + Rd + Bs{stability-pool}",
    reading:
      "The same shape as Maker with the governance removed. A hard redemption right does the work that governance does elsewhere, and depositors pre-commit capital to absorb liquidations.",
    residue: "recovery mode, redistribution ordering, fee dynamics.",
  },
  {
    id: "gmx",
    name: "GMX v2",
    kind: "Perpetual futures",
    syms: ["Sh", "Pm", "Ex", "Pf", "Ct", "Li", "Bs", "Sl"],
    formula: "Sh + Pm + Ex + Pf + Ct + Li + Bs? + Sl?",
    reading:
      "A pool takes the other side of every trade. Funding payments tether the perpetual to an index price, the same solvency test constrains leverage, and losses that exceed the buffers are allocated to the pool.",
    residue: "price-impact curve, keeper network, market-specific accounting.",
  },
  {
    id: "lido",
    name: "Lido v2",
    kind: "Liquid staking",
    syms: ["Rb", "Ex", "Wq", "Up", "Gp"],
    formula: "Rb + Ex{oracle-quorum} + Wq + Up + Gp",
    reading:
      "Staked ether is represented by a token whose balance rebases as rewards are reported by an oracle committee. Exits are not instant, so they become queued claims.",
    residue: "The entire staking mechanism — delegation, validator activation and exit, penalty attribution — has no element. This is why Vl was added as a candidate.",
  },
  {
    id: "cow",
    name: "CoW Protocol",
    kind: "Intent exchange",
    syms: ["In", "Ba", "Ag", "Rf"],
    formula: "In + Ba + Ag + Rf?  —n→ solvers [adverse_selection]",
    reading:
      "Users sign what outcome they want rather than a route. Competing solvers find the route, and orders clear together in a batch at a uniform price.",
    residue: "solver scoring, off-chain order-flow policy, competition concentration.",
  },
  {
    id: "cctp",
    name: "CCTP v2 Fast",
    kind: "Cross-domain transfer",
    syms: ["Au", "Xm", "Xf", "Of"],
    formula: "Au{issuer-mint} + Xm{native-consensus} + Xf{burn-mint} + Of",
    reading:
      "Burn on one chain, mint on another, authorised by the issuer. The fast path advances the destination funds before the source is final — which is a loan, and the formula has to say so.",
    residue: "fast-transfer allowance pricing, issuer balance sheet.",
  },
  {
    id: "centrifuge",
    name: "Centrifuge",
    kind: "Real-world credit",
    syms: ["Uc", "Ft", "Tr", "Sh", "At", "Aw", "Wq", "Xm"],
    formula: "Uc + Ft + Tr + Sh + At + Aw + Wq + Xm?",
    reading:
      "Permissioned investors fund term credit against off-chain assets, split into senior and junior claims, valued by a reported NAV, redeemed asynchronously.",
    residue: "Legal ownership, servicing, bankruptcy remoteness and court enforcement are all outside the formula. For this protocol the residue is larger than the formula.",
  },
  {
    id: "terra",
    name: "Terra / Anchor",
    kind: "Algorithmic stablecoin",
    dead: true,
    syms: ["As", "Rd", "Ex", "Pl", "Ix", "Em"],
    formula: "As + Rd{LUNA-conversion} + Ex + Pl + Ix + Em↺",
    reading:
      "Anyone could burn a dollar of LUNA to mint one UST, or the reverse. Arbitrage was supposed to hold the peg, and a lending market paid about 19.5% to hold the result.",
    build: [
      { sym: "As", why: "The peg mechanism: mint and burn against a second token." },
      { sym: "Rd", why: "The conversion right itself. A legitimate element, alive in protocols today." },
      { sym: "Ex", why: "The conversion needs to know what a dollar is worth." },
      { sym: "Pl", why: "Anchor: an ordinary pooled lending market. Same element as Aave." },
      { sym: "Ix", why: "With ordinary index accrual." },
      { sym: "Em", why: "The 19.5% was not earned. It was subsidised with newly issued tokens." },
    ],
    residue: "confidence, exchange depth, cross-chain flows, validator halt decisions.",
    broke: {
      what:
        "Every element here is legitimate and appears in systems that did not collapse. The defect is a bond: UST's backing was LUNA, and LUNA's value came from demand for UST. When UST slipped below a dollar the mechanism minted LUNA to buy it back — which made LUNA cheaper, which thinned the backing, which pushed UST further down.",
      hazard: "X1",
      loss: "LUNA supply went from 343 million to 6.5 trillion in a week. Roughly $40B erased in about three days.",
      cycle: ["UST below $1", "burn UST, mint LUNA", "LUNA supply rises", "LUNA price falls", "backing thins"],
    },
  },
  {
    id: "mango",
    name: "Mango Markets",
    kind: "Perpetual futures",
    dead: true,
    syms: ["Ob", "Pf", "Pl", "Ct", "Ex", "Li"],
    formula: "Ob + Pf + Pl + Ct + Ex + Li  ↺own-token-collateral",
    reading:
      "An on-chain order book with perpetuals and lending sharing one margin account.",
    residue: "cross-venue price formation, self-trading behaviour.",
    broke: {
      what:
        "Same shape, smaller. The collateral was the protocol's own token, and the price feed read that token's own thin market. Buy the token on a market you can move, and your borrowing power rises with it.",
      hazard: "X2",
      loss: "Approximately $116M drained in October 2022.",
    },
  },
  {
    id: "euler",
    name: "Euler v1",
    kind: "Pooled lending",
    dead: true,
    syms: ["Pl", "Ix", "Ct", "Ex", "Li", "Fl", "Up"],
    formula: "Pl + Ix + Ct + Ex + Li + Fl* + Up",
    reading:
      "An ordinary lending market with permissionless market creation and atomic leverage.",
    residue: "the defective transition itself — implementation residue, not a recurring element.",
    broke: {
      what:
        "Nothing in this formula is wrong. A newly added function omitted a health check. The table cannot see this class of failure at all: every element was correct and correctly combined.",
      hazard: "",
      loss: "Approximately $197M in March 2023 — nearly all of it returned.",
    },
  },
];

/** The method. Six questions, each with a verdict attached. */
export const HOWTO = [
  {
    n: "1",
    q: "What are its parts?",
    body: "Name every recurring financial state transition and refuse everything else. ERC-4626 is a socket, not a mechanism. A hook is somewhere to put an element, not an element. “Points” is marketing. Most whitepapers describe three real mechanisms and forty pages of scenery.",
  },
  {
    n: "2",
    q: "What did each part force?",
    body: "Parts are not chosen freely — each one drags in the next. Leverage forces a truth source, a solvency test and a way for the position to end. A protocol with leverage and only two of those three is not innovating. It is missing a part, and you have just found it.",
  },
  {
    n: "3",
    q: "Where does it read the outside world?",
    body: "This is the question that pays. Every catastrophic loss this table explains runs through the price, not the code. Ask what it would cost to move that input — measured against pool depth, never against the attacker’s balance — and if the answer is less than what can be borrowed against it, the protocol is already lost.",
  },
  {
    n: "4",
    q: "Does anything feed itself?",
    body: "Reflexive collateral is the most reliable way to lose everything ever deployed on-chain. A token that is simultaneously the collateral, the market that prices it, and the capital backing it has three defences that all fail on the same news. This is the one shape that goes to zero rather than merely down.",
  },
  {
    n: "5",
    q: "Who eats the loss?",
    body: "For every fee, delay, slippage and advance, name the claim class or the underwriter. An unassigned loss has not vanished — somebody is carrying it without being paid to, and usually it is the depositor who never read this far. If the documentation cannot name them, that is the answer.",
  },
  {
    n: "6",
    q: "What did the formula fail to say?",
    body: "The residue, and it is the most useful line on the page. For a lending market it is small. For anything touching real-world assets it is larger than the formula and contains the actual risk. A decomposition that reports no residue was not finished.",
  },
];
