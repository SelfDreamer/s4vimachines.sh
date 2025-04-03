# S4vimachines

#### ¿Qué es S4vimachines.sh?
Este es un cliente de terminal, que se encarga de extraer información acerca de las máquinas que va resolviendo [s4vitar](https://www.youtube.com/s4vitar). Este cliente de terminal, trata de tener la misma flexibilidad que se tiene al buscar en la misma página de [infosec](https://infosecmachines.io). 
> [!IMPORTANT]
> Las máquinas y su información se extraen de [infosecmachines](https://infosecmachines.io/api/machines).

---

## ⚠️ Antes de instalar dependencias y demas importante que actualizes el sistema

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


