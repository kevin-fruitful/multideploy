// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Multideploy, Create2Deployment} from "src/Multideploy.sol";
import {Counter} from "src/Counter.sol";

contract MultideployTest is Test {
    Multideploy multideploy;

    /// @notice Setups up the testing suite
    function setUp() public {
        multideploy = new Multideploy();
    }

    function test_DeployCounter_IndividualCreate1() public {
        new Counter();
    }

    function test_DeployMultideploy_IndividualCreate1() public {
        new Multideploy();
    }

    function test_DeployCounter_IndividualCreate2() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Counter).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes32 salt = "0xc1";
        vm.resumeGasMetering();
        assembly {
            let contractAddress := create2(0, add(initCode, 0x20), initCode, salt)
        }
    }

    function test_DeployMultideploy_IndividualCreate2() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes32 salt = "0xc1";
        vm.resumeGasMetering();
        assembly {
            let contractAddress := create2(0, add(initCode, 0x20), initCode, salt)
        }
    }

    function test_deployContractsMemory_DeployBatch1MultideployCreate1() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes[] memory initCodes = new bytes[](1);
        initCodes[0] = initCode;
        vm.resumeGasMetering();
        multideploy.deployContractsMemory(initCodes);
    }

    function test_deployContracts_DeployBatch1MultideployCreate1() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes[] memory initCodes = new bytes[](1);
        initCodes[0] = initCode;
        vm.resumeGasMetering();
        multideploy.deployContracts(initCodes);
    }

    function test_deployContracts_DeployBatch1CounterCreate1() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Counter).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes[] memory initCodes = new bytes[](1);
        initCodes[0] = initCode;
        vm.resumeGasMetering();
        multideploy.deployContracts(initCodes);
    }

    function test_deployContracts_DeployBatch1CounterCreate2() public {
        vm.pauseGasMetering();
        Create2Deployment[] memory deployments = new Create2Deployment[](1);
        bytes memory bytecode = type(Counter).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        deployments[0].initCode = initCode;
        deployments[0].salt = "0xc1";
        vm.resumeGasMetering();
        multideploy.deployContracts(deployments);
    }

    function test_deployContracts_DeployBatch1MultideployCreate2() public {
        vm.pauseGasMetering();
        Create2Deployment[] memory deployments = new Create2Deployment[](1);
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        deployments[0].initCode = initCode;
        deployments[0].salt = "0xc1";
        vm.resumeGasMetering();
        multideploy.deployContracts(deployments);
    }

    function test_deployContracts_DeployBatch2Multideploy1CounterCreate1() public {
        vm.pauseGasMetering();
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        bytes[] memory initCodes = new bytes[](3);
        initCodes[0] = initCode;
        initCodes[1] = initCode;
        initCode = abi.encodePacked(type(Counter).creationCode, arguments);
        initCodes[2] = initCode;
        vm.resumeGasMetering();
        multideploy.deployContracts(initCodes);
    }

    function test_deployContracts_DeployBatch2Multideploy1CounterCreate2() public {
        vm.pauseGasMetering();
        Create2Deployment[] memory deployments = new Create2Deployment[](3);
        bytes memory bytecode = type(Multideploy).creationCode;
        bytes memory arguments;
        bytes memory initCode = abi.encodePacked(bytecode, arguments);
        deployments[0].initCode = initCode;
        deployments[0].salt = "0xc1";
        deployments[1].initCode = initCode;
        deployments[1].salt = "0xc2";
        initCode = abi.encodePacked(type(Counter).creationCode, arguments);
        deployments[2].initCode = initCode;
        deployments[2].salt = "0xc3";
        vm.resumeGasMetering();
        multideploy.deployContracts(deployments);
    }
}
