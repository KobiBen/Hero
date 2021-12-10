async function main() {
  const Hero = await ethers.getContractFactory("HeroContract")

  // Start deployment, returning a promise that resolves to a contract object
  const hero = await Hero.deploy()
  console.log("Contract deployed to address:", hero.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
