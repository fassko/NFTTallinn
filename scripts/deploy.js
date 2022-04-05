const hre = require("hardhat");

const main = async () => {
  const NFTTallinn = await hre.ethers.getContractFactory("NFTTallinn");
  const nftTallinn = await NFTTallinn.deploy("NFTTallinn", "NFTTLN");

  await nftTallinn.deployed();

  console.log("NFT Tallinn ticket deployed:", nftTallinn.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });