// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./LabelNFT.sol";

contract LabelFactory is Initializable, OwnableUpgradeable {
    // Define create label event
    event LabelCreated(address indexed creator, string labelName, address labelAddress);

    // Define delete label event
    event LabelRemoved(string labelName, address labelAddress);
    
    // Save twitter account with LabelNFT contract address list
    mapping(string => address[]) public accountToLabels;

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
    }

    // Create new LabelNFT Contract
    function createLabel(string memory twitterAccount, string memory labelName) public returns (address) {
        // Check if there is a same labelName and twitterAccount
        address[] storage existingLabels = accountToLabels[twitterAccount];
        for (uint i = 0; i < existingLabels.length; i++) {
            LabelNFT existingLabel = LabelNFT(existingLabels[i]);
            (, string memory existingName,) = existingLabel.getInfo();
            require(keccak256(abi.encodePacked(existingName)) != keccak256(abi.encodePacked(labelName)), "Already Exist");
        }
        
        // Deploy new LabelNFT
        LabelNFT newLabel = new LabelNFT(twitterAccount, labelName);
        
        // Add new LabelNFT to accountToLabels map
        accountToLabels[twitterAccount].push(address(newLabel));
        // Trigger LabelCreated event
        emit LabelCreated(msg.sender, labelName, address(newLabel));
        return address(newLabel);
    }

    // Delete labelName in accountToLabels, only executed by owner
    function removeLabel(string memory twitterAccount, string memory labelName) public onlyOwner {
        address[] storage labels = accountToLabels[twitterAccount];
        for (uint i = 0; i < labels.length; i++) {
            LabelNFT label = LabelNFT(labels[i]);
            (, string memory existingName,) = label.getInfo();
            if (keccak256(abi.encodePacked(existingName)) == keccak256(abi.encodePacked(labelName))) {
                labels[i] = labels[labels.length - 1];
                labels.pop();
                // Trigger LabelRemoved event
                emit LabelRemoved(labelName, address(label));
                return;
            }
        }
        revert("Label Not Found");
    }

    function version() public pure returns (string memory) {
        return "1.0.0";
    }
}



