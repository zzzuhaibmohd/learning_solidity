//The below code demonstrates how to create a MultiSig Wallet 
//The contract is deployed with predefined owners and we set the number of Confirmations needed to execute the transaction
//For Example there are 3 owners defined and numConfirmations=2, which means only confirmation from 
//two owners is good enough to proceed with tranasctions.

pragma solidity ^0.5.11;

contract MultiSigWallet {

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTrasaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTrasaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    uint public numConfirmationsRequired;
    mapping(address => bool) isOwner;

    //stores all the important data regarding the transaction
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        mapping(address => bool) isConfirmed;
        uint numConfirmations;
    }

    Transaction[] public transaction;

    constructor(address[] memory _owners, uint _numConfirmationsRequired) public {

        require(_owners.length > 0, "owners required to approve");
        require(_numConfirmationsRequired > 0, "invalid number of tranasctions");
        for (uint i = 0; i < _owners.length; i++){
            address owner = _owners[i];
            
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    modifier onlyOwner(){
        require(isOwner[msg.sender],"not owner");
        _;
    }

    modifier txExists(uint _txIndex){
        require(_txIndex < transaction.length, "tx does not exist");
        _;
    }
    
    modifier notExecuted(uint _txIndex){
        require(!transaction[_txIndex].executed, "tx already executed");
        _;
    }
    
    modifier notConfirmed(uint _txIndex){
        require(!transaction[_txIndex].isConfirmed[msg.sender], "tx already confirmed");
        _;
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {

        uint txIndex = transaction.length;

        transaction.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex) public onlyOwner 
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex)
    {
        Transaction storage transaction = transaction[_txIndex];
        
        transaction.isConfirmed[msg.sender] = true;
        transaction.numConfirmations += 1;

        emit ConfirmTrasaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) public onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
        Transaction storage transaction = transaction[_txIndex];

        require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx");

        transaction.executed = true;
        (bool success, )  = transaction.to.call.value(transaction.value)(transaction.data);
        require(success, "tx failed");

        emit ExecuteTrasaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex) public onlyOwner 
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
        Transaction storage transaction = transaction[_txIndex];

        transaction.isConfirmed[msg.sender] = false;
        transaction.numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

}
