# 🏋️ Virtual Gym BDA

El objetivo del proyecto es diseñar e implementar la infraestructura completa de una base de datos para una plataforma de gimnasio virtual, aplicando buenas prácticas de Administración de Bases de Datos (DBA), almacenamiento, seguridad, recuperación y organización de recursos.

# 📋 Descripción General

Virtual Gym BDA es una implementación de base de datos orientada a una aplicación de gestión de gimnasio virtual.

El proyecto contempla desde la creación de la infraestructura física y lógica de la base de datos hasta la configuración de usuarios, tablespaces, almacenamiento de imágenes, mecanismos de recuperación y administración operativa.

La solución fue desarrollada utilizando Oracle Database y scripts automatizados en SQL y Shell Script.

# 🎯 Objetivos

- Diseñar una arquitectura de almacenamiento organizada y escalable.
- Separar componentes críticos de la base de datos en diferentes dispositivos y rutas.
- Implementar tablespaces especializados según el tipo de información almacenada.
- Gestionar usuarios y privilegios bajo el principio de mínimo privilegio.
- Configurar mecanismos de recuperación y disponibilidad.
- Automatizar la creación y configuración de la base de datos mediante scripts.

# 🏗 Arquitectura del Proyecto

El proyecto se divide en dos módulos principales:

## 1. Infraestructura

Responsable de la creación y configuración de la instancia de base de datos.

### Actividades principales

- Creación de contenedores y dispositivos de almacenamiento.
- Configuración de archivos de control.
- Configuración de password file.
- Creación de SPFILE y PFILE.
- Creación de la CDB y PDB.
- Configuración de directorios físicos.
- Multiplexado de Redo Logs.
- Configuración de Archive Log Mode.
- Configuración de Flashback Database.
- Administración de Tablespaces.
- Configuración de Connection Pool.
- Configuración de Shared Server.
- Planeación de respaldos y recuperación.

### Estructura

```text
infraestructura/
│
├── carga-inicial/
├── s-01-crea-pdb-ordinario.sql
├── s-02-rutas-tablespaces.sh
├── s-03-tablespaces.sql
├── s-04-usuarios.sql
├── s-05-ddl-infraestructura.sql
├── s-06-indices.sql
└── s-07-carga-inicial.sql
```

## 2. Usuarios / Operación

Responsable de la implementación funcional de la aplicación.

### Actividades principales

- Creación de usuarios de operación.
- Creación de tablas de negocio.
- Creación de índices.
- Carga inicial de datos.
- Gestión de archivos e imágenes.
- Simulación de operaciones del sistema.

### Estructura

```text
modulo_usuarios/
│
├── operacion/
│   ├── carga-inicial/
│   ├── s-00-crear-pdb-ordinario.sql
│   ├── s-01-rutas-tablespaces-root.sh
│   ├── s-02-tablespaces.sql
│   ├── s-03-usuarios.sql
│   ├── s-04-ddl-operacion.sql
│   ├── s-05-indices.sql
│   ├── s-06-carga-inicial.sql
│   ├── s-07-copia-archivos.sh
│   ├── s-07-carga-foto-auto.sql
│   └── s-10-simula-carga-auto.sql
```

# 🔐 Seguridad

El proyecto incorpora mecanismos de seguridad como:

- Password File.
- Usuarios separados por módulo.
- Roles y privilegios específicos.
- Separación de responsabilidades administrativas y operativas.
- Administración de accesos mediante esquemas independientes.

# 🔄 Disponibilidad y Recuperación

Se implementaron mecanismos de recuperación y continuidad operativa:

- Multiplexado de Redo Logs.
- Archive Log Mode.
- Flashback Database.
- Planeación de respaldos.
- Recuperación ante fallos simulados.
- Separación física de archivos críticos.

# 🛠 Tecnologías Utilizadas

- Oracle Database
- SQL
- PL/SQL
- Shell Script (Bash)
- Linux


# 🚀 Ejecución

La instalación se realiza mediante la ejecución secuencial de los scripts incluidos en cada módulo.

Pilar Jaqueline Hernández García

Proyecto desarrollado como parte de la asignatura de Bases de Datos Avanzadas.
