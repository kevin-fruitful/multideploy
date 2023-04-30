// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

struct Create2Deployment {
    bytes32 salt;
    bytes initCode;
}

contract Multideploy {
    // STRIPPED DOWN MEMORY - more expensive than calldata version
    function deployContractsMemory(bytes[] memory initCodes) external {
        assembly {
            let length := mload(add(initCodes, 0)) // same gas cost as just loading the length outside of assembly
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let contractAddress :=
                    create(
                        0,
                        add(mload(add(add(initCodes, 0x20), mul(i, 0x20))), 0x20),
                        mload(mload(add(add(initCodes, 0x20), mul(i, 0x20))))
                    )
            }
        }
    }

    function deployContractsMemorySafely(bytes[] memory initCodes) external returns (address[] memory contracts) {
        uint256 length = initCodes.length;
        for (uint256 i; i < length; ++i) {
            assembly {
                let contractAddress :=
                    create(
                        0,
                        add(mload(add(add(initCodes, 0x20), mul(i, 0x20))), 0x20),
                        mload(mload(add(add(initCodes, 0x20), mul(i, 0x20))))
                    )
                if iszero(extcodesize(contractAddress)) { revert(0, 0) }
                mstore(add(contracts, add(0x20, mul(0x20, i))), contractAddress)
            }
        }
    }

    function deployContracts(bytes[] calldata initCodes) external {
        assembly {
            // Get the length of the initCodes array
            let arrayLength := initCodes.length

            // Declare variables outside the loop to save gas
            let elementOffset
            let initCodeLength

            // Iterate through the initCodes array
            for { let i := 0 } lt(i, arrayLength) { i := add(i, 1) } {
                // Calculate the calldata offset of the i-th element
                elementOffset := add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20))))

                // Get the length of the i-th initCode
                initCodeLength := calldataload(add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20)))))

                // Allocate memory for the i-th initCode
                let initCode := mload(0x40)
                // Update the "free memory pointer" by adding the length of the initCode plus 0x20 (32 bytes) for the length field
                mstore(0x40, add(initCode, add(initCodeLength, 0x20)))

                // Copy the i-th initCode from calldata to memory
                calldatacopy(add(initCode, 0x20), add(elementOffset, 0x20), initCodeLength)

                // Deploy the contract using the create opcode, which takes the memory offset, and the initCode length as arguments
                // The contractAddress will be returned by the create opcode
                let contractAddress := create(0, add(initCode, 0x20), initCodeLength)
            }
        }
    }

    function deployContractsSafely(bytes[] calldata initCodes) external returns (address[] memory contracts) {
        assembly {
            // Get the length of the initCodes array
            let arrayLength := initCodes.length

            // Declare variables outside the loop to save gas
            let elementOffset
            let initCodeLength

            // Iterate through the initCodes array
            for { let i := 0 } lt(i, arrayLength) { i := add(i, 1) } {
                // Calculate the calldata offset of the i-th element
                elementOffset := add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20))))

                // Get the length of the i-th initCode
                initCodeLength := calldataload(add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20)))))

                // Allocate memory for the i-th initCode
                let initCode := mload(0x40)
                // Update the "free memory pointer" by adding the length of the initCode plus 0x20 (32 bytes) for the length field
                mstore(0x40, add(initCode, add(initCodeLength, 0x20)))

                // Copy the i-th initCode from calldata to memory
                calldatacopy(add(initCode, 0x20), add(elementOffset, 0x20), initCodeLength)

                // Deploy the contract using the create opcode, which takes the memory offset, and the initCode length as arguments
                // The contractAddress will be returned by the create opcode
                let contractAddress := create(0, add(initCode, 0x20), initCodeLength)

                if iszero(extcodesize(contractAddress)) { revert(0, 0) }
                mstore(add(contracts, add(0x20, mul(0x20, i))), contractAddress)
            }
        }
    }

    function deployContracts(Create2Deployment[] calldata initCodes) external {
        assembly {
            // Get the length of the initCodes array
            let arrayLength := initCodes.length

            // Declare variables outside the loop to save gas
            let elementOffset
            let initCodeLength

            // Iterate through the initCodes array
            for { let i := 0 } lt(i, arrayLength) { i := add(i, 1) } {
                // Calculate the calldata offset of the i-th element
                elementOffset := add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20))))

                // Load the i-th salt from calldata and store it in memory
                let salt := mload(0x40)
                mstore(0x40, add(salt, 0x20))
                calldatacopy(salt, add(elementOffset, 0x20), 0x20)

                // Get the length of the i-th initCode
                initCodeLength := calldataload(add(elementOffset, 0x40))

                // Calculate the calldata offset of the i-th initCode content
                let initCodeOffset := add(elementOffset, 0x60)

                // Allocate memory for the i-th initCode
                let initCode := mload(0x40)
                mstore(0x40, add(initCode, add(initCodeLength, 0x20)))

                // Copy the i-th initCode from calldata to memory
                calldatacopy(add(initCode, 0x20), initCodeOffset, initCodeLength)

                // Deploy the contract using the create2 opcode
                let contractAddress := create2(0, add(initCode, 0x20), initCodeLength, salt)
            }
        }
    }

    function deployContractsSafely(Create2Deployment[] calldata initCodes)
        public
        returns (address[] memory contracts)
    {
        assembly {
            // Get the length of the initCodes array
            let arrayLength := initCodes.length

            // Declare variables outside the loop to save gas
            let elementOffset
            let initCodeLength

            // Iterate through the initCodes array
            for { let i := 0 } lt(i, arrayLength) { i := add(i, 1) } {
                // Calculate the calldata offset of the i-th element
                elementOffset := add(initCodes.offset, calldataload(add(initCodes.offset, mul(i, 0x20))))

                // Load the i-th salt from calldata and store it in memory
                let salt := mload(0x40)
                mstore(0x40, add(salt, 0x20))
                calldatacopy(salt, add(elementOffset, 0x20), 0x20)

                // Get the length of the i-th initCode
                initCodeLength := calldataload(add(elementOffset, 0x40))

                // Calculate the calldata offset of the i-th initCode content
                let initCodeOffset := add(elementOffset, 0x60)

                // Allocate memory for the i-th initCode
                let initCode := mload(0x40)
                mstore(0x40, add(initCode, add(initCodeLength, 0x20)))

                // Copy the i-th initCode from calldata to memory
                calldatacopy(add(initCode, 0x20), initCodeOffset, initCodeLength)

                // Deploy the contract using the create2 opcode
                let contractAddress := create2(0, add(initCode, 0x20), initCodeLength, salt)

                if iszero(extcodesize(contractAddress)) { revert(0, 0) }
                mstore(add(contracts, add(0x20, mul(0x20, i))), contractAddress)
            }
        }
    }
}
