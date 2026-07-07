# Guía del Estudiante: EFT Sistema de Depósito en Garantía (Escrow)

**Curso:** Fundamentos de Blockchain (BCY0010)  
**Evaluación:** Evaluación Final Transversal (EFT)

---

## 1. Introducción al Caso de Uso

El proyecto consiste en un **Sistema de Depósito en Garantía (Escrow)** automatizado mediante un Contrato Inteligente para la compraventa de activos físicos de alto valor (como bienes raíces o vehículos) en Chile. 
En un escenario tradicional, la compra de un auto o una propiedad requiere de un tercero de confianza (notaría, instrucciones notariales o vale vista bancario) para asegurar que el comprador no entregue el dinero sin recibir el activo, y que el vendedor no entregue el activo sin asegurar el pago. 

Este contrato inteligente reemplaza la custodia física del dinero por una custodia criptográfica en la blockchain, donde:
1. El **Comprador** deposita el valor acordado en el contrato.
2. El contrato retiene los fondos.
3. Si la entrega del activo físico se realiza con éxito, el **Comprador** confirma la recepción, liberando los fondos al **Vendedor**.
4. Si surge un conflicto (ej. el vehículo tiene fallas ocultas o no se entrega la propiedad), cualquiera de las partes puede iniciar una **Disputa**.
5. Un **Árbitro** (un tercero de confianza neutral, que actúa como el propietario o `owner` del contrato) revisa la situación off-chain y resuelve la disputa transfiriendo el dinero al vendedor o reembolsándolo al comprador.

---

## 2. Alineación con los Indicadores de Evaluación (Rúbrica BCY0010)

### 📊 IE5: Wallets, Criptografía y Gestión de Llaves
*   **Concepto clave:** Los estudiantes deben comprender que en Ethereum y EVM, las identidades son representadas por direcciones públicas (`address`). 
*   **En el Código:** Las variables `comprador`, `vendedor` y `owner` (árbitro) almacenan las direcciones de sus respectivas wallets. Cada interacción con el contrato requiere la firma digital de una transacción utilizando la clave privada del usuario (mediante wallets como MetaMask o la cuenta local en Remix VM).
*   **Pregunta de defensa individual típica:** *¿Cómo sabe el contrato inteligente que la transacción proviene realmente del comprador y no de un impostor?*  
    *Respuesta:* Gracias a la criptografía de curva elíptica (ECDSA). La transacción es firmada digitalmente con la clave privada de la wallet del comprador, y el nodo de la red blockchain la verifica, poblando la variable global `msg.sender` con la dirección pública correspondiente.

### 🔒 IE6: Buenas Prácticas de Programación y Auditoría
*   **Concepto clave:** Uso de estándares industriales y mitigación de vulnerabilidades conocidas.
*   **En el Código:** 
    *   **OpenZeppelin `Ownable.sol`:** En lugar de reescribir la lógica de autorización del administrador, heredamos de una librería auditada y mantenida por la comunidad. Esto asegura que el rol de `owner` (Árbitro) esté protegido con las mejores prácticas.
    *   **OpenZeppelin `ReentrancyGuard.sol`:** El modificador `nonReentrant` en `confirmarRecepcion()` y `resolverDisputa()` bloquea intentos de ataques de reentrada (reentrancy). Este ataque ocurre cuando un contrato receptor malicioso vuelve a llamar a la función de retiro antes de que el contrato de escrow actualice su balance o estado interno, logrando drenar todos los fondos.
    *   **Patrón Checks-Effects-Interactions (Verificaciones-Efectos-Interacciones):** En `confirmarRecepcion()`, primero validamos condiciones (`require`), luego actualizamos el estado interno del contrato (`estadoActual = Estado.Completado`), y finalmente interactuamos con el exterior (llamando a `vendedor.call{value: ...}`). Esto previene vulnerabilidades lógicas.

### 💻 IE7: Lógica Programable y Estructura del Contrato
*   **Concepto clave:** Estructura limpia de Solidity, variables de estado, enums, modificadores y flujo del programa.
*   **En el Código:** El contrato utiliza una máquina de estados representada por `enum Estado` (`Pendiente`, `Completado`, `Disputa`, `Reembolsado`). Los estudiantes deben rellenar modificadores lógicos (`onlyComprador`, `onlyVendedor`, `inEstado`) y completar la lógica del flujo del dinero usando `require` y condicionales.

### ⚖️ IE11: Aspectos Normativos, Éticos y Legales (Chile)
*   **Ley de Protección de Datos Personales (Ley N° 19.628 / Modernización):** La blockchain es pública e inmutable. Almacenar datos como el RUT de los involucrados, nombres completos, la patente del auto o el rol del inmueble en el contrato violaría gravemente la ley de protección de datos, ya que no se podría cumplir con el **Derecho de Supresión (Derecho al Olvido)** de los datos una vez finalizado el contrato. La buena práctica ética consiste en mantener los datos personales en servidores privados tradicionales y registrar en la blockchain únicamente la firma criptográfica o un hash del acuerdo.
*   **Ley Fintech (Ley N° 21.521 - Chile):** Al custodiar dinero digital temporalmente en un contrato inteligente de forma automatizada, los estudiantes deben reflexionar si la plataforma que aloja este servicio requiere regulación por parte de la Comisión para el Mercado Financiero (CMF) bajo el régimen de "Servicios de Custodia de Instrumentos Financieros o Criptoactivos" o "Sistemas Alternativos de Transacción".
*   **Dilema Ético del "Código es Ley" (Code is Law):** ¿Qué ocurre si el contrato inteligente tiene un error que bloquea los fondos para siempre? En el derecho chileno, los contratos tradicionales permiten la teoría de la imprevisión o la rescisión mutua. En un smart contract puro sin árbitro, la inmutabilidad puede causar injusticias éticas y pérdidas financieras irreparables. Por ello, la inclusión de un Árbitro humano como rol de confianza en el contrato es una decisión de diseño ética y pragmática.

---

## 3. Guía de Soluciones para los TODOs (Para el Alumno / Docente)

A continuación se detalla cómo el alumno debe completar cada uno de los 10 bloques `TODO` en `DepositoGarantia.sol`:

### **TODO 1: Modificador `onlyComprador`**
*   **Código esperado:**
    ```solidity
    require(msg.sender == comprador, "Solo el comprador puede ejecutar esta accion");
    ```

### **TODO 2: Modificador `onlyVendedor`**
*   **Código esperado:**
    ```solidity
    require(msg.sender == vendedor, "Solo el vendedor puede ejecutar esta accion");
    ```

### **TODO 3: Modificador `inEstado`**
*   **Código esperado:**
    ```solidity
    require(estadoActual == _estadoEsperado, "Estado del contrato no valido para esta operacion");
    ```

### **TODO 4 & 5: Función `depositarFondos`**
*   **Código esperado:**
    ```solidity
    require(!fondosDepositados, "Fondos ya fueron depositados");
    require(msg.value == precioActivo, "Monto enviado no coincide con el precio del activo");
    ```

### **TODO 6: Función `confirmarRecepcion`**
*   **Código esperado:**
    ```solidity
    require(fondosDepositados, "Los fondos no han sido depositados");
    ```

### **TODO 7 & 8: Función `iniciarDisputa`**
*   **Código esperado:**
    ```solidity
    require(msg.sender == comprador || msg.sender == vendedor, "No autorizado");
    require(fondosDepositados, "Los fondos deben estar depositados");
    ```

### **TODO 9 & 10: Función `resolverDisputa`**
*   **Código esperado:**
    ```solidity
    if (_favorVendedor) {
        destinatario = vendedor;
        estadoActual = Estado.Completado;
    } else {
        destinatario = comprador;
        estadoActual = Estado.Reembolsado;
    }

    uint256 montoTransferir = address(this).balance;
    (bool exito, ) = payable(destinatario).call{value: montoTransferir}("");
    require(exito, "Error al transferir los fondos");
    ```

---

## 4. Guía Práctica de Pruebas en Remix IDE

Para probar este boilerplate sin lidiar con configuraciones complejas de Node.js, los alumnos pueden seguir estos pasos:

1.  **Abrir Remix IDE:** Ir a [remix.ethereum.org](https://remix.ethereum.org).
2.  **Crear el Archivo:** Crear un archivo llamado `DepositoGarantia.sol` en la carpeta `contracts`.
3.  **Pegar y Compilar:** Pegar el código del boilerplate, seleccionar la versión del compilador `0.8.20` o superior y hacer clic en **Compile**.
4.  **Simular en Remix VM:**
    *   Ir a la pestaña **Deploy & Run Transactions**.
    *   Remix proporciona 10 cuentas de prueba con 100 Ether cada una.
    *   **Definir Direcciones:**
        *   Selecciona la Cuenta 1 como el **Comprador** (copia su dirección).
        *   Selecciona la Cuenta 2 como el **Vendedor** (copia su dirección).
        *   Selecciona la Cuenta 3 como el **Árbitro** (copia su dirección).
    *   **Desplegar:**
        *   En el botón de despliegue, ingresa los parámetros del constructor:
            *   `_comprador`: Dirección Cuenta 1
            *   `_vendedor`: Dirección Cuenta 2
            *   `_arbitro`: Dirección Cuenta 3
            *   `_precioActivo`: `1000000000000000000` (1 Ether en Wei, o cualquier valor numérico).
        *   Asegúrate de estar en la Cuenta 3 (Árbitro) al hacer clic en **Deploy** (o cualquier cuenta, pero el Árbitro será el dueño del contrato).
5.  **Ejecutar el Flujo:**
    *   **Depósito:** Cambia a la Cuenta 1 (Comprador). En el campo **Value** del panel superior de Remix, escribe `1` y selecciona la unidad `Ether`. Luego presiona el botón `depositarFondos`.
    *   **Verificar Balance:** Llama al método público `fondosDepositados` o revisa el saldo del contrato (debería mostrar 1 Ether).
    *   **Liberación Directa:** (Flujo Feliz) Con la Cuenta 1 (Comprador) seleccionada, haz clic en `confirmarRecepcion`. Verifica que el saldo de la Cuenta 2 (Vendedor) aumentó en 1 Ether y que `estadoActual` cambió a `1` (Completado).
    *   **Flujo con Disputa:** (Alternativo) Despliega un nuevo contrato. Repite el depósito con la Cuenta 1. Luego selecciona la Cuenta 1 o Cuenta 2 y haz clic en `iniciarDisputa` ingresando un motivo (ej: "No recibí la propiedad"). El estado del contrato cambiará a `2` (Disputa).
    *   **Resolución:** Cambia a la Cuenta 3 (Árbitro/Propietario). Llama a `resolverDisputa` con valor `false` (para reembolsar al comprador) o `true` (para pagar al vendedor). Verifica el saldo del destinatario correspondiente.
