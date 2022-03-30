const hre = require("hardhat");

const main = async () => {
  const [owner, addr1, addr2] = await ethers.getSigners();

  console.log("owner", owner.address);
  console.log("addr1", addr1.address);
  console.log("addr2", addr2.address);

  const NFTTallinnTicket = await hre.ethers.getContractFactory("NFTTallinnTicket");
  const nftTallinnTicket = await NFTTallinnTicket.deploy("NFTTallinn", "NFTTLN");

  await nftTallinnTicket.deployed();

  console.log("NFT Tallinn ticket deployed:", nftTallinnTicket.address);

  await nftTallinnTicket.createTicket(addr1.address, 1, "https://bafybeigsc6eqcgxkevnvxcvbdpdmecxsn4vteio4kd5tsdiubjj2ohmysu.ipfs.dweb.link/");

  const myTicket = await nftTallinnTicket.connect(addr1).getMyTickets();
  console.log(myTicket);

  let checkEntrance = await nftTallinnTicket.checkEntrance(addr1.address);
  console.log("Check entrance", checkEntrance);

  const sellTicket = await nftTallinnTicket.connect(addr1).sellTicket(addr2.address);

  console.log(sellTicket);

  checkEntrance = await nftTallinnTicket.checkEntrance(addr1.address);
  console.log("Check entrance", checkEntrance);

  checkEntrance = await nftTallinnTicket.checkEntrance(addr2.address);
  console.log("Check entrance", checkEntrance);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });