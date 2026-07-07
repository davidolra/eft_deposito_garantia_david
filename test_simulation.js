import hre from "hardhat";
import assert from "node:assert/strict";

async function main() {
  const connection = await hre.network.getOrCreate();
  const ethers = connection.ethers;

  console.log("====================================================");
  console.log("SIMULACION DE FLUJO: DEPOSITOGARANTIA (ESCROW)");
  console.log("====================================================\n");

  const [deployer, comprador, vendedor, arbitro, tercero] = await ethers.getSigners();
  const precioActivo = ethers.parseEther("1.0");

  const DepositoGarantia = await ethers.getContractFactory("DepositoGarantia");

  async function desplegar() {
    const escrow = await DepositoGarantia.deploy(
      comprador.address,
      vendedor.address,
      arbitro.address,
      precioActivo
    );
    await escrow.waitForDeployment();
    return escrow;
  }

  // ---------------------------------------------------------
  // ESCENARIO A: Flujo feliz (deposito + confirmacion)
  // ---------------------------------------------------------
  console.log("ESCENARIO A: Flujo feliz (deposito + confirmacion)");
  let escrow = await desplegar();
  console.log("Contrato desplegado en:", await escrow.getAddress());

  await (await escrow.connect(comprador).depositarFondos({ value: precioActivo })).wait();
  assert.equal(await escrow.fondosDepositados(), true, "fondosDepositados deberia ser true");
  console.log("  Deposito OK. fondosDepositados =", await escrow.fondosDepositados());

  const balVendedorAntes = await ethers.provider.getBalance(vendedor.address);
  await (await escrow.connect(comprador).confirmarRecepcion()).wait();
  const balVendedorDespues = await ethers.provider.getBalance(vendedor.address);

  assert.equal(Number(await escrow.estadoActual()), 1, "Estado deberia ser Completado (1)");
  assert.equal(
    ethers.formatEther(balVendedorDespues - balVendedorAntes),
    "1.0",
    "El vendedor deberia recibir exactamente el precio del activo"
  );
  console.log("  Estado final:", Number(await escrow.estadoActual()), "(1 = Completado)");
  console.log("  Vendedor recibio:", ethers.formatEther(balVendedorDespues - balVendedorAntes), "ETH\n");

  // ---------------------------------------------------------
  // ESCENARIO B: Depositar con monto incorrecto (debe revertir)
  // ---------------------------------------------------------
  console.log("ESCENARIO B: Deposito con monto incorrecto (debe revertir)");
  escrow = await desplegar();
  await assert.rejects(
    escrow.connect(comprador).depositarFondos({ value: ethers.parseEther("0.5") }),
    /Monto enviado no coincide con el precio del activo/,
    "Deberia revertir por monto incorrecto"
  );
  console.log("  Rechazado correctamente.\n");

  // ---------------------------------------------------------
  // ESCENARIO C: Un tercero intenta depositar (debe revertir)
  // ---------------------------------------------------------
  console.log("ESCENARIO C: Un tercero intenta depositar (debe revertir)");
  await assert.rejects(
    escrow.connect(tercero).depositarFondos({ value: precioActivo }),
    /Solo el comprador puede ejecutar esta accion/,
    "Deberia revertir porque el emisor no es el comprador"
  );
  console.log("  Rechazado correctamente.\n");

  // ---------------------------------------------------------
  // ESCENARIO D: Disputa resuelta a favor del vendedor
  // ---------------------------------------------------------
  console.log("ESCENARIO D: Disputa resuelta a favor del vendedor");
  escrow = await desplegar();
  await (await escrow.connect(comprador).depositarFondos({ value: precioActivo })).wait();
  await (await escrow.connect(vendedor).iniciarDisputa("El comprador no confirma sin motivo")).wait();
  assert.equal(Number(await escrow.estadoActual()), 2, "Estado deberia ser Disputa (2)");
  console.log("  Estado tras iniciar disputa:", Number(await escrow.estadoActual()), "(2 = Disputa)");

  const balVendedorAntesD = await ethers.provider.getBalance(vendedor.address);
  await (await escrow.connect(arbitro).resolverDisputa(true)).wait();
  const balVendedorDespuesD = await ethers.provider.getBalance(vendedor.address);

  assert.equal(Number(await escrow.estadoActual()), 1, "Estado deberia ser Completado (1)");
  console.log("  Estado final:", Number(await escrow.estadoActual()), "(1 = Completado)");
  console.log("  Vendedor recibio en disputa:", ethers.formatEther(balVendedorDespuesD - balVendedorAntesD), "ETH\n");

  // ---------------------------------------------------------
  // ESCENARIO E: Disputa resuelta a favor del comprador (reembolso)
  // ---------------------------------------------------------
  console.log("ESCENARIO E: Disputa resuelta a favor del comprador (reembolso)");
  escrow = await desplegar();
  await (await escrow.connect(comprador).depositarFondos({ value: precioActivo })).wait();
  await (await escrow.connect(comprador).iniciarDisputa("El vendedor no entrego el activo")).wait();

  const balCompradorAntes = await ethers.provider.getBalance(comprador.address);
  const txResolver = await escrow.connect(arbitro).resolverDisputa(false);
  await txResolver.wait();
  const balCompradorDespues = await ethers.provider.getBalance(comprador.address);

  assert.equal(Number(await escrow.estadoActual()), 3, "Estado deberia ser Reembolsado (3)");
  console.log("  Estado final:", Number(await escrow.estadoActual()), "(3 = Reembolsado)");
  console.log("  Comprador reembolsado:", ethers.formatEther(balCompradorDespues - balCompradorAntes), "ETH\n");

  // ---------------------------------------------------------
  // ESCENARIO F: Un tercero intenta resolver la disputa (debe revertir)
  // ---------------------------------------------------------
  console.log("ESCENARIO F: Un tercero (no arbitro) intenta resolver la disputa (debe revertir)");
  escrow = await desplegar();
  await (await escrow.connect(comprador).depositarFondos({ value: precioActivo })).wait();
  await (await escrow.connect(comprador).iniciarDisputa("Prueba de autorizacion")).wait();
  await assert.rejects(
    escrow.connect(tercero).resolverDisputa(true),
    /OwnableUnauthorizedAccount/,
    "Deberia revertir porque el emisor no es el arbitro (owner)"
  );
  console.log("  Rechazado correctamente.\n");

  // ---------------------------------------------------------
  // ESCENARIO G: Rechazo de transferencia directa (sin depositarFondos)
  // ---------------------------------------------------------
  console.log("ESCENARIO G: Rechazo de transferencia directa (sin pasar por depositarFondos)");
  escrow = await desplegar();
  await assert.rejects(
    comprador.sendTransaction({ to: await escrow.getAddress(), value: precioActivo }),
    /Transaccion directa rechazada/,
    "Deberia revertir la transferencia directa"
  );
  console.log("  Rechazado correctamente.\n");

  console.log("====================================================");
  console.log("TODOS LOS ESCENARIOS SE EJECUTARON CORRECTAMENTE");
  console.log("====================================================");
}

main().catch((error) => {
  console.error("Error en la simulacion:", error);
  process.exitCode = 1;
});
