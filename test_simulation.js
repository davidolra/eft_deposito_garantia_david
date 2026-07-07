import hre from "hardhat";

async function main() {
  const connection = await hre.network.getOrCreate();
  const ethers = connection.ethers;

  console.log("====================================================");
  console.log("🚀 SIMULACIÓN DE FLUJO: DEPOSITOGARANTIA (ESCROW)");
  console.log("====================================================\n");

  const [deployer, comprador, vendedor, arbitro] = await ethers.getSigners();
  const precioActivo = ethers.parseEther("1.0"); // 1 ETH

  // 1. Despliegue del Contrato
  console.log("1. Desplegando el contrato con el Árbitro como Owner...");
  const DepositoGarantia = await ethers.getContractFactory("DepositoGarantia");
  const escrow = await DepositoGarantia.deploy(
    comprador.address,
    vendedor.address,
    arbitro.address,
    precioActivo
  );
  await escrow.waitForDeployment();
  const contractAddress = await escrow.getAddress();
  console.log(`✔️  Contrato desplegado en: ${contractAddress}`);
  console.log(`   - Comprador: ${comprador.address}`);
  console.log(`   - Vendedor: ${vendedor.address}`);
  console.log(`   - Árbitro (Owner): ${arbitro.address}\n`);

  // NOTA: Para realizar la simulación, el contrato debe estar completado.
  // Dado que es un boilerplate con TODOs, explicamos cómo funcionará una vez completado.
  console.log("📝 NOTA ACADÉMICA:");
  console.log("Este script interactúa con el contrato DepositoGarantia.sol.");
  console.log("Una vez que completes los TODOs en el código Solidity, este script");
  console.log("podrá ejecutar la simulación completa sin revertir transacciones.");
  console.log("----------------------------------------------------\n");

  console.log("2. Simulación de Depósito (Comprador -> Contrato)...");
  console.log("   Llamando a depositarFondos() con 1.0 ETH desde la wallet del comprador...");
  
  try {
    // Intentamos hacer el depósito
    const tx = await escrow.connect(comprador).depositarFondos({ value: precioActivo });
    await tx.wait();
    console.log("✔️  Fondos depositados exitosamente.");
  } catch (error) {
    console.log("⚠️  El depósito fue revertido.");
    console.log("   Razón: Es probable que los TODOs del contrato aún no estén implementados.");
    console.log(`   Detalle del error: ${error.message.split("\n")[0]}\n`);
    return;
  }

  // 3. Simulación de Confirmación de Recepción
  console.log("3. Confirmación de Recepción del activo físico...");
  try {
    const txConfirm = await escrow.connect(comprador).confirmarRecepcion();
    await txConfirm.wait();
    console.log("✔️  Recepción confirmada. Fondos liberados al vendedor.");
    
    const estado = await escrow.estadoActual();
    console.log(`   Estado final del contrato: ${estado} (1 = Completado)\n`);
  } catch (error) {
    console.log("⚠️  La confirmación falló.");
    console.log(`   Detalle: ${error.message.split("\n")[0]}\n`);
  }
}

main().catch((error) => {
  console.error("Error en la simulación:", error);
  process.exitCode = 1;
});
