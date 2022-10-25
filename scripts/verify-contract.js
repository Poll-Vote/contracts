require('dotenv').config()
const hre = require('hardhat')

const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay * 1000));

async function main() {
  const ethers = hre.ethers;
  
  console.log('network:', await ethers.provider.getNetwork())

  const signer = (await ethers.getSigners())[0]
  console.log('signer:', await signer.getAddress())

  const contractAddress = '0x174452f2686678Dcb98f312C892D0EF1C0AE1F0F';

  // Verify Contract
  try {
    await hre.run('verify:verify', {
      address: contractAddress,
      constructorArguments: []
    })
    console.log('verified')
  } catch (error) {
    console.log('verification failed : ', error)
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
