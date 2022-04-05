const hre = require("hardhat");

const main = async () => {
  // get test addresses
  const [owner, addr1, addr2] = await ethers.getSigners();

  // log out addresses
  console.log("owner", owner.address);
  console.log("addr1", addr1.address);
  console.log("addr2", addr2.address);

  const NFTTallinn = await hre.ethers.getContractFactory("NFTTallinn");
  const nftTallinn = await NFTTallinn.deploy("NFTTallinn", "NFTTLN");

  await nftTallinn.deployed();

  console.log("NFT Tallinn ticket deployed:", nftTallinn.address);

  await nftTallinn.createTicket(addr1.address, 1, "https://bafybeigsc6eqcgxkevnvxcvbdpdmecxsn4vteio4kd5tsdiubjj2ohmysu.ipfs.dweb.link/");

  const myTicket = await nftTallinn.connect(addr1).getMyTicket();
  console.log(myTicket);

  let checkEntrance = await nftTallinn.checkEntrance(addr1.address);
  console.log("Check entrance", checkEntrance);

  const sellTicket = await nftTallinn.connect(addr1).sellTicket(addr2.address);

  console.log(sellTicket);

  checkEntrance = await nftTallinn.checkEntrance(addr1.address);
  console.log("Check entrance", checkEntrance);

  checkEntrance = await nftTallinn.checkEntrance(addr2.address);
  console.log("Check entrance", checkEntrance);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });