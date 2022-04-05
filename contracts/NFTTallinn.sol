//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// https://eips.ethereum.org/EIPS/eip-721

// ERC721 implementation
// https://docs.openzeppelin.com/contracts/2.x/api/token/erc721#ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Storage for URLS where NFT metadata is saved
// https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721URIStorage
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// https://docs.openzeppelin.com/contracts/2.x/access-control#ownership-and-ownable
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

// Ticket types
// Represented as integers
enum TicketType {
    Regular, // 0
    VIP, // 1
    Speaker // 2
}

// Ticket data structure
struct Ticket {
    uint256 id; // ticket QR code ID
    TicketType ticketType; // enum - 0, 1, 2
}

// Storage for URLS where NFT metadata is saved
// Get import

// Ownable - someone who deployed the contract can access it
contract NFTTallinn is ERC721URIStorage, Ownable {

  // token ID counter, starts with 0 when initialized, default value
  uint256 private tokenId; // = 0;

  // keeping track of addresses that has ticket
  // 0x3FD0E5b04c1191629ecCe9e3BD62BFF97e1367BC => { ID, TICKET_TYPE }
  mapping(address => Ticket) private tickets;

  // !! can show if we have time
  modifier ticketExists(address _address) {
    require(tickets[_address].id != 0, "Ticket does not exist!");
    _;
  }

  // called when smart contract is being deployed on the chain
  constructor(
      string memory eventName,
      string memory shortName
  ) ERC721(eventName, shortName) {
      // initializes the NFT token contract
  }

  // creating the ticket function
  function createTicket(
      address visitor, // address of the visitor
      TicketType ticketType, // which tiket type
      string memory tokenURI // token metadata from IPFS
  ) public onlyOwner returns (uint256) {
    // can call person who deployed this contract

    // generate the ticket ID to be placed on the QR code
    tokenId++;

    // mint the NFT and assign to the visitor address
    // ERC-721 standard
    _mint(visitor, tokenId);

    // set the token JSON file link that was uploaded to the IPFS
    // show how to upload with NFT Storage or Pinata
    _setTokenURI(tokenId, tokenURI);

    tickets[visitor] = Ticket({
      id: tokenId,
      ticketType: ticketType
    });

    // get back the NFT ticket ID
    return tokenId;
  }

  // ticket holder can call this
  function getMyTicket() external view returns (Ticket memory) {
    // check if ticket exists
    require(tickets[msg.sender].id != 0, "Ticket does not exist!");

    return tickets[msg.sender];
  }

  // ticket holder can call this to sell ticket to someone else
  // here we don't have money transfers involved for sake of simplicity but that can be a homework
  function sellTicket(address to) external {
    // check again if ticket exists
    // can extract to the modifier
    require(tickets[msg.sender].id != 0, "Ticket does not exist!");

    // get ticket id
    uint256 ticketId = tickets[msg.sender].id;

    // transfer to new owner the NFT
    // ERC-721
    safeTransferFrom(msg.sender, to, ticketId);

    // assign ticket to the new owner
    // important otherwise this screws up everything
    tickets[to] = tickets[msg.sender];

    // delete old ticket from the register
    delete tickets[msg.sender];
  }

  // visitor shows their metamask wallet QR code
  // after scanning QR code check the entrance with the ticket ID and address
  function checkEntrance(address _address) 
      external 
      view 
      onlyOwner
      returns(bool)
  {
    // only owner of the contract can do this

    // check if ticket exists
    require(tickets[_address].id != 0, "Ticket does not exist!");

    // get the ticket id
    uint256 ticketId = tickets[_address].id;

    // check if can enter
    return ownerOf(ticketId) == _address;
  }
}


/**
JSON file formats
Uploaded to IPFS

https://ethereum.org/en/developers/docs/standards/tokens/erc-721/
https://nftschool.dev/reference/metadata-schemas/#intro-to-json-schemas

https://nft.storage/login/
https://app.pinata.cloud/

**/