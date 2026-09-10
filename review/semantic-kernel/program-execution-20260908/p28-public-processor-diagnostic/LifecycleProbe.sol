// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.2;
import "contracts/DepegProduct.sol";
import "@etherisc/gif-contracts/contracts/services/ProductService.sol";
import "@etherisc/gif-contracts/contracts/flows/PolicyDefaultFlow.sol";

// Root diagnostic fixtures. No real token, treasury, policy controller, riskpool,
// oracle, or license governance is implemented by these fixtures.
contract LifecycleRegistry {
    mapping(bytes32 => address) private targets;
    function set(bytes32 name, address a) external { targets[name] = a; }
    function getContract(bytes32 name) external view returns(address) { return targets[name]; }
}
contract LifecycleLicense {
    address private flow;
    constructor(address f) { flow = f; }
    function getAuthorizationStatus(address) external view returns(uint256,bool,address) {
        return (17,true,flow);
    }
}
contract LifecyclePrice {
    function getToken() external pure returns(address) { return address(0x123); }
    function getDecimals() external pure returns(uint8) { return 2; }
    function getDepeggedAt() external pure returns(uint256) { return 1; }
    function getDepeggedBlockNumber() external pure returns(uint256) { return 77; }
    function getDepegPriceInfo() public pure returns(IPriceDataProvider.PriceInfo memory p) {
        p.price = 80; p.depeggedAt = 1; p.eventType = IPriceDataProvider.EventType.DepegEvent;
    }
    function processLatestPriceInfo() external pure returns(IPriceDataProvider.PriceInfo memory) {
        return getDepegPriceInfo();
    }
}
contract LifecyclePool {
    uint256 public calls;
    uint256 public amount;
    uint256 public releases;
    function decodeApplicationParameterFromData(bytes memory data)
        external pure returns(address,uint256,uint256,uint256,uint256) {
        return abi.decode(data,(address,uint256,uint256,uint256,uint256));
    }
    function depegPriceIsBelowProtectedDepegPrice(uint256 price,uint256 target)
        external pure returns(bool) { return price < target / 2; }
    function getProtectedMinDepegPrice(uint256 target) external pure returns(uint256) { return target / 2; }
    function processPayout(bytes32,uint256 a) external { calls++; amount += a; }
    function release(bytes32) external { releases++; }
}
contract LifecyclePolicy {
    address private holder;
    address private pool;
    address private treasury;
    mapping(bytes32 => IPolicy.Policy) private policies;
    mapping(bytes32 => IPolicy.Claim) private claimsById;
    mapping(bytes32 => uint256) private payouts;
    uint256 public confirmations;
    uint256 public createdPayouts;
    uint256 public paid;
    constructor(address h,address p) { holder=h; pool=p; }
    function setTreasury(address t) external { treasury=t; }
    function getComponent(uint256) external view returns(address) { return pool; }
    function getTreasuryAddress() external view returns(address) { return treasury; }
    function getComponentId(address) external pure returns(uint256) { return 17; }
    function getMetadata(bytes32) external view returns(IPolicy.Metadata memory m) { m.owner=holder; m.productId=17; }
    function getApplication(bytes32) external view returns(IPolicy.Application memory a) {
        a.data=abi.encode(holder,uint256(100),uint256(1000),uint256(1),uint256(0));
        a.sumInsuredAmount=100;
    }
    function getPolicy(bytes32 id) external view returns(IPolicy.Policy memory p) { return policies[id]; }
    function getClaim(bytes32 id,uint256) external view returns(IPolicy.Claim memory) { return claimsById[id]; }
    function claims(bytes32 id) external view returns(uint256) { return policies[id].claimsCount; }
    function createClaim(bytes32 id,uint256 amount,bytes memory data) external returns(uint256) {
        policies[id].claimsCount++;
        claimsById[id]=IPolicy.Claim(IPolicy.ClaimState.Applied,amount,0,data,1,1);
        return 0;
    }
    function expirePolicy(bytes32 id) external { policies[id].state=IPolicy.PolicyState.Expired; }
    function closePolicy(bytes32 id) external { policies[id].state=IPolicy.PolicyState.Closed; }
    function confirmClaim(bytes32 id,uint256,uint256 amount) external {
        confirmations++; claimsById[id].state=IPolicy.ClaimState.Confirmed;
        claimsById[id].claimAmount=amount;
    }
    function createPayout(bytes32 id,uint256,uint256 amount,bytes memory) external returns(uint256) {
        createdPayouts++; payouts[id]=amount; return 0;
    }
    function payoutAmount(bytes32 id) external view returns(uint256) { return payouts[id]; }
    function processPayout(bytes32 id,uint256) external { paid += payouts[id]; }
}
contract LifecycleTreasury {
    LifecyclePolicy private policy;
    bool private fail;
    uint256 public calls;
    constructor(LifecyclePolicy p,bool f) { policy=p; fail=f; }
    function processPayout(bytes32 id,uint256) external returns(uint256,uint256) {
        calls++;
        require(!fail,"ROOT_FIXTURE:TREASURY_REFUSAL");
        return (0,policy.payoutAmount(id));
    }
}
contract LifecycleOtherActor {
    function create(DepegProduct p,bytes32 id) external { p.createDepegClaim(id); }
    function process(DepegProduct p,bytes32 id) external { p.processPolicy(id); }
    function attest(DepegProduct p,DepegProduct.DepegBalance[] memory b) external { p.addDepegBalances(b); }
}
contract LifecycleProbe {
    struct Setup {
        DepegProduct product;
        LifecyclePolicy policy;
        LifecyclePool pool;
        LifecycleTreasury treasury;
    }
    function setup(bool fail) private returns(Setup memory s) {
        LifecycleRegistry registry=new LifecycleRegistry();
        s.pool=new LifecyclePool();
        s.policy=new LifecyclePolicy(address(this),address(s.pool));
        s.treasury=new LifecycleTreasury(s.policy,fail);
        s.policy.setTreasury(address(s.treasury));
        PolicyDefaultFlow flow=new PolicyDefaultFlow(address(registry));
        ProductService service=new ProductService(address(registry));
        registry.set("PolicyDefaultFlow",address(flow));
        registry.set("ProductService",address(service));
        registry.set("InstanceService",address(s.policy));
        registry.set("License",address(new LifecycleLicense(address(flow))));
        registry.set("Component",address(this));
        registry.set("Policy",address(s.policy));
        registry.set("Treasury",address(s.treasury));
        registry.set("Pool",address(s.pool));
        s.product=new DepegProduct("ROOT diagnostic",address(new LifecyclePrice()),address(0x456),address(registry),1,address(0));
        s.product.setId(17);
        // Product ID assignment uses the actual Component guard; component registry is a fixture.
        registry.set("Component",address(s.policy));
        s.product.processLatestPriceInfo();
    }
    function attest(DepegProduct p,uint256 amount) private {
        DepegProduct.DepegBalance[] memory b=new DepegProduct.DepegBalance[](1);
        b[0]=DepegProduct.DepegBalance(address(this),77,amount);
        (uint256 good,uint256 bad)=p.addDepegBalances(b);
        require(good==1 && bad==0,"attestation fixture");
    }
    function expectFailure(bool ok,bytes memory raw,string memory message) private pure {
        require(!ok && keccak256(raw)==keccak256(abi.encodeWithSignature("Error(string)",message)),"wrong refusal");
    }
    // Every scenario uses a fresh local state. The actual DepegProduct, ProductService,
    // and PolicyDefaultFlow constructors and public functions execute unmodified.
    function probe(uint256 scenario) external returns(uint256[12] memory o) {
        require(scenario>=11 && scenario<=13,"new scenario only");
        Setup memory s=setup(scenario==7);
        bytes32 id=bytes32(uint256(1));
        if(scenario>=11) {
            LifecycleOtherActor actor=new LifecycleOtherActor();
            require(s.product.owner()==address(this) && address(actor)!=address(this),"distinct processor");
            // The mock application protects address(this); the actor is neither that wallet nor the owner.
            if(scenario!=13) s.product.createDepegClaim(id);
            if(scenario==11) {
                attest(s.product,150);
                actor.process(s.product,id);
            } else {
                (bool ok,bytes memory raw)=address(actor).call(abi.encodeWithSelector(actor.process.selector,s.product,id));
                expectFailure(ok,raw,scenario==12 ? "ERROR:DP-043:DEPEG_BALANCE_MISSING" : "ERROR:DP-042:NOT_IN_PROCESS_SET");
                o[0]=1;
            }
        } else if(scenario==3) {
            LifecycleOtherActor actor=new LifecycleOtherActor();
            (bool ok,bytes memory raw)=address(actor).call(abi.encodeWithSelector(actor.create.selector,s.product,id));
            expectFailure(ok,raw,"ERROR:PRD-002:NOT_INSURED_WALLET");
            o[0]=1;
        } else if(scenario==4) {
            (bool ok,bytes memory raw)=address(s.product).call(abi.encodeWithSelector(s.product.processPolicy.selector,id));
            expectFailure(ok,raw,"ERROR:DP-042:NOT_IN_PROCESS_SET"); o[0]=1;
        } else if(scenario==9) {
            LifecycleOtherActor actor=new LifecycleOtherActor();
            DepegProduct.DepegBalance[] memory b=new DepegProduct.DepegBalance[](1);
            b[0]=DepegProduct.DepegBalance(address(this),77,150);
            (bool ok,bytes memory raw)=address(actor).call(abi.encodeWithSelector(actor.attest.selector,s.product,b));
            expectFailure(ok,raw,"Ownable: caller is not the owner"); o[0]=1;
        } else if(scenario==10) {
            DepegProduct.DepegBalance[] memory b=new DepegProduct.DepegBalance[](3);
            b[0]=DepegProduct.DepegBalance(address(this),77,150);
            b[1]=DepegProduct.DepegBalance(address(0),77,200);
            b[2]=DepegProduct.DepegBalance(address(this),78,250);
            (uint256 good,uint256 bad)=s.product.addDepegBalances(b);
            require(good==1 && bad==2,"partial batch counts"); o[0]=102;
        } else {
            s.product.createDepegClaim(id);
            if(scenario!=1) attest(s.product,scenario==2 ? 0 : scenario==8 ? 100 : 150);
            if(scenario==0) { s.product.processPolicy(id); }
            else if(scenario==1 || scenario==2 || scenario==7) {
                (bool ok,bytes memory raw)=address(s.product).call(abi.encodeWithSelector(s.product.processPolicy.selector,id));
                expectFailure(ok,raw,scenario==1 ? "ERROR:DP-043:DEPEG_BALANCE_MISSING" : scenario==2 ? "ERROR:DP-044:DEPEG_BALANCE_ZERO" : "ROOT_FIXTURE:TREASURY_REFUSAL"); o[0]=1;
            } else {
                bytes32 second=bytes32(uint256(2)); s.product.createDepegClaim(second);
                if(scenario==8) {
                    bytes32[] memory ids=new bytes32[](2); ids[0]=id; ids[1]=second;
                    (bool ok,bytes memory raw)=address(s.product).call(abi.encodeWithSelector(s.product.processPolicies.selector,ids));
                    expectFailure(ok,raw,"ERROR:DP-045:PROTECTED_BALANCE_PROCESSED_ALREADY"); o[0]=1;
                } else {
                    s.product.processPolicy(id);
                    if(scenario==5) {
                        s.product.processPolicy(second);
                        bytes32 third=bytes32(uint256(3)); s.product.createDepegClaim(third);
                        (bool ok,bytes memory raw)=address(s.product).call(abi.encodeWithSelector(s.product.processPolicy.selector,third));
                        expectFailure(ok,raw,"ERROR:DP-045:PROTECTED_BALANCE_PROCESSED_ALREADY"); o[0]=1;
                    } else {
                        attest(s.product,50);
                        (bool ok,bytes memory raw)=address(s.product).call(abi.encodeWithSelector(s.product.processPolicy.selector,second));
                        require(!ok && keccak256(raw)==keccak256(abi.encodeWithSignature("Panic(uint256)",uint256(0x11))),"wrong underflow panic"); o[0]=17;
                    }
                }
            }
        }
        o[1]=s.product.policiesToProcess();
        o[2]=s.product.getProcessedBalance(address(this));
        o[3]=s.policy.confirmations();
        o[4]=s.policy.createdPayouts();
        o[5]=s.policy.paid();
        o[6]=s.treasury.calls();
        o[7]=s.pool.calls();
        o[8]=s.pool.amount();
        o[9]=uint256(s.policy.getPolicy(id).state);
        o[10]=s.policy.claims(id);
        o[11]=s.product.getDepegBalance(address(this)).balance;
    }
}
