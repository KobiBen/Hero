// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const Box = await ethers.getContractFactory("HeroContract");
  const box = await upgrades.deployProxy(Box, []);
  await box.deployed();
  console.log("Box deployed to:", box.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })


  