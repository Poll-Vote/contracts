require('dotenv').config()
const hre = require('hardhat')

async function main() {
  const ethers = hre.ethers
  const upgrades = hre.upgrades;

  console.log('network:', await ethers.provider.getNetwork())

  const signer = (await ethers.getSigners())[0]
  console.log('signer:', await signer.getAddress())
  
  

  /**
   * Upgrade SpaceFactory
   */
   const SpaceFactoryAddress = "0x9fd95b0dc0a42d8adf5855fed985a5b290ba2e53";

   const SpaceFactoryV2 = await ethers.getContractFactory('SpaceFactory', {
     signer: (await ethers.getSigners())[0]
   })

   const upgradedContract = await upgrades.upgradeProxy(SpaceFactoryAddress, SpaceFactoryV2);
   console.log('SpaceFactory upgraded: ', upgradedContract.address)

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
