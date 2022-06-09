// SPDX-License-Identifier: unlicense
pragma solidity ^0.8.0;

import "./SpacePiratesTokens.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract SpacePiratesFaucet is Ownable {
    SpacePiratesTokens public immutable tokenContract;

    uint256 public constant DOUBLOONS = 1;
    uint256 public constant ASTEROIDS = 2;

    uint256 public mintLimit = 10000;

    mapping(address => uint256) public mintedDoubloons;
    mapping(address => uint256) public mintedAsteroids;

    constructor(SpacePiratesTokens _tokenContract) {
        tokenContract = _tokenContract;
    }

    function setMintLimit(uint256 _mintLimit) public onlyOwner {
        mintLimit = _mintLimit;
    }

    function mintDoubloons(uint256 _amount) public {
        require(
            mintedDoubloons[msg.sender] <= mintLimit,
            "SpacePiratesFaucet: MAX DOUBLOONS MINT LIMIT REACHED"
        );

        uint256 mintableAmount = (mintedDoubloons[msg.sender] + _amount) >
            mintLimit
            ? mintLimit - mintedDoubloons[msg.sender]
            : _amount;
        
        mintedDoubloons[msg.sender] += mintableAmount;

        tokenContract.mint(msg.sender, mintableAmount, DOUBLOONS);
    }

    function mintAsteroids(uint256 _amount) public {
        require(
            mintedAsteroids[msg.sender] <= mintLimit,
            "SpacePiratesFaucet: MAX ASTEROIDS MINT LIMIT REACHED"
        );

        uint256 mintableAmount = (mintedAsteroids[msg.sender] + _amount) >
            mintLimit
            ? mintLimit - mintedAsteroids[msg.sender]
            : _amount;
        mintedAsteroids[msg.sender] += mintableAmount;

        tokenContract.mint(msg.sender, mintableAmount, ASTEROIDS);
    }
}
