//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

contract AccessControl {

    //indexing the parameters to quickly filter via logs
    event GrantRole(address indexed _address, bytes32 indexed _role);
    event RevokeRole(address indexed _address, bytes32 indexed _role);

    //mapping role-->address-->bool
    mapping(bytes32 => mapping(address => bool)) public roles;

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    //0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    //Note: using 'private' and 'constant' identifiers helps save gas
    // ADMIN hASH - 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 public constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // USER hASH - 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 public constant USER = keccak256(abi.encodePacked("USER"));
    
    modifier requireRole(bytes32 _role){
        require(roles[_role][msg.sender], "access control missing !!!");
        _;
    }
    
    constructor(){
        _grantRole(msg.sender, ADMIN);
    }
    //using access speficer as internal because other contract ingeriting this contract can use this function as well
    function _grantRole (address _address, bytes32 _role) internal {
        roles[_role][_address] = true;

        emit GrantRole(_address, _role);
    }

    function _revokeRole (address _address, bytes32 _role) internal {
        roles[_role][_address] = false;

        emit RevokeRole(_address, _role);
    }
    
    //only role ADMIN can provide and revoke access.
    function grantRole (address _address, bytes32 _role) external requireRole(ADMIN){
        _grantRole(_address, _role);
    }
    
    function revokeRole (address _address, bytes32 _role) external requireRole(ADMIN){
        _revokeRole(_address, _role);
    }

    //only users with USER role access can call deposit and withdraw functions
    function depositFunds(address _to) external requireRole(USER){
        //logic for depositFunds
    }

    function withDrawFunds(address _to) external requireRole(USER){
        //logic for depositFunds
    }
}   
