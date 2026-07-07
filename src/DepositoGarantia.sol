// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DepositoGarantia is Ownable, ReentrancyGuard {

    address public comprador;
    address public vendedor;
    uint256 public precioActivo; // Representado en wei (1 Ether = 10^18 wei)

    enum Estado { Pendiente, Completado, Disputa, Reembolsado }
    Estado public estadoActual;

    bool public fondosDepositados;

    event FondosDepositados(address indexed comprador, uint256 monto);
    event RecepcionConfirmada(address indexed comprador, address indexed vendedor, uint256 montoLiberado);
    event DisputaIniciada(address indexed denunciante, string motivo);
    event DisputaResuelta(address indexed arbitro, Estado estadoFinal, address destinatarioFondos);

    modifier onlyComprador() {
        require(msg.sender == comprador, "Solo el comprador puede ejecutar esta accion");
        _;
    }

    modifier onlyVendedor() {
        require(msg.sender == vendedor, "Solo el vendedor puede ejecutar esta accion");
        _;
    }

    modifier inEstado(Estado _estadoEsperado) {
        require(estadoActual == _estadoEsperado, "Estado del contrato no valido para esta operacion");
        _;
    }

    constructor(
        address _comprador,
        address _vendedor,
        address _arbitro,
        uint256 _precioActivo
    ) Ownable(_arbitro) {
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

    function depositarFondos() external payable onlyComprador inEstado(Estado.Pendiente) {
        require(!fondosDepositados, "Los fondos ya fueron depositados");
        require(msg.value == precioActivo, "Monto enviado no coincide con el precio del activo");

        fondosDepositados = true;

        emit FondosDepositados(msg.sender, msg.value);
    }

    function confirmarRecepcion() external onlyComprador inEstado(Estado.Pendiente) nonReentrant {
        require(fondosDepositados, "Los fondos aun no han sido depositados");

        estadoActual = Estado.Completado;

        uint256 montoTransferir = address(this).balance;

        (bool exito, ) = payable(vendedor).call{value: montoTransferir}("");
        require(exito, "Error al transferir los fondos al vendedor");

        emit RecepcionConfirmada(comprador, vendedor, montoTransferir);
    }

    function iniciarDisputa(string calldata _motivo) external inEstado(Estado.Pendiente) {
        require(msg.sender == comprador || msg.sender == vendedor, "No autorizado");
        require(fondosDepositados, "No hay fondos custodiados en el contrato");

        estadoActual = Estado.Disputa;

        emit DisputaIniciada(msg.sender, _motivo);
    }

    function resolverDisputa(bool _favorVendedor) external onlyOwner inEstado(Estado.Disputa) nonReentrant {
        address destinatario;

        if (_favorVendedor) {
            destinatario = vendedor;
            estadoActual = Estado.Completado;
        } else {
            destinatario = comprador;
            estadoActual = Estado.Reembolsado;
        }

        uint256 montoTransferir = address(this).balance;

        (bool exito, ) = payable(destinatario).call{value: montoTransferir}("");
        require(exito, "Error al transferir los fondos al destinatario");

        emit DisputaResuelta(msg.sender, estadoActual, destinatario);
    }

    receive() external payable {
        revert("Transaccion directa rechazada. Use depositarFondos()");
    }
}
