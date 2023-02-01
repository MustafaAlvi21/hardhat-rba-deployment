async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("RoburnaDividendTracker");
  const token = await Token.deploy("0xD7da2A0e9880315b0779C886AEe73291d65E80Ca", "0xD7da2A0e9880315b0779C886AEe73291d65E80Ca");

  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });