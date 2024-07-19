// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

contract ChatApp {
    // User struct
    struct User {
        string name;
        Friend[] friends;
    }

    // Friend struct
    struct Friend {
        address publicKey;
        string name;
    }

    // Message struct
    struct Message {
        address from;
        address to;
        uint256 timestamp;
        string content;
    }

    mapping(address => User) users; // Mapping of public key to User
    mapping(bytes32 => Message[]) messages; // Mapping of hash to Message

    // Check if user exists.
    function doesUserExist(address publicKey) public view returns (bool) {
        return bytes(users[publicKey].name).length > 0;
    }

    // Create a new account.
    function createAccount(string calldata name) external {
        require(!doesUserExist(msg.sender), "User already exists!");
        require(bytes(name).length > 0, "Name cannot be empty!");

        users[msg.sender].name = name;
    }

    // Find user name given user address.
    function getUserName(address publicKey) public returns (string memory) {
        require(doesUserExist(publicKey), "User does not exist!");

        return users[publicKey].name
    }
}
