// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

//Four Important instructions in memory
//1. mload
//2. mstore
//3. mstore8
//4. msize

// [0x..00-0x..20] & [0x..20-0x..40] -> used as scratch space - ephemeral space
// [0x..40-0x..60] as free memory pointer - used while writing something new to memory
// [0x..60-0x..80] is kept empty
// the action begins at [0x..80]
//

contract Memory {
    struct Point {
        uint256 x;
        uint256 y;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMsize(bytes32, bytes32);

    function highAccess() external pure {
        assembly {
            // pop just throws away the return value
            // this is because we are trying to read a very high location in memory
            //uses more than 30M block gas limit
            pop(mload(0xffffffffffffffff))
        }
    }

    function mstore8() external pure {
        assembly {
            mstore8(0x00, 7) //7
            mstore(0x00, 7)  //0..........00007
        }
    }

    function memPointer() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        Point memory p = Point({x: 1, y: 2});

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }// 0xc0 - 0x80 = 64 (2 slots of 32 bytes for x and y)

    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        Point memory p = Point({x: 1, y: 2});
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        assembly {
            pop(mload(0xff))
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);
    }

    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        uint256[2] memory arr = [uint256(5), uint256(6)];
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }// 0xc0 - 0x80 = 64 (2 slots of 32 bytes for x and y)

    function abiEncode() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint256(19));
        assembly {
            x40 := mload(0x40)//output wont be packed
        }
        emit MemoryPointer(x40);
    } //abi.encode needs to know the length of the arguments in this case 2 and stores it in one of the slots
      // it takes up 3 slots
      
    

    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint128(19));
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    } // even though uint128, abi.encode packs it into 32bytes 

    function abiEncodePacked() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encodePacked(uint256(5), uint128(19)); //output be packed since uint128(19), uses only 16 bytes instead of 32 bytes of memory
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    } // abi.encodePacked uses 16bytes for uint128

    event Debug(bytes32, bytes32, bytes32, bytes32);

    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        assembly {
            location := arr
            len := mload(arr)
            valueAtIndex0 := mload(add(arr, 0x20)) //directly read from index 0
            valueAtIndex1 := mload(add(arr, 0x40))
            // ...
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }

    function breakFreeMemoryPointer(uint256[1] memory foo)
        external
        view
        returns (uint256)
    {
        assembly {
            mstore(0x40, 0x80)
        }
        uint256[1] memory bar = [uint256(6)];
        return foo[0];
    }//foo gets overwritten by bar due to overwritting the memory

    uint8[] foo = [1, 2, 3, 4, 5, 6];

    function unpacked() external {
        uint8[] memory bar = foo;
    }//will load each uint8 in 32 bytes slot
}
