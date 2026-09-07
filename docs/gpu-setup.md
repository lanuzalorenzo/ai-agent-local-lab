# 🖥️ Configuración de GPU para Ollama

## 🧾 Descripción
Guía técnica para habilitar aceleración NVIDIA + CUDA en Ubuntu con el fin de ejecutar modelos LLM localmente mediante Ollama.  
El objetivo es garantizar compatibilidad, rendimiento y estabilidad en el laboratorio de agente IA local.

---

## 📌 Requisitos
- Ubuntu 22.04 o superior  
- GPU NVIDIA compatible con CUDA  
- Drivers NVIDIA instalados correctamente  
- Herramienta `nvidia-smi` disponible  
- Ollama instalado desde `.deb` (no Snap)

---

## 🔧 1. Verificar la GPU
Ejecutar:

```bash
nvidia-smi
```

Debe aparecer la GPU, por ejemplo:

```
NVIDIA GeForce RTX 3050 Laptop GPU
```

Si no aparece:
- Revisar drivers  
- Revisar Secure Boot  
- Revisar modo AHCI/RAID en BIOS (Dell XPS)

---

## 🔧 2. Instalar drivers NVIDIA
```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

Tras reiniciar:

```bash
nvidia-smi
```

---

## 🔧 3. Instalar CUDA (opcional)
Ollama incluye su propio runtime CUDA.  
Si se necesitan herramientas adicionales:

```bash
sudo apt install nvidia-cuda-toolkit
```

---

## 🔧 4. Verificar que Ollama detecta la GPU
```bash
journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
```

Debe aparecer algo similar a:

```
library=CUDA
name="NVIDIA GeForce RTX 3050 Laptop GPU"
```

Si no aparece:
- Reiniciar el servicio  
- Reinstalar Ollama  
- Revisar drivers  
- Confirmar que no se usa Snap

---

## 🔧 5. Reiniciar Ollama
```bash
sudo systemctl restart ollama
```

---

## 🔧 6. Probar un modelo con GPU
```bash
ollama run llama3.1:8b
```

Si la GPU está activa, se verá uso de VRAM en:

```bash
nvidia-smi
```

---

## 🧪 7. Verificación rápida
Puede utilizarse el script del repositorio:

```
scripts/gpu_check.sh
```

---

## ✔️ Conclusión
Si la GPU aparece en:

- `nvidia-smi`  
- `journalctl -u ollama`  

entonces Ollama está utilizando aceleración CUDA correctamente.  
El laboratorio de agente IA local está listo para trabajar con modelos grandes.
```

---

Cuando quieras, me das el siguiente fichero.
