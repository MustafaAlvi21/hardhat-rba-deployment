/**
 * UPGRADEABLE DEPLOYMENT
 */
async function main() {
  const Curve_CDP = await ethers.getContractFactory("Curve_CDP")
  console.log("Deploying Curve_CDP, ProxyAdmin, and then Proxy...")
  const proxy = await upgrades.deployProxy(Curve_CDP)
  console.log("Proxy of Curve_CDP deployed to:", proxy.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

// 0x2c6Cf57D73e13F9AE9D1f774C421558A607cCb27
// C:\Users\Alvi\Desktop\upgrade2\smartcontract-upgrades-example>npx hardhat run --network binance scripts/deploy.js
// Deploying Box, ProxyAdmin, and then Proxy...
// Proxy of Box deployed to: 0x2c6Cf57D73e13F9AE9D1f774C421558A607cCb27
// for upgrading use upgrade.js not prepare-upgrade.js





/**
 * SIMPLE DEPLOYMENT
 */
// async function main() {
//   const [deployer] = await ethers.getSigners();

//   console.log("Deploying contracts with the account:", deployer.address);

//   console.log("Account balance:", (await deployer.getBalance()).toString());

//   const Token = await ethers.getContractFactory("RedPanda");
//   const token = await Token.deploy();

//   console.log("Token address:", token.address);
// }

// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });