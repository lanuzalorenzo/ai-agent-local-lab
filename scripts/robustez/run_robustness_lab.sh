#!/usr/bin/env bash
#
# run_robustness_lab.sh
# Prepara un equipo Ubuntu, ejecuta la matriz de robustez de prompts y deja el
# sistema como estaba.
# Autor: Lorenzo Lanuza Arellano
# Proyecto: lab-ia-aprendizaje
#
# Uso:
#   ./scripts/robustez/run_robustness_lab.sh                 # instala, ejecuta y restaura
#   ./scripts/robustez/run_robustness_lab.sh --preparar      # solo deja el entorno listo
#   ./scripts/robustez/run_robustness_lab.sh --keep          # no restaura al terminar
#   ./scripts/robustez/run_robustness_lab.sh --restore       # revierte una sesión anterior
#   ./scripts/robustez/run_robustness_lab.sh --dry-run       # muestra el plan sin ejecutar
#
# Garantías:
#   - Solo instala Ollama si no existe. Si ya existe, no lo modifica.
#   - Solo descarga el modelo si no está. Si ya estaba, no lo borra.
#   - Registra qué ha cambiado y lo revierte al terminar.
#   - No escribe secretos, IPs ni nombres de equipo en la evidencia.

set -Eeuo pipefail

# --------------------------------------------------------------------------
# Valores por defecto
# --------------------------------------------------------------------------

DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ_REPO="$(cd "$DIR_SCRIPT/../.." && pwd)"

MODELO="${MODELO:-qwen2.5-coder:7b}"
NIVELES="${NIVELES:-N0 N1}"
REPETICIONES="${REPETICIONES:-3}"
ENDPOINT="${ENDPOINT:-http://127.0.0.1:11434}"
SISTEMA="${SISTEMA:-v1}"

MODO="ejecutar"
CONSERVAR=0
DRY_RUN=0
SI=0
SALIDA=""

ESTADO_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/lab-ia-aprendizaje"
ESTADO="$ESTADO_DIR/sesion.env"

# --------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------

log()  { printf '%s %s\n' "·" "$*"; }
ok()   { printf '%s %s\n' "✅" "$*"; }
warn() { printf '%s %s\n' "⚠️ " "$*" >&2; }
die()  { printf '%s %s\n' "❌" "$*" >&2; exit 1; }

ejecutar() {
    if [[ $DRY_RUN -eq 1 ]]; then
        printf '   [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

sudo_c() {
    if [[ ${EUID} -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

# --------------------------------------------------------------------------
# Estado de la sesión
# --------------------------------------------------------------------------

estado_ini() {
    if [[ $DRY_RUN -eq 1 ]]; then return 0; fi
    mkdir -p "$ESTADO_DIR"
    cat > "$ESTADO" <<EOF
# Sesión iniciada $(date -Is). Se elimina al restaurar.
MODELO=$MODELO
OLLAMA_INSTALADO_POR_SCRIPT=0
MODELO_DESCARGADO_POR_SCRIPT=0
SERVICIO_ACTIVO_ANTES=0
SERVICIO_HABILITADO_ANTES=0
MODELO_PREEXISTENTE=0
EOF
}

estado_set() {
    if [[ $DRY_RUN -eq 1 ]]; then return 0; fi
    [[ -f "$ESTADO" ]] || return 0
    sed -i "s|^$1=.*|$1=$2|" "$ESTADO"
}

estado_get() {
    [[ -f "$ESTADO" ]] || { echo "${2:-}"; return 0; }
    local v
    v="$(grep -E "^$1=" "$ESTADO" | cut -d= -f2-)"
    echo "${v:-${2:-}}"
}

# --------------------------------------------------------------------------
# Diagnóstico previo
# --------------------------------------------------------------------------

preflight() {
    log "Comprobando el equipo"

    [[ -r /etc/os-release ]] || die "No se puede leer /etc/os-release"
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
        ubuntu|debian) ;;
        *) die "Este script está pensado para Ubuntu/Debian; detectado: ${ID:-desconocido}" ;;
    esac
    log "Sistema: ${PRETTY_NAME:-$ID}"

    command -v python3 >/dev/null 2>&1 \
        || die "Falta python3. Instálalo con: sudo apt-get install -y python3"
    local py
    py="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    log "Python: $py"
    python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' \
        || die "Se requiere Python 3.9 o superior (detectado $py)"

    command -v curl >/dev/null 2>&1 \
        || die "Falta curl. Instálalo con: sudo apt-get install -y curl"

    local libre_gb
    libre_gb="$(df -BG --output=avail /usr | tail -1 | tr -dc '0-9')"
    if [[ "${libre_gb:-0}" -lt 8 ]]; then
        warn "Espacio libre en /usr: ${libre_gb} GB. Un modelo de 7B ocupa entre 4 y 6 GB."
    else
        log "Espacio libre en /usr: ${libre_gb} GB"
    fi

    local ram_gb
    ram_gb="$(awk '/MemTotal/{printf "%d", $2/1024/1024}' /proc/meminfo)"
    log "RAM: ${ram_gb} GB"
    if [[ "${ram_gb:-0}" -lt 8 ]]; then
        warn "Menos de 8 GB de RAM: el modelo de 7B irá muy justo. Considera --modelo qwen2.5:3b."
    fi

    if command -v nvidia-smi >/dev/null 2>&1; then
        log "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
        local mem_mib
        mem_mib="$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1 | tr -dc '0-9')"
        case "$MODELO" in
            *7b*|*7B*)
                if [[ -n "$mem_mib" && "$mem_mib" -lt 8000 ]]; then
                    warn "GPU con ${mem_mib} MiB: un 7B en Q4 no cabe entero; usa --modelo qwen2.5:3b o asume offload a CPU."
                fi
                ;;
        esac
    else
        warn "Sin nvidia-smi: la inferencia será por CPU y lenta."
    fi
}

# --------------------------------------------------------------------------
# Ollama
# --------------------------------------------------------------------------

instalar_ollama_si_falta() {
    if command -v ollama >/dev/null 2>&1; then
        log "Ollama ya está instalado; no se modifica"
        return 0
    fi

    log "Ollama no está instalado: se usa scripts/instalacion/install_ollama.sh"
    if [[ $DRY_RUN -eq 0 ]]; then estado_set OLLAMA_INSTALADO_POR_SCRIPT 1; fi

    if [[ $DRY_RUN -eq 1 ]]; then
        printf '   [dry-run] ASSUME_YES=1 bash %s\n' "$DIR_SCRIPT/../instalacion/install_ollama.sh"
        return 0
    fi
    ASSUME_YES=1 bash "$DIR_SCRIPT/../instalacion/install_ollama.sh"
    command -v ollama >/dev/null 2>&1 || die "La instalación terminó pero 'ollama' no está en PATH"
}

arrancar_servicio() {
    if systemctl is-active --quiet ollama 2>/dev/null; then
        log "Servicio ollama ya activo"
        return 0
    fi
    log "Arrancando el servicio ollama"
    ejecutar sudo_c systemctl start ollama || die "No se pudo arrancar el servicio ollama"
}

esperar_endpoint() {
    if [[ $DRY_RUN -eq 1 ]]; then return 0; fi
    log "Esperando a $ENDPOINT"
    local i
    for i in $(seq 1 30); do
        if curl -fsS --max-time 2 "$ENDPOINT/api/tags" >/dev/null 2>&1; then
            ok "Endpoint disponible"
            return 0
        fi
        sleep 2
    done
    die "El endpoint $ENDPOINT no responde tras 60 s"
}

descargar_modelo() {
    if [[ $DRY_RUN -eq 0 ]] && ollama list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$MODELO"; then
        log "El modelo $MODELO ya estaba presente; no se borrará al restaurar"
        estado_set MODELO_PREEXISTENTE 1
        return 0
    fi

    log "Descargando el modelo $MODELO (puede tardar y ocupar varios GB)"
    ejecutar ollama pull "$MODELO" || die "Falló la descarga del modelo"
    if [[ $DRY_RUN -eq 0 ]]; then estado_set MODELO_DESCARGADO_POR_SCRIPT 1; fi
}

# --------------------------------------------------------------------------
# Huella del entorno y ejecución
# --------------------------------------------------------------------------

huella_entorno() {
    local destino="$SALIDA/entorno.json"
    if [[ $DRY_RUN -eq 1 ]]; then printf '   [dry-run] huella -> %s\n' "$destino"; return 0; fi
    mkdir -p "$SALIDA"

    local ollama_version modelo_id gpu
    ollama_version="$(ollama --version 2>/dev/null | head -1 || echo "desconocida")"
    modelo_id="$(ollama list 2>/dev/null | awk -v m="$MODELO" '$1==m{print $2}' || true)"
    if command -v nvidia-smi >/dev/null 2>&1; then
        gpu="$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | head -1)"
    else
        gpu="no detectada"
    fi

    OLLAMA_VERSION="$ollama_version" MODELO_ID="$modelo_id" GPU="$gpu" \
    MODELO="$MODELO" ENDPOINT="$ENDPOINT" DESTINO="$destino" python3 - <<'PY'
import json, os, platform, re

def leer(path, patron, defecto="desconocido"):
    try:
        with open(path) as f:
            m = re.search(patron, f.read(), re.M)
            return m.group(1) if m else defecto
    except OSError:
        return defecto

datos = {
    "fecha": __import__("datetime").datetime.now().astimezone().isoformat(timespec="seconds"),
    "sistema": leer("/etc/os-release", r'^PRETTY_NAME="?([^"\n]+)"?'),
    "kernel": platform.release(),
    "cpu": leer("/proc/cpuinfo", r"^model name\s*:\s*(.+)$"),
    "cpu_nucleos": os.cpu_count(),
    "ram_gb": round(int(leer("/proc/meminfo", r"^MemTotal:\s+(\d+)", "0")) / 1024 / 1024),
    "gpu": os.environ.get("GPU", "no detectada"),
    "python": platform.python_version(),
    "ollama": os.environ.get("OLLAMA_VERSION", "desconocida"),
    "modelo": os.environ.get("MODELO"),
    "modelo_digest": os.environ.get("MODELO_ID") or "no registrado",
    "endpoint": os.environ.get("ENDPOINT"),
    "nota": "Sin nombre de equipo ni direcciones IP: la huella describe el entorno, no la identidad.",
}

with open(os.environ["DESTINO"], "w", encoding="utf-8") as f:
    json.dump(datos, f, ensure_ascii=False, indent=2)
    f.write("\n")
print("   huella escrita en", os.environ["DESTINO"])
PY
}

ejecutar_matriz() {
    log "Ejecutando la matriz de robustez"
    local estado=0
    ejecutar python3 "$RAIZ_REPO/scripts/robustez/prompt_robustness_matrix.py" run \
        --model "$MODELO" \
        --endpoint "$ENDPOINT" \
        --niveles $NIVELES \
        --sistema "$SISTEMA" \
        --repeticiones "$REPETICIONES" \
        --out "$SALIDA" || estado=$?
    if [[ $estado -eq 3 ]]; then
        warn "La matriz terminó con N0 > 0 (código 3): línea base fallida, no error de infraestructura. La evidencia está en $SALIDA."
        return 3
    fi
    return $estado
}

# --------------------------------------------------------------------------
# Restauración
# --------------------------------------------------------------------------

restaurar() {
    if [[ ! -f "$ESTADO" ]]; then
        log "No hay sesión registrada; nada que restaurar"
        return 0
    fi

    log "Restaurando el estado del equipo"
    local descargado instalado activo_antes habilitado_antes preexistente modelo_guardado
    descargado="$(estado_get MODELO_DESCARGADO_POR_SCRIPT 0)"
    instalado="$(estado_get OLLAMA_INSTALADO_POR_SCRIPT 0)"
    activo_antes="$(estado_get SERVICIO_ACTIVO_ANTES 0)"
    habilitado_antes="$(estado_get SERVICIO_HABILITADO_ANTES 0)"
    preexistente="$(estado_get MODELO_PREEXISTENTE 0)"
    modelo_guardado="$(estado_get MODELO "$MODELO")"

    # 1. Modelo: solo si lo descargamos nosotros y no estaba antes.
    if [[ "$descargado" == "1" && "$preexistente" != "1" ]]; then
        if command -v ollama >/dev/null 2>&1 && systemctl is-active --quiet ollama 2>/dev/null; then
            log "Eliminando el modelo $modelo_guardado"
            ejecutar ollama rm "$modelo_guardado" || warn "No se pudo eliminar el modelo"
        fi
    fi

    # 2. Ollama: desinstalación completa solo si lo instaló este script.
    if [[ "$instalado" == "1" && -n "$(command -v ollama 2>/dev/null)" ]]; then
        log "Desinstalando Ollama (lo instaló este script)"
        ejecutar sudo_c systemctl stop ollama || true
        ejecutar sudo_c systemctl disable ollama || true
        ejecutar sudo_c rm -f /etc/systemd/system/ollama.service
        ejecutar sudo_c rm -f "$(command -v ollama)"
        ejecutar sudo_c rm -rf /usr/local/lib/ollama
        ejecutar sudo_c rm -rf /usr/share/ollama
        ejecutar sudo_c userdel ollama || true
        ejecutar sudo_c groupdel ollama || true
        ejecutar sudo_c systemctl daemon-reload || true
        ok "Ollama eliminado"
    else
        # 3. Solo se restaura el estado del servicio si ya existía.
        if [[ "$activo_antes" == "0" ]]; then
            ejecutar sudo_c systemctl stop ollama || true
        fi
        if [[ "$habilitado_antes" == "0" ]]; then
            ejecutar sudo_c systemctl disable ollama || true
        fi
        ok "Estado del servicio restaurado"
    fi

    if [[ $DRY_RUN -eq 0 ]]; then
        rm -f "$ESTADO"
        rmdir "$ESTADO_DIR" 2>/dev/null || true
    fi
}

finalizar() {
    local codigo=$?
    trap - EXIT
    if [[ "$MODO" != "restaurar" ]]; then
        if [[ $CONSERVAR -eq 1 ]]; then
            warn "Se conserva el entorno. Para revertirlo: $0 --restore"
        else
            restaurar || warn "La restauración no terminó bien; revisa el estado manualmente"
        fi
    fi
    exit $codigo
}

# --------------------------------------------------------------------------
# Argumentos
# --------------------------------------------------------------------------

ayuda() {
    awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"
    cat <<'EOF'

Opciones:
  --modelo NOMBRE        Modelo a usar (por defecto qwen2.5-coder:7b)
  --niveles N0 N1        Niveles de la matriz (también "--niveles N0,N2")
  --repeticiones N       Repeticiones por caso (por defecto 3)
  --sistema v1|v2        Versión del prompt de sistema (por defecto v1)
  --endpoint URL         Endpoint de Ollama (por defecto http://127.0.0.1:11434)
  --salida DIR           Directorio de evidencia (por defecto docs/evidencias/<fecha>-robustez)
  --preparar             Instala y descarga el modelo, sin ejecutar la matriz
  --restore              Revierte una sesión anterior y termina
  --keep                 No restaura al terminar
  --dry-run              Muestra el plan sin ejecutar nada
  -y, --yes              No pide confirmación
  -h, --help             Muestra esta ayuda

Variables de entorno equivalentes: MODELO, NIVELES, REPETICIONES, ENDPOINT.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --modelo)      MODELO="$2"; shift 2 ;;
        --niveles)
            shift
            NIVELES=""
            while [[ $# -gt 0 && "$1" != --* ]]; do
                NIVELES="$NIVELES ${1//,/ }"
                shift
            done
            NIVELES="$(echo $NIVELES)"
            [[ -n "$NIVELES" ]] || die "--niveles requiere al menos un nivel (N0, N1, N2, N3)"
            for n in $NIVELES; do
                case "$n" in
                    N0|N1|N2|N3) ;;
                    *) die "Nivel no válido: $n (usa N0, N1, N2 o N3)" ;;
                esac
            done
            ;;
        --repeticiones) REPETICIONES="$2"; shift 2 ;;
        --sistema)
            SISTEMA="$2"; shift 2
            case "$SISTEMA" in
                v1|v2) ;;
                *) die "Sistema no válido: $SISTEMA (usa v1 o v2)" ;;
            esac
            ;;
        --endpoint)    ENDPOINT="$2"; shift 2 ;;
        --salida)      SALIDA="$2"; shift 2 ;;
        --preparar)    MODO="preparar"; shift ;;
        --restore)     MODO="restaurar"; shift ;;
        --keep)        CONSERVAR=1; shift ;;
        --dry-run)     DRY_RUN=1; shift ;;
        -y|--yes)      SI=1; shift ;;
        -h|--help)     ayuda; exit 0 ;;
        *) die "Opción desconocida: $1 (usa --help)" ;;
    esac
done

if [[ -z "$SALIDA" ]]; then
    SALIDA="$RAIZ_REPO/docs/evidencias/$(date +%Y-%m-%d)-robustez-ejecucion"
fi
if [[ -e "$SALIDA" && $DRY_RUN -eq 0 ]]; then
    SALIDA="${SALIDA}-$(date +%H%M)"
fi

trap finalizar EXIT

# --------------------------------------------------------------------------
# Flujo principal
# --------------------------------------------------------------------------

if [[ "$MODO" == "restaurar" ]]; then
    restaurar
    exit 0
fi

echo "════════════════════════════════════════════════════════════"
echo " Laboratorio de robustez de prompts — lab-ia-aprendizaje"
echo " Modelo: $MODELO · Niveles: $NIVELES · Repeticiones: $REPETICIONES · Prompt: $SISTEMA"
echo "════════════════════════════════════════════════════════════"
if [[ $DRY_RUN -eq 1 ]]; then echo " MODO SIMULACIÓN: no se ejecutará nada"; fi
echo

preflight

if [[ $SI -eq 0 && $DRY_RUN -eq 0 ]]; then
    echo
    echo "Se va a instalar Ollama si falta, descargar '$MODELO' si falta y"
    echo "ejecutar ${REPETICIONES} repeticiones por caso. Al terminar, el"
    echo "sistema se restaura salvo que uses --keep."
    read -r -p "¿Continuar? [y/N] " r
    [[ "$r" == "y" || "$r" == "Y" ]] || { echo "Cancelado."; exit 1; }
fi

if [[ $DRY_RUN -eq 0 ]]; then
    activo_antes=0
    habilitado_antes=0
    if systemctl is-active --quiet ollama 2>/dev/null; then activo_antes=1; fi
    if systemctl is-enabled --quiet ollama 2>/dev/null; then habilitado_antes=1; fi
    estado_ini
    estado_set SERVICIO_ACTIVO_ANTES "$activo_antes"
    estado_set SERVICIO_HABILITADO_ANTES "$habilitado_antes"
    sudo_c -v || die "Se necesitan privilegios para instalar o gestionar el servicio"
fi

instalar_ollama_si_falta
arrancar_servicio
esperar_endpoint
descargar_modelo
huella_entorno

if [[ "$MODO" == "preparar" ]]; then
    ok "Entorno preparado. Ejecuta la matriz cuando quieras."
    CONSERVAR=1
    exit 0
fi

ejecutar_matriz
ok "Evidencia en $SALIDA"
