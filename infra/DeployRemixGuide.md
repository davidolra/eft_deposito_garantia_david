# Guía de Despliegue e Interacción en Remix IDE

Esta guía detalla el flujo paso a paso para compilar, desplegar e interactuar con el contrato inteligente [`DepositoGarantia.sol`](./src/DepositoGarantia.sol) utilizando **Remix IDE** y el entorno de simulación **Remix VM**.

---

## 🛠️ Paso 1: Cargar el Contrato en Remix IDE

1. Abra [Remix IDE](https://remix.ethereum.org/) en su navegador.
2. En el explorador de archivos (*File Explorer*), cree un nuevo archivo dentro de la carpeta `contracts/` y nómbrelo `DepositoGarantia.sol`.
3. Copie y pegue todo el contenido del archivo [`DepositoGarantia.sol`](./src/DepositoGarantia.sol) en el archivo recién creado en Remix.

---

## ⚙️ Paso 2: Compilación del Contrato

1. Diríjase a la pestaña **Solidity Compiler** (icono de compilador en la barra lateral izquierda).
2. Seleccione la versión del compilador **`0.8.20`** (o superior).
3. Asegúrese de que la configuración de optimización esté habilitada si desea replicar la configuración de Hardhat, aunque no es estrictamente necesario para la simulación local.
4. Presione el botón **Compile DepositoGarantia.sol**.
5. Verifique que aparezca el check verde indicando que la compilación fue exitosa.

---

## 🚀 Paso 3: Despliegue en Remix VM (Máquina Virtual)

Para simular el flujo completo del contrato de depósito en garantía, se requieren **tres direcciones diferentes** (wallets virtuales proporcionadas por Remix) y definir el monto en Wei.

1. Diríjase a la pestaña **Deploy & Run Transactions** (icono de Ethereum en la barra lateral izquierda).
2. En la opción **Environment**, asegúrese de seleccionar **Remix VM (Shanghai)** o **Remix VM (Cancun)**. Esto le proporcionará 10 cuentas de prueba con 100 ETH cada una.
3. **Identifique las cuentas a utilizar**:
   - Seleccione la primera cuenta de la lista y copie su dirección. Esta será la cuenta del **Comprador** (e.g., `0x5B3...`).
   - Seleccione la segunda cuenta, copie su dirección. Esta será la cuenta del **Vendedor** (e.g., `0xAb8...`).
   - Seleccione la tercera cuenta, copie su dirección. Esta será la cuenta del **Árbitro** (que actuará como propietario/owner, e.g., `0x4B2...`).
4. **Configurar el Constructor**:
   - En el menú desplegable del contrato, seleccione `DepositoGarantia`.
   - Expanda el botón naranja **Deploy** haciendo clic en la flecha de la derecha para ver los campos del constructor.
   - Complete los campos con las direcciones copiadas:
     - `_comprador`: Dirección del Comprador.
     - `_vendedor`: Dirección del Vendedor.
     - `_arbitro`: Dirección del Árbitro.
     - `_precioActivo`: El precio en Wei (por ejemplo, para 1 Ether ingrese `1000000000000000000`).
5. Asegúrese de tener seleccionada la cuenta del **Árbitro** (u otra cuenta de su preferencia, pero el árbitro/owner es quien despliega en este ejemplo pedagógico) en el campo **Account** principal.
6. Haga clic en **Transact**. El contrato se desplegará y aparecerá bajo **Deployed Contracts** en la parte inferior de la pestaña lateral.

---

## 🔄 Paso 4: Flujo de Interacción y Pruebas

### Escenario A: Flujo Exitoso (Depósito y Confirmación)
1. **Depositar Fondos (Comprador)**:
   - Seleccione la cuenta del **Comprador** en el campo **Account**.
   - Defina el campo **Value** de Remix para que coincida exactamente con el precio configurado (por ejemplo, cambie la unidad a `Ether` y escriba `1`, o en `Wei` y escriba `1000000000000000000`).
   - Expanda el contrato desplegado y haga clic en el botón rojo **depositarFondos**.
   - Verifique en la consola que la transacción fue exitosa y que el estado de `fondosDepositados` cambió a `true`.
2. **Confirmar Recepción y Liberar Fondos (Comprador)**:
   - Manteniendo seleccionada la cuenta del **Comprador** en **Account**.
   - Asegúrese de que el campo **Value** esté en `0` (ya no se requiere enviar fondos).
   - Haga clic en el botón **confirmarRecepcion**.
   - Verifique en la consola el éxito de la transacción. El balance del contrato pasará a ser `0` y el balance de la cuenta del **Vendedor** se habrá incrementado.
   - El estado de `estadoActual` pasará a ser `1` (que corresponde a `Estado.Completado`).

### Escenario B: Resolución de Disputa por el Árbitro
1. **Iniciar Disputa (Comprador o Vendedor)**:
   - Realice el paso 1 del Escenario A (Depositar fondos con el Comprador).
   - Seleccione la cuenta del **Comprador** o del **Vendedor**.
   - En el campo junto a **iniciarDisputa**, introduzca un texto de motivo (ej. `"El activo no cumple con las condiciones acordadas"`).
   - Haga clic en **iniciarDisputa**. El `estadoActual` cambiará a `2` (que corresponde a `Estado.Disputa`).
2. **Resolver Disputa (Árbitro/Owner)**:
   - Seleccione la cuenta del **Árbitro** en el campo **Account**. Solo el propietario/árbitro puede llamar a esta función.
   - En el campo junto a **resolverDisputa**, asigne la resolución:
     - Escriba `true` si desea transferir los fondos al vendedor.
     - Escriba `false` si desea reembolsar los fondos al comprador.
   - Haga clic en **resolverDisputa**. El balance del contrato se transferirá al destinatario respectivo y el `estadoActual` cambiará a `Completado` (`1`) o `Reembolsado` (`3`).
