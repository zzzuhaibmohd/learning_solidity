// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract YulTypes {

    function getNumber() external pure returns(uint256){
        uint256 x;
        
        assembly{
            x := 42
        }

        return x;
    }

    function getHex() external pure returns(uint256){
        uint256 x;
        
        assembly{
            x := 0xa //decimal 10
        }

        return x;
    }

    function demoString() external pure returns(string memory){
        bytes32 myString = "";

        assembly {
            myString := "hello world"
        }
        
        //return myString; //return bytes32
        return string(abi.encode(myString));
    }

    function representation() external pure returns(bool){
        bool x;
        //try changing bool to address and uint8
        assembly {
            x := 1
        }

        return x;
    }
}
