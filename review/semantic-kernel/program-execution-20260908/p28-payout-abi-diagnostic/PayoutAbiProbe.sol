// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.2;

import "@etherisc/gif-interface/contracts/components/Product.sol";
import "@etherisc/gif-contracts/contracts/services/ProductService.sol";
import "@etherisc/gif-contracts/contracts/flows/PolicyDefaultFlow.sol";

// Diagnostic mocks provide only the external dependencies of the exact source path.
// They do not implement custody, claim eligibility, registered-component governance,
// or real policy/treasury/pool accounting.
contract AbiRegistryMock {
    mapping(bytes32 => address) private targets;
    function set(bytes32 name, address target) external { targets[name] = target; }
    function getContract(bytes32 name) external view returns (address) { return targets[name]; }
}
contract AbiLicenseMock {
    address private flow;
    bool private allowed;
    constructor(address f, bool a) { flow = f; allowed = a; }
    function getAuthorizationStatus(address) external view returns (uint256, bool, address) {
        return (17, allowed, flow);
    }
}
contract AbiComponentMock {
    function getComponentId(address) external pure returns (uint256) { return 17; }
}
contract AbiPolicyMock {
    uint256 public calls;
    uint256 private product;
    constructor(uint256 p) { product = p; }
    function getMetadata(bytes32) external view returns (IPolicy.Metadata memory m) {
        m.productId = product;
    }
    function processPayout(bytes32, uint256) external { calls += 1; }
}
contract AbiTreasuryMock {
    uint256 public calls;
    function processPayout(bytes32, uint256) external returns (uint256, uint256) {
        calls += 1;
        return (7, 93);
    }
}
contract AbiPoolMock {
    uint256 public calls;
    uint256 public amount;
    function processPayout(bytes32, uint256 a) external { calls += 1; amount = a; }
}
contract AbiProductProbe is Product {
    constructor(address registry) Product("ABI probe", address(0), "PolicyDefaultFlow", 0, registry) {}
    function getApplicationDataStructure() external pure override returns (string memory) { return ""; }
    function getClaimDataStructure() external pure override returns (string memory) { return ""; }
    function getPayoutDataStructure() external pure override returns (string memory) { return ""; }
    function riskPoolCapacityCallback(uint256) external override {}
    function exposedPayout(bytes32 id, uint256 payout) external returns (uint256, uint256) {
        return _processPayout(id, payout);
    }
    function ignoredPayout(bytes32 id, uint256 payout) external returns (uint256) {
        _processPayout(id, payout);
        return 42;
    }
}
contract PayoutAbiProbe {
    // Each evm run begins from fresh local state. Actual pinned constructors deploy
    // ProductService/PolicyDefaultFlow and a subclass using the unchanged Product.
    function probe(uint256 scenario) external returns (uint256[8] memory observed) {
        require(scenario <= 4, "diagnostic scenario");
        AbiRegistryMock registry = new AbiRegistryMock();
        PolicyDefaultFlow flow = new PolicyDefaultFlow(address(registry));
        ProductService service = new ProductService(address(registry));
        AbiPolicyMock policy = new AbiPolicyMock(scenario == 4 ? 18 : 17);
        AbiTreasuryMock treasury = new AbiTreasuryMock();
        AbiPoolMock pool = new AbiPoolMock();
        registry.set("PolicyDefaultFlow", address(flow));
        registry.set("ProductService", address(service));
        registry.set("License", address(new AbiLicenseMock(address(flow), scenario != 3)));
        registry.set("Component", address(new AbiComponentMock()));
        registry.set("Policy", address(policy));
        registry.set("Treasury", address(treasury));
        registry.set("Pool", address(pool));
        AbiProductProbe product = new AbiProductProbe(address(registry));
        if (scenario == 0) {
            (bool ok, bytes memory raw) = address(service).call(abi.encodeWithSignature("processPayout(bytes32,uint256)", bytes32(uint256(1)), 2));
            require(ok, "raw service call failed");
            (bool success, uint256 fee, uint256 net) = abi.decode(raw, (bool, uint256, uint256));
            observed[0] = success ? 1 : 0;
            observed[1] = fee;
            observed[2] = net;
            observed[3] = raw.length;
        } else if (scenario == 1) {
            (observed[0], observed[1]) = product.exposedPayout(bytes32(uint256(1)), 2);
            observed[3] = 64;
        } else if (scenario == 2) {
            observed[0] = product.ignoredPayout(bytes32(uint256(1)), 2);
        } else {
            (bool ok, bytes memory raw) = address(product).call(abi.encodeWithSignature("exposedPayout(bytes32,uint256)", bytes32(uint256(1)), 2));
            bytes memory expected = abi.encodeWithSignature("Error(string)", scenario == 3 ? "ERROR:PRS-001:NOT_AUTHORIZED" : "ERROR:PFD-004:PROCESSID_PRODUCT_MISMATCH");
            require(!ok && keccak256(raw) == keccak256(expected), "wrong refusal");
            observed[0] = 1; // exact source refusal observed; not a successful payout
        }
        observed[4] = treasury.calls();
        observed[5] = policy.calls();
        observed[6] = pool.calls();
        observed[7] = pool.amount();
    }
}
