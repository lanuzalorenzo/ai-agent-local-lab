# 🛠️ Troubleshooting — Laboratorio IA Local

## 🧾 Descripción
Guía técnica de resolución de problemas para el laboratorio de agente IA local basado en Ollama + GPU NVIDIA.  
Incluye los fallos más frecuentes y sus soluciones verificadas.

---

## ⚠️ 1. Ollama no detecta la GPU

### Síntomas
- `journalctl -u ollama` no muestra “CUDA”
- `nvidia-smi` funciona, pero Ollama usa CPU
- El modelo va lento o no carga

### Solución
```bash
sudo systemctl restart ollama
journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
```

Si Ollama fue instalado con Snap:
```bash
sudo snap remove ollama
curl -fsSL https://ollama.com/install.sh | sh
```

---

## ⚠️ 2. `nvidia-smi` no aparece

### Síntomas
- Error: “NVIDIA-SMI has failed”
- No aparece la GPU

### Solución
```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

Verificar BIOS (Dell XPS):
- Desactivar Secure Boot  
- Cambiar SATA de RAID a AHCI  

---

## ⚠️ 3. Ollama no arranca

### Síntomas
- `systemctl status ollama` muestra errores
- El servicio no inicia

### Solución
```bash
journalctl -u ollama -n 50 --no-pager
sudo systemctl stop ollama
sudo rm -rf /usr/share/ollama /usr/bin/ollama
curl -fsSL https://ollama.com/install.sh | sh
```

---

## ⚠️ 4. Continue no detecta el modelo local

### Síntomas
- VS Code muestra “Model not available”
- Continue no responde

### Solución
```bash
systemctl status ollama
ollama run llama3.1:8b
```

Revisar configuración:
- VS Code → Settings → Continue → Model Provider → Ollama  
- Modelo: `llama3.1:8b`

---

## ⚠️ 5. El modelo se queda sin VRAM

### Síntomas
- Error: “CUDA out of memory”
- El modelo se cierra

### Solución
Usar un modelo más pequeño:
```bash
ollama run llama3.1:8b
```

Cerrar aplicaciones que usen GPU:
- Chrome  
- VS Code con aceleración  
- Juegos  
- OBS  

Reiniciar Ollama:
```bash
sudo systemctl restart ollama
```

---

## ⚠️ 6. Problemas con Snap

### Síntomas
- Ollama no detecta GPU  
- PATH roto  
- Servicios que no arrancan

### Solución
```bash
sudo snap remove ollama
sudo rm -rf /var/snap /var/lib/snapd /snap
curl -fsSL https://ollama.com/install.sh | sh
```

---

## ⚠️ 7. Logs vacíos o incompletos

### Síntomas
- `journalctl` no muestra información útil

### Solución
Usar el script del repositorio:
```
scripts/gpu_check.sh
```

---

## ✔️ Conclusión
Este documento recoge los problemas más frecuentes del laboratorio y sus soluciones probadas.  
Si Ollama detecta la GPU y Continue se conecta correctamente, el sistema está listo para ejecutar modelos LLM de forma local y acelerada.

---

Cuando quieras, me das el siguiente fichero.
