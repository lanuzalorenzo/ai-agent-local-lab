# 🛠️ Troubleshooting  
Guía de resolución de problemas para el laboratorio de agente IA local con Ollama + GPU

Este documento recoge los problemas más comunes encontrados durante la instalación,
configuración y ejecución del agente local, junto con sus soluciones verificadas.

---

## ⚠️ 1. Ollama no detecta la GPU

### **Síntomas**
- `journalctl -u ollama` no muestra “CUDA”
- `nvidia-smi` funciona, pero Ollama usa CPU
- El modelo va lento o no carga

### **Solución**
1. Reiniciar Ollama:
   ```bash
   sudo systemctl restart ollama
   ```
2. Verificar logs:
   ```bash
   journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
   ```
3. Reinstalar Ollama (si fue instalado con Snap):
   ```bash
   sudo snap remove ollama
   ```
   Luego instalar con `.deb`:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

---

## ⚠️ 2. `nvidia-smi` no aparece

### **Síntomas**
- Error: “NVIDIA-SMI has failed”
- No aparece la GPU

### **Solución**
1. Instalar drivers:
   ```bash
   sudo ubuntu-drivers autoinstall
   sudo reboot
   ```
2. Verificar Secure Boot (Dell XPS):
   - Desactivar Secure Boot en BIOS  
   - Reiniciar

3. Verificar modo SATA:
   - Cambiar de RAID a AHCI en BIOS  
   - Reiniciar

---

## ⚠️ 3. Ollama no arranca

### **Síntomas**
- `systemctl status ollama` muestra errores
- El servicio no inicia

### **Solución**
1. Ver logs:
   ```bash
   journalctl -u ollama -n 50 --no-pager
   ```
2. Reinstalar:
   ```bash
   sudo systemctl stop ollama
   sudo rm -rf /usr/share/ollama /usr/bin/ollama
   curl -fsSL https://ollama.com/install.sh | sh
   ```

---

## ⚠️ 4. Continue no detecta el modelo local

### **Síntomas**
- VS Code muestra “Model not available”
- Continue no responde

### **Solución**
1. Verificar que Ollama está corriendo:
   ```bash
   systemctl status ollama
   ```
2. Probar un modelo:
   ```bash
   ollama run llama3.1:8b
   ```
3. Reiniciar VS Code

4. Revisar configuración de Continue:
   - Settings → Continue → Model Provider → Ollama  
   - Modelo: `llama3.1:8b`

---

## ⚠️ 5. El modelo se queda sin VRAM

### **Síntomas**
- Error: “CUDA out of memory”
- El modelo se cierra

### **Solución**
1. Usar un modelo más pequeño:
   ```bash
   ollama run llama3.1:8b
   ```
2. Cerrar aplicaciones que usen GPU:
   - Chrome  
   - VS Code con aceleración  
   - Juegos  
   - OBS  

3. Reiniciar el servidor:
   ```bash
   sudo systemctl restart ollama
   ```

---

## ⚠️ 6. Problemas con Snap

### **Síntomas**
- Ollama no detecta GPU  
- PATH roto  
- Servicios que no arrancan

### **Solución**
Eliminar Snap completamente:

```bash
sudo snap remove ollama
sudo rm -rf /var/snap /var/lib/snapd /snap
```

Instalar Ollama con `.deb`:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

---

## ⚠️ 7. Logs vacíos o incompletos

### **Síntomas**
- `journalctl` no muestra nada útil

### **Solución**
Usar el script del repositorio:

```bash
scripts/gpu_check.sh
```

---

## ✔️ Conclusión

Este documento cubre los problemas más frecuentes del laboratorio y sus soluciones
probadas. Si Ollama detecta la GPU y Continue se conecta correctamente, el sistema está
listo para ejecutar modelos LLM de forma local y acelerada.

---