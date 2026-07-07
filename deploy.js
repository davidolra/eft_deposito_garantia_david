import hre from "hardhat";

async function main() {
  const connection = await hre.network.getOrCreate();
  const ethers = connection.ethers;

  // Obtener las cuentas del entorno local (Hardhat Network proporciona 20 cuentas con saldo ficticio)
  const [deployer, comprador, vendedor, arbitro] = await ethers.getSigners();

  console.log("====================================================");
  console.log("Iniciando despliegue de DepositoGarantia...");
  console.log("Desplegador (Deployer):", deployer.address);
  console.log("====================================================");

  // Definir el precio del activo físico (Ejemplo: 1.5 Ether representados en Wei)
  // --- MARCADOR RÚBRICA: IE5 (Unidades de valor en Ethereum) ---
  const precioActivo = ethers.parseEther("1.5"); 

  console.log("Parámetros de inicialización:");
  console.log("- Comprador:", comprador.address);
  console.log("- Vendedor:", vendedor.address);
  console.log("- Árbitro (Propietario/Owner):", arbitro.address);
  console.log("- Precio Activo:", ethers.formatEther(precioActivo), "ETH");
  console.log("----------------------------------------------------");

  // Obtener la fábrica del contrato DepositoGarantia
  const DepositoGarantia = await ethers.getContractFactory("DepositoGarantia");

  // Desplegar el contrato pasando los parámetros definidos al constructor
  // NOTA: El árbitro se define aquí para el rol 'Ownable' del contrato.
  const escrow = await DepositoGarantia.deploy(
    comprador.address,
    vendedor.address,
    arbitro.address,
    precioActivo
  );

  // Esperar a que se confirme el minado del bloque de despliegue
  await escrow.waitForDeployment();

  const contractAddress = await escrow.getAddress();
  console.log("¡Contrato desplegado con éxito!");
  console.log("Dirección de contrato Escrow:", contractAddress);
  console.log("====================================================");
  console.log("Instrucciones para probar en local:");
  console.log(`1. Iniciar nodo local: npx hardhat node`);
  console.log(`2. Correr script: npx hardhat run deploy.js --network localhost`);
}

main().catch((error) => {
  console.error("Error durante el despliegue:", error);
  process.exitCode = 1;
});
