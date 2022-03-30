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

contract NFTTallinnTicket is ERC721URIStorage, Ownable {
  // token ID counter, starts with 0 when initialized, default value
  uint256 private tokenId;

  // keeping track of addresses that has ticket
  // 0x3FD0E5b04c1191629ecCe9e3BD62BFF97e1367BC => { ID, TICKET_TYPE }
  mapping(address => Ticket) private tickets;

  modifier ticketExists(address _address) {
    require(tickets[_address].id != 0, "Ticket does not exist!");
    _;
  }

  // called when smart contract is being created
  constructor(
      string memory eventName,
      string memory shortName
  ) ERC721(eventName, shortName) {
      // initializes the NFT token contract
  }

  function createTicket(
      address visitor, // address of the visitor
      TicketType ticketType, // which tiket type
      string memory tokenURI // token metadata
  ) public onlyOwner returns (uint256) {
    // can call person who deployed this contract

    // generate the ticket ID to be placed on the QR code
    tokenId++;

    // mint the NFT and assign to the visitor address
    _mint(visitor, tokenId);

    // set the token JSON file link that was uploaded to the IPFS
    _setTokenURI(tokenId, tokenURI);

    tickets[visitor] = Ticket({
      id: tokenId,
      ticketType: ticketType
    });

    // get back the NFT ticket ID
    return tokenId;
  }

  // ticket holder can call this
  function getMyTickets() external view returns (Ticket memory) {
    // check if ticket exists
    require(tickets[msg.sender].id != 0, "Ticket does not exist!");

    return tickets[msg.sender];
  }

  // ticket holder can call this
  function sellTicket(address to) external {
    // check again if ticket exists
    // can extract to the modifier
    require(tickets[msg.sender].id != 0, "Ticket does not exist!");

    // get ticket id
    uint256 ticketId = tickets[msg.sender].id;

    // transfer to new owner the NFT
    safeTransferFrom(msg.sender, to, ticketId);

    // assign ticket to the new owner 
    tickets[to] = tickets[msg.sender];

    // delete old ticket
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
    // check if ticket exists
    require(tickets[_address].id != 0, "Ticket does not exist!");

    uint256 ticketId = tickets[_address].id;

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