import hre from "hardhat";

async function main() {
  const connection = await hre.network.getOrCreate("sepolia");
  const ethers = connection.ethers;

  console.log("====================================================");
  console.log("Desplegando DepositoGarantia en Sepolia (testnet)...");
  console.log("====================================================");

  const [deployer] = await ethers.getSigners();
  console.log("Cuenta que despliega:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Balance disponible:", ethers.formatEther(balance), "ETH");
  if (balance === 0n) {
    console.log("ADVERTENCIA: la cuenta no tiene ETH de Sepolia. Consigue fondos en un faucet");
    console.log("como https://sepoliafaucet.com o https://www.alchemy.com/faucets/ethereum-sepolia");
  }

  // ---------------------------------------------------------
  // CONFIGURAR AQUI los datos reales del acuerdo antes de desplegar
  // ---------------------------------------------------------
  const comprador = process.env.DIRECCION_COMPRADOR || deployer.address;
  const vendedor = process.env.DIRECCION_VENDEDOR || deployer.address;
  const arbitro = process.env.DIRECCION_ARBITRO || deployer.address;
  const precioActivo = ethers.parseEther(process.env.PRECIO_ACTIVO_ETH || "0.01");

  console.log("\nParametros de inicializacion:");
  console.log("- Comprador:", comprador);
  console.log("- Vendedor:", vendedor);
  console.log("- Arbitro (Owner):", arbitro);
  console.log("- Precio Activo:", ethers.formatEther(precioActivo), "ETH");
  console.log("----------------------------------------------------");

  const DepositoGarantia = await ethers.getContractFactory("DepositoGarantia");
  const escrow = await DepositoGarantia.deploy(comprador, vendedor, arbitro, precioActivo);
  await escrow.waitForDeployment();

  const contractAddress = await escrow.getAddress();
  const deployTx = escrow.deploymentTransaction();

  console.log("\nContrato desplegado con exito!");
  console.log("Direccion del contrato:", contractAddress);
  console.log("Hash de la transaccion de despliegue:", deployTx ? deployTx.hash : "N/A");
  console.log("\nVerificalo en el explorador:");
  console.log(`https://sepolia.etherscan.io/address/${contractAddress}`);
  console.log("\nPega esta direccion en el campo 'Direccion del contrato desplegado' de frontend/index.html");
  console.log("\nPara verificar el codigo fuente en Etherscan, corre:");
  console.log(
    `npx hardhat verify --network sepolia ${contractAddress} "${comprador}" "${vendedor}" "${arbitro}" "${precioActivo}"`
  );
  console.log("(Necesitas ETHERSCAN_API_KEY configurado en tu .env)");
  console.log("====================================================");
}

main().catch((error) => {
  console.error("Error durante el despliegue:", error);
  process.exitCode = 1;
});
