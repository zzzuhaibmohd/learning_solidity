// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract StorageComplex {
    uint256[3] fixedArray; //behaves same as if two individual uint256 were declared
    uint256[] bigArray; 
    //the formula used here is 
    //1. keccak256(abi.encode(slot));
    //2. sload(add(location, index))
    uint8[] smallArray;

    mapping(uint256 => uint256) public myMapping;
    //1.  keccak256(abi.encode(key, uint256(slot)));
    //2.  sload(location)

    mapping(uint256 => mapping(uint256 => uint256)) public nestedMapping;
    //  nestedMapping[2][4] = 7;
    //1. slot := nestedMapping.slot
    //2. abi.encode(uint256(4), keccak256(abi.encode(uint256(2), uint256(slot)))) 
    //3. sload(location)

    mapping(address => uint256[]) public addressToList;
    //
    //1. slot := addressToList.slot
    //2. abi.encode(keccak256(abi.encode(address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4), uint256(slot)))) 
    //3. ret := sload(add(location, index))

    constructor() {
        fixedArray = [99, 999, 9999];
        bigArray = [10, 20, 30, 40];
        smallArray = [1, 2, 3];

        myMapping[10] = 5;
        myMapping[11] = 6;
        nestedMapping[2][4] = 7;

        addressToList[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = [
            42,
            1337,
            777
        ];
    }

    function fixedArrayView(uint256 index) external view returns (uint256 ret) {
        assembly {
            ret := sload(add(fixedArray.slot, index))
        }
    }

    function bigArrayLength() external view returns (uint256 ret) {
        assembly {
            ret := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(uint256 index)
        external
        view
        returns (uint256 ret)
    {
        uint256 slot;
        assembly {
            slot := bigArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot)); //hash the slot and then add index to read the values

        assembly {
            ret := sload(add(location, index))
        }
    }

    function readSmallArray() external view returns (uint256 ret) {
        assembly {
            ret := sload(smallArray.slot)
        }
    }

    function readSmallArrayLocation(uint256 index)
        external
        view
        returns (bytes32 ret)
    {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            ret := sload(add(location, index))
        }
    }

    function getMapping(uint256 key) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := myMapping.slot
        }

        bytes32 location = keccak256(abi.encode(key, uint256(slot)));

        assembly {
            ret := sload(location)
        }
    }

    function getNestedMapping() external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := nestedMapping.slot
        }

        bytes32 location = keccak256(
            abi.encode(
                uint256(4),
                keccak256(abi.encode(uint256(2), uint256(slot)))
            )
        );
        assembly {
            ret := sload(location)
        }
    }

    function lengthOfNestedList() external view returns (uint256 ret) {
        uint256 addressToListSlot;
        assembly {
            addressToListSlot := addressToList.slot
        }

        bytes32 location = keccak256(
            abi.encode(
                address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
                uint256(addressToListSlot)
            )
        );
        assembly {
            ret := sload(location)
        }
    }

    function getAddressToList(uint256 index)
        external
        view
        returns (uint256 ret)
    {
        uint256 slot;
        assembly {
            slot := addressToList.slot
        }

        bytes32 location = keccak256(
            abi.encode(
                keccak256(
                    abi.encode(
                        address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
                        uint256(slot)
                    )
                )
            )
        );
        assembly {
            ret := sload(add(location, index))
        }
    }
}
