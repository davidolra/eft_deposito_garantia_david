# Guía del Estudiante: EFT Sistema de Depósito en Garantía (Escrow)

**Curso:** Fundamentos de Blockchain (BCY0010)  
**Evaluación:** Evaluación Final Transversal (EFT)

Este repositorio contiene la plantilla base de código (*boilerplate*) para el desarrollo del **Encargo Grupal y Defensa Individual de la Evaluación Final Transversal (EFT)** del curso **Fundamentos de Blockchain (BCY0010)** de Duoc UC.

El propósito de esta plantilla es reducir la fricción técnica y el esfuerzo de codificación pura de Solidity, permitiendo que los estudiantes enfoquen sus esfuerzos en:

1. **Conceptualización y Arquitectura:** Comprender el flujo lógico de los contratos y las máquinas de estado.
2. **Cumplimiento Normativo Chileno:** Aplicar conceptos legales como la Ley Fintech (Ley N° 21.521) y la Ley de Protección de Datos Personales (Ley N° 19.628).
3. **Ética en Blockchain:** Evaluar los riesgos del lema *"Code is Law"* y diseñar mecanismos de gobernanza (rol de Árbitro).

---

## 📂 Estructura del Proyecto

El proyecto está organizado según los estándares institucionales:

*   📂 **`src/`**
    *   [`DepositoGarantia.sol`](./src/DepositoGarantia.sol): Contrato inteligente principal en Solidity `^0.8.20`. Contiene 10 marcadores `TODO` donde los alumnos deben implementar lógica básica (modificadores, `require` de control de flujo, transferencias seguras) y extensos comentarios de alineación con la rúbrica.
*   📂 **`docs/`**
    *   [`EFT_Guia_Estudiante.md`](./docs/EFT_Guia_Estudiante.md): Explicación exhaustiva del caso de uso, el mapeo detallado con los Indicadores de Evaluación (IE5, IE6, IE7, IE11) de la rúbrica institucional y la guía de soluciones paso a paso.
*   📄 [`deploy.js`](./deploy.js): Script en JavaScript para desplegar el contrato inteligente localmente usando Hardhat y Ethers.js.
*   📄 [`hardhat.config.js`](./hardhat.config.js): Archivo de configuración local para el compilador de Solidity y rutas de almacenamiento.
*   📄 [`test_simulation.js`](./test_simulation.js): Script de simulación del ciclo de vida del depósito en garantía (depósito, confirmación y resolución de disputas).

---

## 🛠️ Instrucciones de Uso Rápido

### Requerimientos del Sistema (Desarrollo Local)
*   **Node.js**: Versión 18.x o superior.
*   **npm**: Gestor de paquetes de Node (incluido con Node.js).

### Opción A: Desarrollo Nativo en Remix IDE (Recomendado para clases y entregas rápidas)
1. Ingrese a [Remix IDE](https://remix.ethereum.org).
2. Cree un nuevo archivo en el workspace llamado `DepositoGarantia.sol`.
3. Copie el contenido del archivo [`DepositoGarantia.sol`](./src/DepositoGarantia.sol) en su entorno de Remix.
4. Resuelva los comentarios marcados con `TODO` en el contrato.
5. Compile utilizando la versión del compilador `0.8.20` o superior.
6. En la pestaña de despliegue, use el simulador **Remix VM**, defina las cuentas de Comprador, Vendedor y Árbitro, y despliegue el contrato.
7. Siga los pasos detallados de prueba e interacción en la [Guía de Despliegue en Remix](./infra/DeployRemixGuide.md).

### Opción B: Desarrollo Local (Para alumnos avanzados / integración de scripts)
Para compilar y simular de forma automatizada en su máquina local:
1. Instale las dependencias del proyecto utilizando npm:
   ```bash
   npm install
   ```
2. Compile el contrato inteligente:
   ```bash
   npm run compile
   ```
3. Ejecute la simulación de pruebas en la red local de Hardhat:
   ```bash
   npm test
   ```

---

## 🎓 Resumen de Indicadores de Evaluación (Rúbrica)

| Indicador | Descripción | Implementación en este Boilerplate |
| :--- | :--- | :--- |
| **IE5** | Gestión de Wallets y Criptografía | Uso de tipos `address` públicos para identificar participantes firmantes. |
| **IE6** | Buenas Prácticas y Auditoría | Integración de `@openzeppelin` (`Ownable` y `ReentrancyGuard`) y patrón *Checks-Effects-Interactions*. |
| **IE7** | Lógica Programable | Estructura Solidity, máquina de estados (`enum Estado`), modificadores lógicos y flujos condicionales. |
| **IE11** | Aspectos Normativos y Éticos | Discusión de privacidad (Ley N° 19.628), Ley Fintech (Ley N° 21.521) y límites del *Code is Law*. |

*Consulte la guía completa en [`docs/EFT_Guia_Estudiante.md`](./docs/EFT_Guia_Estudiante.md) para preparar la defensa individual.*
