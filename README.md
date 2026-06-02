# Configuración NixOS

Esta es la configuración de NixOS usado en los servidores de la DAAT.

Para replicar un entorno virtual usar la versión 25.11 de NixOS y modificar la linea:

```nix
boot.loader.grub.device = "/dev/sda";
```
para que apunte al dispositivo del grub de la instalación


