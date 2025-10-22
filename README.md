# Proyecto Localnet Ethereum con Blockscout

Este proyecto se configura para desplegar un entorno localnet de Ethereum utilizando servicios definidos en `docker-compose.yml`. Los servicios principales incluyen Geth, Blockscout y varios servicios adicionales para verificación de contratos, visualización y estadísticas.

## Estructura del Proyecto

El proyecto tiene la siguiente estructura de carpetas y archivos:

- `dc/`:
  - `geth-container/`:
    - Configuración específica para el contenedor Geth.
- `src/`:
  - `blockscout-backend/`:
    - Código fuente para el back-end de Blockscout.
  - `blockscout-frontend/`:
    - Código fuente para la interfaz de usuario web de Blockscout.
  - `smart-contract-verifier/`:
    - Código fuente para la verificación de contratos.
- `tools/`:
  - Scripts y herramientas adicionales útiles para el proyecto.
- `config/`:
  - Archivos de configuración para los servicios individuales.
- `logs/`:
  - Directorio para almacenar los logs de los servicios.
- `scripts/`:
  - Scripts para iniciar, detener y mantener el proyecto.
- `CHANGELOG.md`:
  - Notas de versiones y cambios realizados en el proyecto.

## Servicios y Roles en el Ecosistema

### Geth

**Rol**: 
Nodo local de Ethereum utilizado para ejecutar la red local. Proporciona servicios de consensus y transacciones para la red Ethereum.

### Blockscout

**Rol**: 
Ofrece una interfaz de usuario web para explorar y visualizar la red Ethereum. Permite ver los bloques, transacciones, cuentas, contratos y más información relevante de la red.

### PostgreSQL

**Rol**: 
Gestiona la base de datos donde Blockscout almacena datos sobre la red Ethereum, incluyendo bloques, transacciones, cuentas, etc.

### Redis

**Rol**: 
Sirve como servidor de caché para mejorar el rendimiento de las consultas y la carga de datos en Blockscout.

### Smart Contract Verifier

**Rol**: 
Verifica la integridad y seguridad de los contratos Solidity desplegados en la red Ethereum.

### Visualizer and Stats

**Rol**: 
Proporcionan servicios adicionales para visualización y estadísticas relacionadas con la red y los contratos en la red Ethereum.

##Configuraciones y Dependencias

- **Dependencias**: 
  - Blockscout Backend depende del contenedor Geth y la base de datos PostgreSQL.
  - Redis depende del contenedor Geth y Blockscout Backend.
  - Blockscout Frontend depende del contenedor Blockscout Backend.
  - Smart Contract Verifier depende de la base de datos Blockscout.
  - Stats dependen del contenedor Blockscout Backend y Blockscout DB.

- **Redes**: 
  - `eth-net`: Red de tipo bridge utilizada por todos los servicios para comunicarse entre sí.

##Consejos y Mejoras Propuestas

1. **Persistent Data**: 
   - Asegúrate de que los volúmenes como los definidos en `docker-compose` estén configurados correctamente para persistir los datos entre ejecuciones del `docker-compose`.

2. **Logs y Mantenimiento**: 
   - Implementa un sistema robusto de registros para monitorear el desempeño del proyecto.
   - Periodicamente revisa los logs de cada servicio para detectar errores o mejoras en el rendimiento.

3. **Extensiones de Feature Flags**: 
   - Considera exponer más opciones de configuración a través de variables de entorno, como `NETWORK`, `CHAIN_ID` etc., para facilitar la adaptación del proyecto a diferentes entornos o redes.

4. **Seguridad**: 
   - Asegúrate de no exponer puertos innecesarios al exterior y siempre utiliza contenedores con capacidades y permisos minimales para prevenir vulnerabilidades como ataques de inyección SQL o Cross-Site Scripting (XSS).

##Explorando el Proyecto

Para iniciar el proyecto local, puedes usar siguientes comandos:

```sh
# Iniciar todos los servicios definidos en docker-compose.yml
docker-compose up -d

# Ver los logs de un servicio específico, como Geth
docker-compose logs -f geth
```

Para pausar los servicios, puedes usar:

```sh
# Detener todos los servicios de docker-compose
docker-compose down
```