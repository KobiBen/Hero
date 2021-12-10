# Hero
Other Project


npm install on main folder and on /web folder

to run web use:

yarn serve;

to deploy new contract:
npx hardhat run scripts/deploy.js --network

to update exisiting contract on rinkeby:
npx hardhat run .\scripts\upgrade.js - (this will compile the HeroContract if there are any changes an push the new block to this address: 0x0B3E4A623d1c68AE0Ac996782b55Dabbf9A02A70 (https://rinkeby.etherscan.io/address/0x0B3E4A623d1c68AE0Ac996782b55Dabbf9A02A70)
