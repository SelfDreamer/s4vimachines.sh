# S4vimachines

#### ¿Qué es S4vimachines.sh?
Este es un cliente de terminal, que se encarga de extraer información acerca de las máquinas que va resolviendo [s4vitar](https://www.youtube.com/s4vitar). Este cliente de terminal, trata de tener la misma flexibilidad que se tiene al buscar en la misma página de [infosec](https://infosecmachines.io). 
> [!IMPORTANT]
> Las máquinas y su información se extraen de [infosecmachines](https://infosecmachines.io/api/machines).

---

#### ⚠️ Antes de instalar dependencias y demas importante que actualizes el sistema

---

<details>
  <summary><b>Actualización</b></summary>

  ### Debian
  
  ```bash
  sudo apt update && sudo apt upgrade -y # Para distribuciones basadas en debian
  sudo apt update && sudo parrot-upgrade -y # Para el delicado de Parrot
  ```

  ### Arch
  ```bash
  sudo pacman -Syu --noconfirm   # Usando pacman (gestor oficial)
  sudo paru -Syu --noconfirm     # Usando paru (AUR helper basado en pacman)
  sudo yay -Syu --noconfirm      # Usando yay (otro AUR helper basado en pacman)
  ```


</details>  

<details>
  <summary><b>Dependencias</b></summary>

  ### Debian
  
  ```bash
  sudo apt install coreutils util-linux npm nodejs bc moreutils translate-shell -y
  sudo apt install node-js-beautify -y 
  ```

  ### Arch
  
  ```bash
  sudo pacman -S coreutils npm nodejs bc moreutils translate-shell --noconfirm
  sudo npm install -g js-beautify 
  ```

</details>

## Modo de uso: 
`/opt/s4vimachines.sh/s4vimachines.sh` [PARAMETROS] [ARGUMENTOS]

### -h(help): Mostrar el manual de ayuda.

### Actualizaciones y dependencias
- `-u(update)`: Actualizar dependencias

### Listar todas las máquinas.
- `-m(machine)`: Mostrar las propiedades de una máquina.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -m 'Multimaster'`
- `-i(ip_addr)`: Mostrar máquinas por la dirección IP.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -i '10.10.10.179'`
- `-d(difficulty)`: Mostrar máquinas por una dificultad dada.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -d 'Insane'`
- `-o(osSystem)`: Mostrar máquinas por un sistema operativo dado.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -o 'Windows'`
- `-w(writeup)`: Mostrar el enlace a la resolución de una máquina
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -w 'Multimaster'`
- `-s(skill)`: Listar máquinas por skill
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -s 'SQLI'`
- `-p(platform)`: Listar todas las máquinas de una plataforma
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -p 'HackTheBox'`
- `-c(certificate)`: Listar todas las máquinas que dispongan de uno o más certificados
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -c 'OSCP OSWE OSEP'`

### Extras
- `-v(verbose)`: Activar el modo verbose
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -u -v`
- `-y(yes)`: Confirmar cada acción que dependa de una confirmación de usuario
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -u -y`
- `-r(random)`: Modo de elección aleatorio. El script elegirá una máquina al azar por ti.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -r`
- `-t(translate)`: Traducir el output a un idioma específico.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -m 'Tentacle' -t 'es'`
- `-b(browser)`: Abrir el writeup de una máquina, en un navegador específico.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -w 'Tentacle' -b ''` (Navegador por default: firefox)
- `-x(exclude banner)`: No mostrar el banner en el panel de ayuda.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -x`
- `-a(all)`: Listar todas las máquinas existentes.
  - **Ejemplo**: `/opt/s4vimachines.sh/s4vimachines.sh -a`


