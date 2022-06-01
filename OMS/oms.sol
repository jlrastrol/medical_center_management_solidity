
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
    mapping(address => bool) public validacion_centros;

    // Mappin para relacionar la dirección de un centro con su contrato
    mapping(address => address) public centroContrato;

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
        require(validacion_centros[msg.sender] == true, "No tienes permisos para ejecutar esta funcion");
        // Generar un Smart Contract -> Generar su dirección
        address contrato_centro = address(new CentroSalud(msg.sender));
        // Almacenar la dirección del contrato en el array
        direcciones_contratos.push(contrato_centro);
        // Relación entre el centro y su contrato
        centroContrato[msg.sender] = contrato_centro;
        // Emitir evento
        emit nuevoContrato(msg.sender, contrato_centro);
    }

}

// Contrato autogestionable por el Centro de salud
contract CentroSalud {

    // Direcciones iniciales
    address public direccionContrato;
    address public direccionCentro;

    constructor(address _direccion) public{
        direccionCentro = _direccion;
        direccionContrato = address(this);
    }

    // Mapping para relacionar el hash de la persona con los resultados
    mapping(bytes32 => resultados) resultadosCOVID;

    // Estructura de los resultados
    struct resultados {
        bool diagnostico;
        string codigoIPFS;

    }

    // Eventos
    event NuevoResultado(bool,string);

    modifier unicamenteCentroSalud(address _direccion) {
        require(_direccion == direccionCentro, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    // Función para emitir un resultado de una prueba COVID
    function resultadoPruebaCovid(string memory _idPersona, bool _resultadoCOVID, string memory _codigoIPFS) public unicamenteCentroSalud(msg.sender){
        // Hash de la identificación de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        // Relacion del hash de la persona con la estructura de resultados 
        resultadosCOVID[hash_idPersona] = resultados(_resultadoCOVID, _codigoIPFS);
        // Emitir el evento
        emit NuevoResultado(_resultadoCOVID, _codigoIPFS);
    }
    // Funcion que permita la visualizacion de los resultados 
    function visualizarResultados(string memory _idPersona) public view returns(string memory _resultadoPrueba, string memory _codigoIPFS){
        // Hash de la identidad de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        // Retorno de un booleano como string
        string memory resultadoPrueba;
        if (resultadosCOVID[hash_idPersona].diagnostico == true){
            resultadoPrueba = "Positivo";
        } else{
            resultadoPrueba = "Negativo";
        }
        // Retorno de los parametros necesarios
        _resultadoPrueba = resultadoPrueba;
        _codigoIPFS = resultadosCOVID[hash_idPersona].codigoIPFS;
    }
}

