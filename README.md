# Configuración NixOS

Esta es la configuración de NixOS usado en los servidores de la DAAT.

Para replicar un entorno virtual usar la versión 25.11 de NixOS y:

- **IMPORTANTISIMO** Modificar la linea:

```nix
boot.loader.grub.device = "/dev/sda";
```
para que apunte al dispositivo del grub de la instalación.

- **Red**: Comentar las lineas de IP Config del fichero donde se declara IP de interfaz, default gateway, dns, etc.

- **SanTeleco**: Crear pocketbase.env con PB_ENCRYPTION_KEY (https://wiki.nixos.org/wiki/Pocketbase) en /home/daat/

- **SanTeleco**: Clonar https://github.com/daat-uvigo/WebEntradasSanTeleco en /home/daat/

- **DAAT**: Dejar el directorio dist (directorio de build) de https://github.com/daat-uvigo/NuevaWebDaat en /var/www/html/daat/
