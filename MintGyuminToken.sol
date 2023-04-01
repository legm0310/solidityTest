// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintGyuminToken is ERC721Enumerable {
  constructor() ERC721("9minMint", "GMT") {}

  mapping(uint256 => uint256) public gyuminTypes;

  function mintGyuminToken() public {
      uint256 gyuminTokenId = totalSupply() + 1;

      uint256 gyuminType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, gyuminTokenId))) % 5 + 1;

      gyuminTypes[gyuminTokenId] = gyuminType;

      _mint(msg.sender, gyuminTokenId);
  }
}
