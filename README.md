# Multideploy (EXPERIMENTAL)

This is an experimental repo in relation to [https://github.com/mds1/multicall/issues/81](this topic).

THIS CODE IS UNAUDITED. USE AT YOUR OWN RISK.

`Multideploy` is an experimental smart contract designed to deploy multiple contracts with a single function call in a gas-efficient manner. The contract provides different implementations for deploying contracts using the `CREATE` and `CREATE2` opcodes. However, the current findings show that deploying contracts by batching in this manner is more expensive compared to other deployment methods.

## Overview

The `Multideploy` smart contract includes the following functions:

1. `deployContractsMemory(bytes[] memory initCodes)`: Deploy contracts using the `CREATE` opcode with the contract initialization code passed as memory bytes arrays.
2. `deployContractsMemorySafely(bytes[] memory initCodes)`: Deploy contracts using the `CREATE` opcode with the contract initialization code passed as memory bytes arrays and return the contract addresses in a safe manner.
3. `deployContracts(bytes[] calldata initCodes)`: Deploy contracts using the `CREATE` opcode with the contract initialization code passed as calldata bytes arrays.
4. `deployContractsSafely(bytes[] calldata initCodes)`: Deploy contracts using the `CREATE` opcode with the contract initialization code passed as calldata bytes arrays and return the contract addresses in a safe manner.
5. `deployContracts(Create2Deployment[] calldata initCodes)`: Deploy contracts using the `CREATE2` opcode with the struct `Create2Deployment` passed as calldata arrays.
6. `deployContractsSafely(Create2Deployment[] calldata initCodes)`: Deploy contracts using the `CREATE2` opcode with the struct `Create2Deployment` passed as calldata arrays and return the contract addresses in a safe manner.

All of these functions take in the initialization bytecode, which is the bytecode + constructor arguments:

bytes creation_code = type(Contract).creationCode
bytes constructor_arguments = abi.encode(arg1, arg2, etc.)
initialization_bytecode = abi.encodePacked(creation_code, constructor_arguments)

## Usage

To use the `Multideploy` contract, pass an array of contract initialization codes to the appropriate deployment function. The functions will loop through the array and deploy each contract using either the `CREATE` or `CREATE2` opcode. If the deployment is successful, the contract address will be returned. If the deployment fails or an error occurs, the function will revert with a clear error message.

## Limitations

The `Multideploy` contract is currently experimental and may not be as efficient as expected. In the current implementation, deploying contracts in a batch is more expensive than deploying them one-by-one. Further optimization and testing are needed to improve the efficiency of this contract.

## Findings

solc 0.8.19, Forge default compiler settings:

| Quantity |  Contract  |  Opcode  | Individual |  Batch  | Difference |
|:--------:|:----------:|:-------: |:----------:|:-------:|:----------:|
|    1     |   Counter  |  create  |   81827    |  91603  |    9776    |
|    1     |   Counter  | create2  |   84841    |  91775  |    6934    |
|    1     | Multideploy|  create  |   317367   | 329837  |   12470    |
|    1     | Multideploy| create2  |   320639   | 330321  |    9682    |
|    3*    | Multideploy|  create  |   716561   | 733376  |   16815    |
|    3*    | Multideploy| create2  |   726119   | 734384  |    8265    |

*Note that the quantity for the last two rows is 3, with 2 Multideploy contracts and 1 Counter contract.

The difference shows that using multiDeploy() is more expensive in gas.
Another note is that there will be more devex challenges.

## What's next?

`forge snapshot --diff --via-ir --optimizer-runs 1000000`
Test with constructor args.
My assembly skills are awful, are there more optimizations possible?

## Special thanks

[Jeff Lau](https://github.com/jefflau) [@jefflau](https://github.com/jefflau) insights on pros/cons.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
