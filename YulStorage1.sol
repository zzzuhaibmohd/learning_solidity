// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract StorageBasics {
    uint256 x = 2;  //slot 0
    uint256 y = 13; //slot 1
    uint256 z = 54; //slot 2
    uint256 p;      //slot 3

    function getP() external view returns (uint256) {
        return p; // p.slot
    }

    function getVarYul(uint256 slot) external view returns (bytes32 ret) {
        assembly {
            ret := sload(slot)
        }
    }

    function setVarYul(uint256 slot, uint256 value) external {
        assembly {
            sstore(slot, value)
        }
    }

    function setX(uint256 newVal) external {
        x = newVal;
    }

    function getX() external view returns (uint256) {
        return x;
    }
}
