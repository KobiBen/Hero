// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");
const BOX_ADDRESS = "0x0B3E4A623d1c68AE0Ac996782b55Dabbf9A02A70"

async function main() {
  const BoxV2 = await ethers.getContractFactory("HeroContract");
  const box = await upgrades.upgradeProxy(BOX_ADDRESS, BoxV2);
  console.log("Box upgraded: ");
}

main();