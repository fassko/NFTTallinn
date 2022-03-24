//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

enum TicketType {
    Regular,
    VIP,
    Speaker
}

struct Ticket {
    uint256 id; // ticket QR code ID
    TicketType ticketType;
}

contract NFTTallinnTicket is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => Ticket) private tickets;

    constructor(
        string memory eventName,
        string memory shortName
    ) ERC721(eventName, shortName) {
        // initializes the NFT storage
    }

    function createTicket(
        address visitor, 
        TicketType ticketType,
        string memory tokenURI
    ) public onlyOwner nonReentrant returns (uint256) {

        // generate the ticket ID to be placed on the QR code
        _tokenIds.increment();

        // set nft ticket ID
        uint256 newItemId = _tokenIds.current();

        // mint the NFT and assign to the visitor address
        _mint(visitor, newItemId);

        // set the token JSON file link that was uploaded to the IPFS
        _setTokenURI(newItemId, tokenURI);

        tickets[visitor] = Ticket({
          id: newItemId,
          ticketType: ticketType
        });

        // get back the NFT ticket ID
        return newItemId;
    }

    function getMyTickets() external view returns (Ticket memory) {
      require(tickets[msg.sender].id != 0, "Ticket does not exist!");

        // check if ticket exists
        return tickets[msg.sender];
    }

    function sellTicket(address to) external nonReentrant {
      uint256 ticketId = tickets[msg.sender].id;

      safeTransferFrom(msg.sender, to, ticketId);

      tickets[to] = tickets[msg.sender];
      delete tickets[msg.sender];
    }


    // after scanning QR code check the entrance with the ticket ID and address
    function checkEntrance(address _address) 
        external 
        view 
        onlyOwner
        returns(bool)
    {
      uint256 ticketId = tickets[_address].id;

      if (ticketId == 0) {
        return false;
      } else {
        return ownerOf(ticketId) == _address;
      }
    }
}

/**
JSON file formats
Uploaded to IPFS

https://eips.ethereum.org/EIPS/eip-721
https://ethereum.org/en/developers/docs/standards/tokens/erc-721/
https://nftschool.dev/reference/metadata-schemas/#intro-to-json-schemas

{
    "name": "NFT Tallinn",
    "description": "NFT Tallinn aims to connect NFT creators, collectors and other web3 industry pioneers.",
    "image": "https://nfttallinn.ee/ticket-hfn84n.png",

    "ticketType": "regular"
}

{
    "name": "NFT Tallinn",
    "description": "NFT Tallinn aims to connect NFT creators, collectors and other web3 industry pioneers.",
    "image": "https://nfttallinn.ee/ticket-hfn84n.png",

    "ticketType": "vip" 
}
**/