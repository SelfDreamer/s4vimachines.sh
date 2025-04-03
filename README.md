# S4vimachines

#### ¿Qué es S4vimachines.sh?
Este es un cliente de terminal, que se encarga de extraer información acerca de las máquinas que va resolviendo [s4vitar](https://www.youtube.com/s4vitar). Este cliente de terminal, trata de tener la misma flexibilidad que se tiene al buscar en la misma página de [infosec](https://infosecmachines.io). 
> [!IMPORTANT]
> Las máquinas y su información se extraen de [infosecmachines](https://infosecmachines.io/api/machines).

---

<details>
  <summary><b>Dependencias</b></summary>

  ### Debian
  
  ⚠️ Actualiza el sistema
  ```bash
  sudo apt update && sudo apt upgrade -y # Para distribuciones basadas en debian
  sudo apt update && sudo parrot-upgrade -y # Para el delicado de Parrot
  ```

  ### Arch
  
  ⚠️ Actualiza el sistema
  ```bash
  sudo pacman -Syu --noconfirm   # Usando pacman (gestor oficial)
  sudo paru -Syu --noconfirm     # Usando paru (AUR helper basado en pacman)
  sudo yay -Syu --noconfirm      # Usando yay (otro AUR helper basado en pacman)
  ```


</details>


```bash
sudo apt install -y nodejs js-beautify bc moreutils

```
