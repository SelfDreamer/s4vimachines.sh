<div align=center><h1> S4vimachines </h1></div>

---

# ¿Qué es S4vimachines.sh?
Este es un cliente de terminal diseñado para funcionar como buscador de máquinas que [S4vitar](https://youtube.com/S4vitar) va resolviendo a lo largo del tiempo. 
Anteriormente las máquinas se extraian de **infosecmachines**, pero hace poco S4vitar se puso manos a la obra e hizo que **infosecmachines** ahora apunte a la nueva plataforma de [HackingVault](https://hackingvault.com). Y si bien esta nueva plataforma pretende mejorar tu forma de aprender Hacking, lo malo como tal de esta nueva plataforma es que el buscador ya no funciona como lo hizo **infosecmachines** en su momento. Entonces, este script de bash fue hecho para extraer las máquinas desde el excel de s4vitar y buscar de la forma en la que **infosecmachines** lo hacia en aquel entonces.

---
# ¿Por qué elegir esta herramienta? 
Esta herramienta se distingue de las demás herramientas que encontraras porque ademas de poseer flexibilidad a la hora de buscar máquinas, es personalizable.
Si bien otros buscadores usan la tipica de que listan todas las máquinas usando `column` y ya, en este caso la cosa es diferente, porque este script usa [fzf](https://github.com/junegunn/fzf) para mejorar la estética drasticamente a la hora de buscar por multiples máquinas. 
Lo mejor de todo esto esto es que posee aún la función de busqueda avanzada y podemos aplicar un coloreado a la linea en donde salgan nuestros `matches`, como lo hacia `infosecmachines` en aquel entonces. Y todo esto, desde la terminal.

> [!WARNING]
> Actualmente la personalización no tiene tanto alcanze, pero a futuro se iran agregando cosas interesantes.

---
# Ejemplos 
### Resaltado de los matches encontrados.
<img width="1884" height="787" alt="image" src="https://github.com/user-attachments/assets/2a189923-86d8-46f4-b78f-d530b439c546" />

### Sin el resaltado
<img width="1914" height="791" alt="image" src="https://github.com/user-attachments/assets/c4448851-8f82-4681-9811-da314fe8b3a8" />

### Fzf con resaltado de matches (eJPT, como objeto)
<img width="1903" height="989" alt="image" src="https://github.com/user-attachments/assets/34bcafc2-39a1-4670-917c-9b60a3853578" />

### Fzf sin resaltado de matches (eJPT, como objeto)
<img width="1908" height="998" alt="image" src="https://github.com/user-attachments/assets/8e08a4b5-fd22-4270-b90b-98deb53e9c69" />


---

# ¿infosecmachines a desaparecido?
La respuesta corta es, no. 
Aunque muchos creerian que si, la verdad es que como tal el dominio de `infosecmachines.io` redirige a [HackingVault](https://hackingvault.com), pero puedes lanzarlo en local desde el siguiente [repositorio](https://github.com/JavierMolines/hack4u-machines). 

---

# Configuración 

Este repositorio cuenta con 2 directorios, los cuales son:

- **config**
- **variables**

## Personalización 
En el apartado de **config** encontraremos un archivo llamado **appareance.sh** el cual contendra variables de entorno que se pueden usar para modificar un poco la información de las máquinas que se mostraran por terminal.

Por ejemplo, en este caso tenemos las siguientes variables de entorno las cuales indican los estilos a aplicar:

```bash
italic_style="\u001b[3m"
underline_style="\033[4m"
bold_style="\u001b[1m"
```

En este indicamos que estilos queremos que se apliquen. Y si, podemos aplicarlos todos.  

```bash 
bold_match=false 
italic_match=false 
underline_match=false 
```

Y en este otro caso vamos a indicar de que color queremos que pinte la linea donde salen las palabras clave que hemos puesto. Esto aplica para: 
- La función de busqueda avanzada, que busca por todos los campos menos los de **ip** y la dirección **url**
- La busqueda de técnicas
- La busqueda de certificaciones 

```bash 
color="\033[33m" # El color que recibira la linea donde esten los matches  
```

Y al final tenemos esta variable **icon**, la cual sirve para indicar que queremos que se muestre al listar certificados/skills. Ya que en esta ocación, las ténicas/certificados no se mostraran en una sola linea si no que se mostraran de linea en linea como en **infosecmachines**
Y el **icon_color** es para indicarle de que color queremos que sea el icono, en este caso sera amarillo.

```bash 
# Output machine results 
icon="  •"
icon_color="\u001b[93m"
```

## Variables de entorno
En este apartado solo encontraremos un archivo llamado `global_variables.sh`, el cual como su mismo nombre lo indica, habran variables globales que se usaran dentro de el script.

Por ejemplo, tenemos la variable la cual se encargara de definir donde apuntara el archivo que contendra toda la información de las máquinas.

```bash
PATH_ARCHIVE="$HOME/.local/share/s4vimachines/bundle.js"
```

---

# Parametros 

Si queremos listar parametros solo tendremos que llamar al panel de ayuda de la siguiente forma. 

```bash 
s4vimachines.sh --help 
```

---

<div align=center>Es todo, muchas gracias por tomarte el tiempo de leer. Y si tienes problemas, crea un ISSUE y te ayudare en lo que pueda.</div>
