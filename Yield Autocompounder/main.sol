pragma solidity ^0.8.0;

contract AutoCompounder {
    address owner;
    mapping (address => mapping (string => uint)) public balances;
    mapping (string => uint) public interestRates;
    uint public totalSupply;
    uint public interestPool;
    
    // Constructor
    constructor() public {
        owner = msg.sender;
        totalSupply = 0;
        interestPool = 0;
    }
    
    // Deposit tokens
    function deposit(string memory _token) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender][_token] += msg.value;
        interestPool += msg.value;
        emit Deposit(msg.sender, msg.value, _token);
    }
    
    // Withdraw tokens
    function withdraw(string memory _token, uint _amount) public {
        require(balances[msg.sender][_token] >= _amount, "Insufficient balance");
        balances[msg.sender][_token] -= _amount;
        interestPool -= _amount;
        msg.sender.transfer(_amount);
        emit Withdrawal(msg.sender, _amount, _token);
    }
    
    // Compound interest on user's balance
    function compoundInterest(string memory _token) public {
        require(interestRates[_token] > 0, "Interest rate for the token is not set");
        uint interestAmount = balances[msg.sender][_token] * interestRates[_token] / 100;
        balances[msg.sender][_token] += interestAmount;
        interestPool += interestAmount;
        emit InterestCompounded(msg.sender, interestAmount, _token);
    }
    
    // Update interest rate for a token
    function updateInterestRate(string memory _token, uint _rate) public {
        require(msg.sender == owner, "Only the contract owner can update interest rate");
        interestRates[_token] = _rate;
        emit InterestRateUpdated(_token, _rate);
    }
    
    // Add a new token
    function addToken(string memory _token) public {
        require(msg.sender == owner, "Only the contract owner can add a new token");
        interestRates[_token] = 0;
        emit TokenAdded(_token);
    }
    
    // Remove a token
    function removeToken(string memory _token) public {
        require(msg.sender == owner, "Only the contract owner can remove a token");
        require(interestRates[_token] > 0, "Token does not exist in the contract");
        delete interestRates[_token];
        emit TokenRemoved(_token);
    }
    
    // Events
    event Deposit(address indexed _user, uint _amount, string _token);
    event Withdrawal(address indexed _user, uint _amount, string _token);
    event InterestCompounded(address indexed _user, uint _amount, string _token);
    event InterestRateUpdated(string _token, uint _rate);
    event TokenAdded(string _token);
    event TokenRemoved(string _token);
}