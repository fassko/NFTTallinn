const hre = require("hardhat");

const main = async () => {
  const NFTTallinnTicket = await hre.ethers.getContractFactory("NFTTallinnTicket");
  const nftTallinnTicket = await NFTTallinnTicket.deploy("NFTTallinn", "NFTTLN");

  await nftTallinnTicket.deployed();

  console.log("NFT Tallinn ticket deployed:", nftTallinnTicket.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });