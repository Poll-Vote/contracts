require('dotenv').config()
const hre = require('hardhat')

const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay * 1000));

async function main() {
  const ethers = hre.ethers
  const upgrades = hre.upgrades;

  console.log('network:', await ethers.provider.getNetwork());

  const signer = (await ethers.getSigners())[0];
  console.log('signer:', await signer.getAddress());

  const feeAddress = process.env.FEE_ADDRESS;
  const tokenAddress = process.env.TOKEN_ADDRESS;
  

  /**
   *  Deploy SpaceFactory
   */
  
  const SpaceFactory = await ethers.getContractFactory('SpaceFactory', {
    signer: (await ethers.getSigners())[0]
  });
  const spaceFactoryContract = await upgrades.deployProxy(SpaceFactory, [feeAddress,tokenAddress], { initializer: 'initialize' });
  await spaceFactoryContract.deployed()

  console.log('SpaceFactory proxy deployed: ', spaceFactoryContract.address)

  spaceFactoryImplementation = await upgrades.erc1967.getImplementationAddress(spaceFactoryContract.address);
  console.log('SpaceFactory Implementation address: ', spaceFactoryImplementation)

  await sleep(60);
  
  // Verify SpaceFactory
  try {
    await hre.run('verify:verify', {
      address: spaceFactoryImplementation,
      constructorArguments: []
    })
    console.log('SpaceFactory verified')
  } catch (error) {
    console.log('SpaceFactory verification failed : ', error)
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
