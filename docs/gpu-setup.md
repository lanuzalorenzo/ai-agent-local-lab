# 🖥️ Configuración de GPU para Ollama  
Guía completa para habilitar aceleración NVIDIA + CUDA en Ubuntu

Este documento explica cómo preparar una GPU NVIDIA para ejecutar modelos LLM localmente
con Ollama, asegurando compatibilidad, rendimiento y estabilidad.

---

## 📌 Requisitos

- Ubuntu 22.04 o superior  
- GPU NVIDIA compatible con CUDA  
- Drivers NVIDIA instalados correctamente  
- Paquete `nvidia-smi` disponible  
- Ollama instalado desde `.deb` (no Snap)

---

## 🔧 1. Verificar la GPU

Ejecuta:

```bash
nvidia-smi
```

Debe mostrar tu GPU, por ejemplo:

```text
NVIDIA GeForce RTX 3050 Laptop GPU
```

Si no aparece:

- Revisa drivers  
- Revisa Secure Boot  
- Revisa modo AHCI/RAID en BIOS (Dell XPS)

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

## 🔧 3. Instalar CUDA (si es necesario)

Ollama incluye su propio runtime CUDA, pero si quieres herramientas adicionales:

```bash
sudo apt install nvidia-cuda-toolkit
```

---

## 🔧 4. Verificar que Ollama detecta la GPU

```bash
journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
```

Debes ver algo como:

```text
library=CUDA name="NVIDIA GeForce RTX 3050 Laptop GPU"
```

Si no aparece:

- Reinicia el servicio  
- Reinstala Ollama  
- Comprueba drivers  
- Comprueba que no usas Snap

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

Si la GPU está activa, verás uso de VRAM en `nvidia-smi`.

---

## 🧪 7. Script de verificación rápida

Puedes usar el script del repositorio:

```text
scripts/gpu_check.sh
```

---

## ✔️ Conclusión

Si tu GPU aparece en:

- `nvidia-smi`  
- `journalctl -u ollama`  

Entonces Ollama está usando aceleración CUDA correctamente.

Tu laboratorio de agente IA local está listo para trabajar con modelos grandes.