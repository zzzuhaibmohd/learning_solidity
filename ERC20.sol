pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);
    
    //check to grant the "spender" to spend on behalf of "owner"
    function allowance(address owner, address spender) external view returns (uint);

    //grant the "spender" to spend "amount" number of tokens
    function approve(address spender, uint amount) external returns (bool);

    //transfer "amount" number of tokens from "sender" to "recipient" 
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf; //to check balance of LOL token of an address
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "LolCoin";
    string public symbol = "LOL";
    uint8 public decimals = 18;

    // simple transfer of tokens from msg.sender to recipient
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    
    //grant the "spender" to spend "amount" number of tokens
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    //transfer "amount" number of tokens from "sender" to "recipient" 
    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
  
    //public function to mint "amount" number the tokens
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    //public function to burn "amount" number the tokens 
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
