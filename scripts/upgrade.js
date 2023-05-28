async function main() {
    const BoxV2 = await ethers.getContractFactory("BURNER_2")
    let box = await upgrades.upgradeProxy("0x28edA866dB64E4647483226AF1Ed78a94C88945e", BoxV2)
    console.log("Your upgraded proxy is done!", box.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })


// C:\Users\Alvi\Desktop\upgrade2\smartcontract-upgrades-example>npx hardhat run --network binance scripts/upgrade.js
// Your upgraded proxy is done! 0x2c6Cf57D73e13F9AE9D1f774C421558A607cCb27

// C:\Users\Alvi\Desktop\upgrade2\smartcontract-upgrades-example>


// Steps:
// 1) update contarct name like => contract "NFT_Gurus_V2" is ERC721EnumerableUpgradeable, OwnableUpgradeable {
// 2) write down contract name in "getContractFactory"  
// 3) write down deployed contract address in "upgradeProxy"