
//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract OMS {

    // Dirección de la OMS -> Owner
    address public oms;

    // Constructor del contrato
    constructor() public{
        oms = msg.sender;
    }

    // Mapping para relacionar los centros de salud con la validez del sistema de gestión
    mapping(address => bool) validacion_centros;

    // Ejemplo 1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 -> true = TIENE PERMISOS PARA CREAR SU SMART CONTRACT
    // Ejemplo 2: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db -> false = NO TIENE PERMISOS PARA CREAR SU SMART CONTRACT

    // Array de direcciones que almacene los contratos de los centros de salud validados
    address [] public direcciones_contratos;

    // Array de direcciones que soliciten acceso
    address [] solicitudes;

    // Eventos
    event nuevoCentroValidado(address);
    event nuevoContrato(address, address);
    event solicitudAcceso(address);

    // Modificador que permita únicamente la ejecución de funciones por la OMS
    modifier unicamente(address _direccion){
        require(_direccion == oms, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    // Funcion para solicitar acceso al sistema medico 
    function solicitarAcceso() public{
        solicitudes.push(msg.sender);
        emit solicitudAcceso(msg.sender);
    }
    // Funcion que visualiza las direcciones que han solicitado este acceso 
    function visualizarSolicitudes() public view unicamente(msg.sender) returns(address[] memory){
        return solicitudes;
    }
    // Funcion para validar nuevos centros de salud que puedan autogestionarse -> UnicamenteOMS
    function centrosSalud(address _centro) public unicamente(msg.sender){
        // Asignación del estado de validez al centro de salud
        validacion_centros[_centro] = true;
        // Emitir evento
        emit nuevoCentroValidado(_centro);
    }
    // Funcion que permita crear un contrato inteligente de un centro de salud 
    function factoryCentro() public {
        // Filtrado para que únicamente los centros de salud validados sean capaces de ejecutar esta función
        require(validacion_centros[msg.sender] = true, "No tienes permisos para ejecutar esta funcion");
        // Generar un Smart Contract -> Generar su dirección
        address contrato_centro = address(new CentroSalud(msg.sender));
        // Almacenar la dirección del contrato en el array
        direcciones_contratos.push(contrato_centro);
        // Emitir evento
        emit nuevoContrato(msg.sender, contrato_centro);
    }

}

contract CentroSalud {

    address public direccionContrato;
    address public direccionCentro;

    constructor(address _direccion) public{
        direccionCentro = _direccion;
        direccionContrato = address(this);

    }
}

