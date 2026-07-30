# Git from Scratch: Master Version Control Like a Pro

Workshop práctico para aprender Git desde los fundamentos hasta un flujo colaborativo profesional, utilizando un repositorio remoto y Red Hat OpenShift como plataforma de construcción y despliegue.

El repositorio incluye dos experiencias complementarias:

1. **Guía Markdown consolidada:** [`WORKSHOP.md`](WORKSHOP.md), útil para GitHub, GitLab, Gitea o lectura directa.
2. **Showroom navegable:** contenido Antora/AsciiDoc bajo `documentation/`, organizado con una navegación similar a los laboratorios de Red Hat Demo Platform.

## Objetivo

Al finalizar, cada participante podrá:

- Configurar Git y explicar su modelo de trabajo.
- Crear commits pequeños, claros y trazables.
- Trabajar con ramas de corta duración.
- Sincronizar cambios con un repositorio remoto.
- Crear y revisar Pull Requests o Merge Requests.
- Resolver conflictos de integración.
- Recuperar cambios de forma segura.
- Etiquetar versiones con tags.
- Construir y desplegar una aplicación desde Git en OpenShift.
- Entender el paso conceptual de Git hacia CI/CD y GitOps.

## Duración

**Duración recomendada:** 4 horas.

| Bloque | Tiempo |
|---|---:|
| Bienvenida, entorno y preflight | 20 min |
| Fundamentos y primer commit | 40 min |
| Ramas e historial | 35 min |
| Remotos y colaboración | 35 min |
| Pull Requests y conflictos | 45 min |
| Recuperación y versionado | 25 min |
| OpenShift: build y deployment desde Git | 45 min |
| Reto final y cierre | 35 min |

La ruta puede reducirse a 3 horas dejando GitOps y recuperación avanzada como demostraciones del instructor.

## Audiencia

- Personas sin experiencia previa con Git.
- Desarrolladores, administradores, SRE, DevOps y DevSecOps.
- Equipos que comenzarán a utilizar repositorios como fuente de verdad.
- Participantes que trabajarán con OpenShift, pipelines o GitOps.

## Requisitos

- Git 2.30 o superior.
- Acceso a una terminal Bash, Zsh o PowerShell.
- Acceso a un repositorio remoto: GitHub, GitLab, Gitea o equivalente.
- Acceso a un clúster OpenShift 4.x.
- Cliente `oc` compatible con el clúster.
- Permisos para crear proyectos o recursos dentro de un proyecto asignado.
- Acceso de salida desde OpenShift hacia el servidor Git y `registry.access.redhat.com`.

## Estructura del repositorio

```text
git-from-scratch-showroom/
├── README.md
├── WORKSHOP.md
├── INSTRUCTOR_GUIDE.md
├── default-site.yml
├── ui-config.yml
├── documentation/
│   ├── antora.yml
│   └── modules/ROOT/
│       ├── nav.adoc
│       ├── pages/
│       └── assets/images/
├── lab-content/
│   ├── app/
│   └── openshift/
├── scripts/
└── .github/workflows/gh-pages.yml
```

## Inicio rápido

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd git-from-scratch-showroom
```

### 2. Validar el entorno

```bash
./scripts/preflight.sh
```

### 3. Consultar la guía consolidada

Abrir [`WORKSHOP.md`](WORKSHOP.md).

### 4. Previsualizar el Showroom

Con Podman:

```bash
podman run --rm --name antora \
  -v "$PWD:/antora:z" \
  -p 8080:8080 \
  -it ghcr.io/juliaaano/antora-viewer
```

Abrir `http://localhost:8080`.

Con Docker, retirar `:z` si no se utiliza SELinux:

```bash
docker run --rm --name antora \
  -v "$PWD:/antora" \
  -p 8080:8080 \
  -it ghcr.io/juliaaano/antora-viewer
```

## Publicar en GitHub Pages

El workflow `.github/workflows/gh-pages.yml` genera el sitio con Antora y lo publica mediante GitHub Pages.

En el repositorio de GitHub:

1. Abrir **Settings → Pages**.
2. Seleccionar **GitHub Actions** como fuente.
3. Ejecutar el workflow manualmente o hacer push a `main`.

La salida se genera en `www/`.

## Desplegar la aplicación de ejemplo en OpenShift

Definir el repositorio que OpenShift podrá clonar:

```bash
export GIT_REPO_URL="https://git.example.com/<usuario>/git-from-scratch-showroom.git"
export GIT_REF="main"
export PROJECT="git-workshop-$(whoami | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
```

Ejecutar:

```bash
./scripts/deploy-from-git.sh
```

Validar:

```bash
./scripts/validate-deployment.sh
```

Limpiar:

```bash
./scripts/cleanup.sh
```

## Configuración del entorno Showroom

Los valores dinámicos se encuentran en `documentation/antora.yml`. Antes de entregar el laboratorio, ajuste como mínimo:

- `openshift_cluster_console_url`
- `openshift_api_server_url`
- `openshift_username`
- `openshift_password`
- `git_server_url`
- `git_username`
- `git_password`
- `git_repository_url`

No almacene credenciales reales en un repositorio público. En plataformas de laboratorio, estos atributos normalmente son reemplazados dinámicamente.

## Modelo de ramas sugerido

```text
main
 ├── feature/update-homepage
 ├── fix/route-validation
 └── docs/improve-workshop
```

Reglas recomendadas:

- `main` debe permanecer funcional.
- Cada rama debe tener un objetivo concreto.
- Los cambios se integran mediante Pull Request o Merge Request.
- Se recomienda squash merge para ejercicios introductorios.
- Las versiones se identifican con tags semánticos.

## Seguridad

Nunca almacenar en Git:

- Contraseñas o tokens.
- Kubeconfigs.
- Pull secrets.
- Llaves SSH privadas.
- Archivos `.env` con credenciales.
- Certificados privados.

El repositorio incluye un `.gitignore` inicial, pero este archivo no reemplaza controles como secret scanning, Gitleaks o políticas del servidor Git.

## Documentos principales

- [`WORKSHOP.md`](WORKSHOP.md): guía completa del participante.
- [`INSTRUCTOR_GUIDE.md`](INSTRUCTOR_GUIDE.md): preparación, tiempos, demostraciones y recuperación.
- [`documentation/modules/ROOT/pages/`](documentation/modules/ROOT/pages/): versión Showroom.
- [`lab-content/`](lab-content/): aplicación y recursos de OpenShift.

## Licencia

Contenido disponible bajo Apache License 2.0. Consulte [`LICENSE`](LICENSE).
