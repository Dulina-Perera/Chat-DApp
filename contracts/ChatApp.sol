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
    function getUserName(address publicKey) external returns (string memory) {
        require(doesUserExist(publicKey), "User does not exist!");

        return users[publicKey].name
    }

    // Check whether two users are friends.
    function areFriends(address publicKey1, address publicKey2) internal view returns (bool) {
        if (users[publicKey1].friends.length > users[publicKey2].friends.length) {
            address temporary = publicKey1;
            publicKey1 = publicKey2;
            publicKey2 = temporary;
        }

        for (uint256 i = 0; i < users[publicKey1].friends.length; i++) {
            if (users[publicKey1].friends[i].publicKey == publicKey2) {
                return true;
            }
        }
        return false;
    }

    // Add a friend. (Internal)
    function _addFriend(address publicKey1, address publicKey2, string memory name) internal {
        Friend memory friend = Friend(publicKey2, name);
        users[publicKey1].friends.push(friend);
    }

    // Add a friend. (Extenal)
    function addFriend(address publicKey, string calldata name) external {
        require(doesUserExist(msg.sender), "Create an account first!");
        require(doesUserExist(publicKey), "The user you're trying to add does not exist!");
        require(msg.sender != publicKey, "You can't add yourself as a friend.");
        require(!areFriends(msg.sender, publicKey), "You two are already friends!");

        _addFriend(msg.sender, publicKey, name);
        _addFriend(publicKey, msg.sender, users[msg.sender].name);
    }
}
