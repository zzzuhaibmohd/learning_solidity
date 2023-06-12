//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract WithdrawV1 {
    constructor() payable {}

    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdraw() external {
        //payable(owner).transfer(address(this).balance); -> it will only 2300 gas instead of gas()
        (bool s, bytes memory data) = payable(owner).call{value: address(this).balance}("");
        require(s);
    }
}

contract WithdrawV2 {
    constructor() payable {}

    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdraw() external {
        assembly {                                  // ("") -> corresponds to first (0,0)                                     
            let s := call(gas(), owner, selfbalance(), 0, 0, 0, 0)
            if iszero(s) {                              //  [    ] -> corresponds to "bytes memory data"
                revert(0, 0)
            }
        }
    }
}
