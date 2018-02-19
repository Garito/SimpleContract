pragma solidity ^0.4.18;


contract SimpleProject {
    struct Proposal {
        address contributor;
        uint amount;
    }

    address public owner;
    mapping (uint => Proposal) public pending;
    mapping (address => uint) public shares;
    uint public total;
    uint public time;
    uint public cash;

    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }

    function SimpleProject (uint t, uint c) public {
        owner = msg.sender;
        time = t;
        cash = c;
    }

    event Payment(address indexed _from, uint _value);

    function () public payable {
        Payment(msg.sender, msg.value);
    }

    event ChangeOwnership (address newOwner);

    function changeOwner (address newOwner) public onlyOwner {
        owner = newOwner;
        ChangeOwnership(newOwner);
    }

    event TimeChangeChanged (uint newChange);

    function timeChange (uint newChange) public onlyOwner {
        time = newChange;
        TimeChangeChanged(newChange);
    }

    event CashChangeChanged (uint newChanged);

    function cashChange (uint newChange) public onlyOwner {
        cash = newChange;
        CashChangeChanged(newChange);
    }

    event CashInvestment (address investor, uint id, uint _value);

    function investCash (uint id) public payable {
        pending[id] = Proposal(msg.sender, msg.value * cash);
        CashInvestment(msg.sender, id, msg.value * cash);
    }

    event TimeInvestment (address investor, uint id, uint _value);

    function investTime (uint id, uint16 amount) public {
        pending[id] = Proposal(msg.sender, amount * time);
        TimeInvestment(msg.sender, id, amount * time);
    }

    event InvestmentAccepted (uint id);

    function acceptInvestment (uint id) public {
        shares[pending[id].contributor] += pending[id].amount;
        total += pending[id].amount;
        delete pending[id];
        InvestmentAccepted(id);
    }

    event Withdrawed (address contributor, uint amount);

    function withdraw (address contributor) public returns (uint balance) {
        balance = contributorBalance(contributor);
        require(this.balance > balance);
        shares[contributor] = 0;
        total -= balance;
        contributor.transfer(balance);
        Withdrawed(contributor, balance);
    }

    function contributorShares (address contributor) public view returns (uint) {
        return shares[contributor];
    }

    function contributorPercent (address contributor) public view returns (uint) {
        return (shares[contributor] * 100) / total;
    }

    function contributorBalance (address contributor) public view returns (uint) {
        return (this.balance * contributorPercent(contributor)) / 100;
    }

    function contributorStatus (address contributor) public view returns (uint, uint, uint) {
        return (contributorShares(contributor), contributorPercent(contributor), contributorBalance(contributor));
    }
}
