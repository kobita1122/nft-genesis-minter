const hre = require("hardhat");

// Usage: npx hardhat run mint.js --network localhost
async function main() {
    const CONTRACT_ADDRESS = "0x..."; // Replace after deploy
    const MINT_QTY = 1;
    const PRICE = hre.ethers.parseEther("0.05");

    const nft = await hre.ethers.getContractAt("GenesisNFT", CONTRACT_ADDRESS);
    
    // Check if sale is active, if not, activate it (Owner only)
    const isActive = await nft.isPublicSaleActive();
    if (!isActive) {
        console.log("Activating sale...");
        const tx = await nft.toggleSale();
        await tx.wait();
    }

    console.log(`Minting ${MINT_QTY} NFT(s)...`);
    const tx = await nft.mint(MINT_QTY, { value: PRICE });
    await tx.wait();
    
    console.log("Mint successful!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
