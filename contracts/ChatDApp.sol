// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

contract ChatApp {
    struct _User {
        string name;
        address publicKey;
    }
    struct User {
        string name;
        Friend[] friends;
    }

    struct Friend {
        address publicKey;
        string name;
    }

    struct Message {
        address from;
        address to;
        uint256 timestamp;
        string content;
    }

    _User[] public users;

    mapping(address => User) userByPublicKey;
    mapping(bytes32 => Message[]) messages;

    function doesUserExist(address publicKey) public view returns (bool) {
        return bytes(userByPublicKey[publicKey].name).length > 0;
    }

    function createAccount(string calldata name) external {
        require(!doesUserExist(msg.sender), "User already exists!");
        require(bytes(name).length > 0, "Name cannot be empty!");

        users.push(_User(name, msg.sender));
        userByPublicKey[msg.sender].name = name;
    }

    function getUserName(address publicKey) external view returns (string memory) {
        require(doesUserExist(publicKey), "User does not exist!");

        return userByPublicKey[publicKey].name;
    }

    function areFriends(address publicKey1, address publicKey2) internal view returns (bool) {
        if (userByPublicKey[publicKey1].friends.length > userByPublicKey[publicKey2].friends.length) {
            address temporary = publicKey1;
            publicKey1 = publicKey2;
            publicKey2 = temporary;
        }

        for (uint256 i = 0; i < userByPublicKey[publicKey1].friends.length; i++) {
            if (userByPublicKey[publicKey1].friends[i].publicKey == publicKey2) {
                return true;
            }
        }
        return false;
    }

    function _addFriend(address publicKey1, address publicKey2, string memory name) internal {
        Friend memory friend = Friend(publicKey2, name);
        userByPublicKey[publicKey1].friends.push(friend);
    }

    function addFriend(address publicKey, string calldata name) external {
        require(doesUserExist(msg.sender), "You have to create an account first!");
        require(doesUserExist(publicKey), "The user you're trying to add does not exist!");
        require(msg.sender != publicKey, "You can't add yourself as a friend.");
        require(!areFriends(msg.sender, publicKey), "You two are already friends!");

        _addFriend(msg.sender, publicKey, name);
        _addFriend(publicKey, msg.sender, userByPublicKey[msg.sender].name);
    }

    function getFriends() external view returns(Friend[] memory) {
        return userByPublicKey[msg.sender].friends;
    }

    function _getChatCode(address publicKey1, address publicKey2) internal pure returns(bytes32) {
        if (publicKey1 < publicKey2) {
            return keccak256(abi.encodePacked(publicKey1, publicKey2));
        } else {
            return keccak256(abi.encodePacked(publicKey2, publicKey1));
        }
    }

    function sendMessage(address receiver, string calldata content) external {
        require(doesUserExist(msg.sender), "You have to create an account first!");
        require(doesUserExist(receiver), "The user you're trying to chat with does not exist!");
        require(areFriends(msg.sender, receiver), "You have to befriend this user to start chatting!");

        bytes32 chatCode = _getChatCode(msg.sender, receiver);
        Message memory message = Message(msg.sender, receiver, block.timestamp, content);
        messages[chatCode].push(message);
    }

    function readMessages(address friend) external view returns(Message[] memory) {
        bytes32 chatCode = _getChatCode(msg.sender, friend);
        return messages[chatCode];
    }

    function getAllUsers() public view returns(_User[] memory) {
        return users;
    }
}
