//  Current contract address: 0x464Efc7d5B4ACc96a09d8DfC6Ce6f90cC1F39acB

const { utils } = require("ethers");

async function main() {
  const baseTokenURI = "https://ipfs.io/ipfs/QmNyDfNaWYAF8EJwi53HfkThxDkXUVRXj5pTZWgFph2z4j/";

  // Get owner/deployer's wallet address
  const [owner] = await hre.ethers.getSigners();

  // Get contract that we want to deploy
  const contractFactory = await hre.ethers.getContractFactory("Mountains_Club");

  // Deploy contract with the correct constructor arguments
  // const contract = await contractFactory.deploy(baseTokenURI);
  const contract = await contractFactory.deploy();

  // Wait for this transaction to be mined
  await contract.deployed();

  // Get contract address
  console.log("Contract deployed to:", contract.address);

  // // Mint 3 NFTs by sending 0.03 ether
  // txn = await contract.mint(1, { value: utils.parseEther("0.01") });
  // await txn.wait();
  // console.log("1 NFT is minted successfully, ok?");
  // // Get all token IDs of the owner

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
