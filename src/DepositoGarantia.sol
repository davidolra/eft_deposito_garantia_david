// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Importación de librerías estándar de OpenZeppelin.
 * En Remix IDE, estas rutas se resuelven automáticamente a través de npm.
 * 
 * --- MARCADOR CONCEPTUAL RÚBRICA: IE6 (Buenas Prácticas y Auditoría) ---
 * El uso de contratos base auditados de OpenZeppelin reduce el riesgo de fallos en producción.
 * - 'Ownable' se utiliza para implementar un control de acceso robusto, asignando al Árbitro como 'owner'.
 * - 'ReentrancyGuard' proporciona protección contra ataques de reentrada (reentrancy) en transferencias de valor.
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DepositoGarantia (Escrow)
 * @author Ingeniero de Software Senior & Desarrollador Principal de Solidity
 * @notice Contrato inteligente pedagógico para el curso Fundamentos de Blockchain (BCY0010).
 * Permite realizar depósitos en garantía para la compraventa de activos físicos (bienes raíces o vehículos).
 * 
 * --- MARCADOR CONCEPTUAL RÚBRICA: IE11 (Aspectos Normativos, Éticos y Legales en Chile) ---
 * 1. Equivalencia Funcional y Ley Fintech (Ley N° 21.521):
 *    Este contrato actúa como una "custodia de fondos automatizada". Bajo el marco de la Ley Fintech chilena,
 *    las plataformas que intermedien o custodien fondos/criptoactivos de terceros deben registrarse ante la
 *    Comisión para el Mercado Financiero (CMF) y cumplir con estrictos estándares de ciberseguridad y lavado de activos (UAF).
 * 2. Protección de Datos Personales (Ley N° 19.628 y su modernización):
 *    Principio de Privacidad por Diseño (Privacy by Design). Por motivos éticos y legales, NUNCA deben almacenarse
 *    datos personales (RUT, Nombres, patentes de vehículos, roles de propiedades) en las variables de estado del contrato.
 *    La inmutabilidad de la blockchain hace imposible ejercer el "Derecho de Supresión/Olvido" (Derechos ARCO). 
 *    Solo se deben registrar los hashes o manejar los datos off-chain.
 */
contract DepositoGarantia is Ownable, ReentrancyGuard {

    // --- MARCADOR CONCEPTUAL RÚBRICA: IE5 (Criptografía, Wallets y Llaves) ---
    // Las variables 'address' representan hashes de claves públicas asociadas a wallets (ej. MetaMask).
    // Cada interacción con estas direcciones requiere una firma digital con su clave privada correspondiente.
    address public comprador;
    address public vendedor;
    uint256 public precioActivo; // Representado en wei (1 Ether = 10^18 wei)

    // --- MARCADOR CONCEPTUAL RÚBRICA: IE7 (Estructura de Contratos y Lógica Programable) ---
    // Representación de la máquina de estados del contrato.
    enum Estado { Pendiente, Completado, Disputa, Reembolsado }
    Estado public estadoActual;

    // Estado interno para rastrear si el comprador ya depositó el dinero.
    bool public fondosDepositados;

    // Eventos (Esencial para la indexación y lectura off-chain mediante The Graph o Web3.js)
    event FondosDepositados(address indexed comprador, uint256 monto);
    event RecepcionConfirmada(address indexed comprador, address indexed vendedor, uint256 montoLiberado);
    event DisputaIniciada(address indexed denunciante, string motivo);
    event DisputaResuelta(address indexed arbitro, Estado estadoFinal, address destinatarioFondos);

    // ==========================================
    // MODIFICADORES DE ACCESO (TODOs para el Alumno)
    // ==========================================

    /**
     * @dev Restringe la ejecución al Comprador.
     * --- MARCADOR CONCEPTUAL RÚBRICA: IE7 (Lógica Programable) ---
     */
    modifier onlyComprador() {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 1: Implementar la validación utilizando 'require' para asegurar que msg.sender sea igual a 'comprador'.
        // Debe lanzar un mensaje de error descriptivo: "Solo el comprador puede ejecutar esta accion".
        // Pista: require(msg.sender == comprador, "Mensaje de error");
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<
        _;
    }

    /**
     * @dev Restringe la ejecución al Vendedor.
     * --- MARCADOR CONCEPTUAL RÚBRICA: IE7 (Lógica Programable) ---
     */
    modifier onlyVendedor() {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 2: Implementar la validación con 'require' para validar que msg.sender sea el 'vendedor'.
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<
        _;
    }

    /**
     * @dev Valida que el contrato se encuentre en un estado específico.
     * --- MARCADOR CONCEPTUAL RÚBRICA: IE7 (Lógica Programable) ---
     */
    modifier inEstado(Estado _estadoEsperado) {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 3: Implementar la validación que compare 'estadoActual' con '_estadoEsperado'.
        // Mensaje de error sugerido: "Estado del contrato no valido para esta operacion".
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<
        _;
    }

    // ==========================================
    // CONSTRUCTOR
    // ==========================================

    /**
     * @dev Inicializa el contrato definiendo los roles y el precio del activo.
     * --- MARCADOR CONCEPTUAL RÚBRICA: IE6 (Control de Accesos / Inicialización Segura) ---
     * En OpenZeppelin v5, el constructor de 'Ownable' requiere la dirección del propietario inicial.
     * Aquí, el Árbitro (_arbitro) asume la propiedad del contrato ('owner') para poder resolver disputas.
     */
    constructor(
        address _comprador,
        address _vendedor,
        address _arbitro,
        uint256 _precioActivo
    ) Ownable(_arbitro) {
        // Validaciones de seguridad en el despliegue
        require(_comprador != address(0), "Comprador no puede ser la direccion cero");
        require(_vendedor != address(0), "Vendedor no puede ser la direccion cero");
        require(_arbitro != address(0), "Arbitro no puede ser la direccion cero");
        require(_comprador != _vendedor, "El comprador y el vendedor deben ser distintos");
        require(_arbitro != _comprador && _arbitro != _vendedor, "El arbitro debe ser una entidad neutral");
        require(_precioActivo > 0, "El precio del activo debe ser mayor a cero");

        comprador = _comprador;
        vendedor = _vendedor;
        precioActivo = _precioActivo;
        
        estadoActual = Estado.Pendiente;
        fondosDepositados = false;
    }

    // ==========================================
    // FUNCIONES OPERATIVAS
    // ==========================================

    /**
     * @notice Permite al comprador depositar los fondos del acuerdo en el contrato inteligente.
     * @dev Debe ser declarada como 'payable' para poder recibir Ether (o la moneda nativa de la red).
     */
    function depositarFondos() external payable onlyComprador inEstado(Estado.Pendiente) {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 4: Evitar depósitos duplicados. Validar que 'fondosDepositados' sea 'false'.
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<
        
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 5: Validar que los fondos enviados (msg.value) coincidan EXACTAMENTE con el 'precioActivo'.
        // Mensaje de error sugerido: "Monto enviado no coincide con el precio del activo".
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<

        // Cambio de estado interno
        fondosDepositados = true;

        emit FondosDepositados(msg.sender, msg.value);
    }

    /**
     * @notice Permite al comprador confirmar la recepción conforme del activo, liberando el dinero al vendedor.
     * @dev Utiliza el modificador 'nonReentrant' de ReentrancyGuard para evitar vulnerabilidades de reentrada (IE6).
     */
    function confirmarRecepcion() external onlyComprador inEstado(Estado.Pendiente) nonReentrant {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 6: Validar que los fondos hayan sido depositados previamente ('fondosDepositados' debe ser 'true').
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<

        // Actualización del estado antes de transferir (Patrón Checks-Effects-Interactions)
        estadoActual = Estado.Completado;

        uint256 montoTransferir = address(this).balance;

        // --- MARCADOR CONCEPTUAL RÚBRICA: IE7 & IE6 (Envío Seguro de Ether) ---
        // Se prefiere el uso de '.call' con control de éxito sobre '.transfer' o '.send',
        // ya que '.transfer' tiene un límite fijo de 2300 gas que puede romper la transacción si el receptor es un contrato.
        (bool exito, ) = payable(vendedor).call{value: montoTransferir}("");
        require(exito, "Error al transferir los fondos al vendedor");

        emit RecepcionConfirmada(comprador, vendedor, montoTransferir);
    }

    /**
     * @notice Permite al comprador o al vendedor abrir una disputa formal si el acuerdo físico no se cumple.
     * @param _motivo Explicación breve de la disputa (se recomienda que no contenga datos personales sensibles, IE11).
     */
    function iniciarDisputa(string calldata _motivo) external inEstado(Estado.Pendiente) {
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 7: Validar que el emisor de la transacción (msg.sender) sea el comprador O el vendedor.
        // Pista: require(msg.sender == comprador || msg.sender == vendedor, "No autorizado");
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<

        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 8: Validar que los fondos ya se encuentren custodiados en el contrato (fondosDepositados == true).
        // No tiene sentido abrir una disputa por un contrato sin saldo financiero.
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<

        estadoActual = Estado.Disputa;

        emit DisputaIniciada(msg.sender, _motivo);
    }

    /**
     * @notice Permite exclusivamente al Árbitro (Owner) resolver la disputa activa.
     * @param _favorVendedor Si es 'true', los fondos van al vendedor. Si es 'false', se reembolsan al comprador.
     * @dev Utiliza 'onlyOwner' para control de acceso y 'nonReentrant' para asegurar el retiro.
     */
    function resolverDisputa(bool _favorVendedor) external onlyOwner inEstado(Estado.Disputa) nonReentrant {
        address destinatario;
        
        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 9: Implementar la bifurcación lógica.
        // - Si _favorVendedor es true: 
        //     * 'destinatario' debe ser 'vendedor'.
        //     * 'estadoActual' cambia a 'Estado.Completado'.
        // - Si _favorVendedor es false:
        //     * 'destinatario' debe ser 'comprador'.
        //     * 'estadoActual' cambia a 'Estado.Reembolsado'.

        uint256 montoTransferir = address(this).balance;

        // [COMPLETAR AQUÍ POR EL ALUMNADO]:
        // TODO 10: Ejecutar la transferencia segura de 'montoTransferir' al 'destinatario' usando '.call'.
        // Validar el éxito de la transferencia con 'require'.
        // Pista: (bool exito, ) = payable(destinatario).call{value: montoTransferir}("");
        //        require(exito, "Error...");
        // >>> COMPLETA AQUÍ LA CLÁUSULA REQUIRE <<<

        emit DisputaResuelta(msg.sender, estadoActual, destinatario);
    }

    /**
     * @dev Función fallback fallback/receive para rechazar transferencias directas sin pasar por la función depositarFondos.
     * Esto evita que usuarios envíen fondos accidentalmente sin activar el flujo lógico del escrow.
     */
    receive() external payable {
        revert("Transaccion directa rechazada. Use depositarFondos()");
    }
}
