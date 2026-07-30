# Git from Scratch: Master Version Control Like a Pro

## Información general

Este workshop enseña Git mediante una secuencia de ejercicios progresivos. El participante comienza configurando su identidad local, crea un repositorio y registra sus primeros cambios. Después trabaja con ramas, repositorios remotos, Pull Requests, conflictos, tags y recuperación. La última parte conecta el flujo de Git con una construcción y un despliegue reales en Red Hat OpenShift.

> **Duración recomendada:** 4 horas  
> **Modalidad:** 30 % explicación, 60 % práctica, 10 % reto y cierre  
> **Nivel:** introductorio con cierre intermedio  
> **Resultado final:** una aplicación modificada mediante una rama, integrada mediante revisión y desplegada desde Git en OpenShift

---

## Arquitectura del laboratorio

```text
Participante
    |
    | clone / branch / commit / push
    v
Repositorio Git remoto
    |
    | BuildConfig clona el código
    v
OpenShift Build
    |
    | genera una imagen
    v
ImageStream
    |
    | activa el rollout
    v
Deployment -> Service -> Route
```

---

## Módulo 1. Preparar el entorno

**Tiempo estimado:** 20 minutos

### Objetivos

- Validar Git y `oc`.
- Configurar la identidad de Git.
- Autenticarse en el clúster.
- Identificar el repositorio remoto y el proyecto de OpenShift.

### 1.1 Validar herramientas

```bash
git --version
oc version --client
```

También puede ejecutar:

```bash
./scripts/preflight.sh
```

### 1.2 Configurar identidad

```bash
git config --global user.name "Nombre Apellido"
git config --global user.email "correo@example.com"
git config --global init.defaultBranch main
```

Validar:

```bash
git config --global --list
```

### 1.3 Autenticarse en OpenShift

```bash
oc login <OPENSHIFT_API_URL> -u <USUARIO> -p '<PASSWORD>'
oc whoami
oc cluster-info
```

> No copie un token o contraseña dentro de un archivo que será versionado.

### Verificación

```bash
git --version
oc whoami
git config --global user.name
git config --global user.email
```

---

## Módulo 2. Comprender Git

**Tiempo estimado:** 20 minutos

Git es un sistema distribuido de control de versiones. Cada clon contiene el historial y permite trabajar localmente.

### Las tres áreas principales

```text
Working tree  ->  Staging area  ->  Local repository
  modificar          git add            git commit
```

- **Working tree:** archivos visibles y editables.
- **Staging area:** selección exacta del próximo commit.
- **Local repository:** historial confirmado.
- **Remote repository:** punto de colaboración y respaldo compartido.

### Git frente a GitHub, GitLab o Gitea

- **Git** es la herramienta de control de versiones.
- **GitHub, GitLab y Gitea** hospedan repositorios y agregan colaboración, revisión, permisos, issues y automatización.

### Primer experimento

```bash
mkdir git-sandbox
cd git-sandbox
git init
git status
```

Eliminar el sandbox al terminar:

```bash
cd ..
rm -rf git-sandbox
```

---

## Módulo 3. Crear commits útiles

**Tiempo estimado:** 25 minutos

### 3.1 Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd git-from-scratch-showroom
```

### 3.2 Explorar estado e historial

```bash
git status
git log --oneline --decorate --graph --all -10
```

### 3.3 Crear un archivo personal

```bash
mkdir -p participants
cat > "participants/$(whoami).md" <<EOF
# Participante: $(whoami)

- Objetivo: aprender un flujo profesional de Git.
- Plataforma: OpenShift.
EOF
```

Revisar:

```bash
git status
git diff
```

Preparar y confirmar:

```bash
git add "participants/$(whoami).md"
git diff --staged
git commit -m "docs: add participant profile"
```

### Mensajes de commit

Convención sugerida:

```text
feat: add homepage customization
fix: correct OpenShift route check
docs: clarify repository setup
test: add response validation
chore: update workshop metadata
```

Un buen commit responde:

1. ¿Qué cambió?
2. ¿Por qué existe este cambio?
3. ¿Puede revisarse de forma aislada?

---

## Módulo 4. Trabajar con ramas

**Tiempo estimado:** 35 minutos

### 4.1 Crear una feature branch

```bash
git switch -c feature/personalize-homepage
```

Verificar:

```bash
git branch --show-current
git branch -vv
```

### 4.2 Modificar la aplicación

Editar `lab-content/app/public/index.html` y cambiar:

```html
<h1>Git from Scratch</h1>
```

por un título personal, por ejemplo:

```html
<h1>Git from Scratch — Heber's Lab</h1>
```

Revisar el cambio:

```bash
git diff -- lab-content/app/public/index.html
```

Confirmar:

```bash
git add lab-content/app/public/index.html
git commit -m "feat: personalize workshop homepage"
```

### 4.3 Visualizar el historial

```bash
git log --graph --decorate --oneline --all
```

### 4.4 Comparar ramas

```bash
git diff main...feature/personalize-homepage
```

---

## Módulo 5. Repositorios remotos

**Tiempo estimado:** 25 minutos

### 5.1 Identificar el remoto

```bash
git remote -v
```

El remoto principal normalmente se llama `origin`.

### 5.2 Publicar la rama

```bash
git push -u origin feature/personalize-homepage
```

La opción `-u` establece la rama de seguimiento. Los siguientes pushes pueden ejecutarse con:

```bash
git push
```

### 5.3 Fetch frente a pull

```bash
git fetch origin
git log --oneline --decorate --all -10
```

`git fetch` actualiza referencias remotas sin integrar cambios. `git pull` descarga e integra en la rama actual.

Para mantener un historial lineal durante el laboratorio:

```bash
git pull --rebase origin main
```

---

## Módulo 6. Pull Requests y revisión

**Tiempo estimado:** 25 minutos

Desde GitHub, GitLab, Gitea o la plataforma asignada:

1. Crear un Pull Request o Merge Request desde `feature/personalize-homepage` hacia `main`.
2. Utilizar un título concreto: `feat: personalize workshop homepage`.
3. Explicar qué cambió.
4. Indicar cómo se validó.
5. Solicitar revisión a otra persona.
6. Revisar la pestaña de cambios.
7. Atender comentarios.
8. Integrar utilizando el método acordado por el instructor.

### Plantilla sugerida

```markdown
## What changed?

- Personalized the workshop homepage.

## Why?

- Identifies the participant deployment during the final exercise.

## Validation

- Reviewed the local diff.
- Started the application locally.
- Confirmed HTTP 200 on port 8080.
```

### Después del merge

```bash
git switch main
git pull --ff-only origin main
git branch -d feature/personalize-homepage
```

---

## Módulo 7. Resolver conflictos

**Tiempo estimado:** 30 minutos

### 7.1 Crear dos cambios incompatibles

Primera rama:

```bash
git switch main
git switch -c feature/blue-team-title
```

Modificar la línea `<h1>` y confirmar:

```bash
git add lab-content/app/public/index.html
git commit -m "feat: add blue team title"
```

Cambiar a `main` y crear otra modificación en la misma línea:

```bash
git switch main
git switch -c feature/platform-team-title
```

Confirmar el segundo cambio:

```bash
git add lab-content/app/public/index.html
git commit -m "feat: add platform team title"
```

Integrar la primera rama:

```bash
git merge feature/blue-team-title
```

Git mostrará marcadores como:

```text
<<<<<<< HEAD
<h1>Git Workshop — Platform Team</h1>
=======
<h1>Git Workshop — Blue Team</h1>
>>>>>>> feature/blue-team-title
```

Editar el archivo y conservar una versión consensuada:

```html
<h1>Git Workshop — Platform & Blue Team</h1>
```

Finalizar:

```bash
git add lab-content/app/public/index.html
git commit -m "merge: resolve homepage title conflict"
```

### Abortar una integración

Antes de confirmar la resolución:

```bash
git merge --abort
```

### Mensaje clave

Un conflicto no es corrupción. Git detiene la integración porque requiere una decisión humana sobre el contenido final.

---

## Módulo 8. Recuperación y versionado

**Tiempo estimado:** 25 minutos

### Descartar un cambio no preparado

```bash
git restore <archivo>
```

### Retirar un archivo del staging area

```bash
git restore --staged <archivo>
```

### Guardar trabajo temporalmente

```bash
git stash push -m "work in progress"
git stash list
git stash pop
```

### Revertir un commit publicado

```bash
git log --oneline
git revert <COMMIT_ID>
```

`git revert` crea un nuevo commit inverso y conserva la trazabilidad.

### Crear una versión

```bash
git tag -a v1.0.0 -m "Git workshop application v1.0.0"
git show v1.0.0
git push origin v1.0.0
```

### Regla de seguridad

Evite `git reset --hard` y `git push --force` mientras no comprenda exactamente qué referencias y cambios serán eliminados. Para ramas compartidas, prefiera `git revert`.

---

## Módulo 9. Construir y desplegar desde Git en OpenShift

**Tiempo estimado:** 45 minutos

### 9.1 Preparar variables

```bash
export GIT_REPO_URL="https://git.example.com/<usuario>/git-from-scratch-showroom.git"
export GIT_REF="main"
export APP_NAME="git-workshop"
export PROJECT="git-workshop-$(whoami | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
```

> El clúster debe poder acceder a `GIT_REPO_URL`. Una URL local de su laptop no funcionará desde el BuildConfig.

### 9.2 Crear el despliegue

```bash
./scripts/deploy-from-git.sh
```

El script procesa `lab-content/openshift/template.yaml`, que crea:

- `ImageStream`
- `BuildConfig`
- `Deployment`
- `Service`
- `Route`

### 9.3 Observar el build

```bash
oc get builds
oc logs -f bc/${APP_NAME}
```

También puede iniciar otro build:

```bash
oc start-build ${APP_NAME} --follow
```

### 9.4 Observar el rollout

```bash
oc rollout status deployment/${APP_NAME} --timeout=5m
oc get pods
oc get service
oc get route
```

### 9.5 Abrir la aplicación

```bash
ROUTE_URL="https://$(oc get route ${APP_NAME} -o jsonpath='{.spec.host}')"
echo "${ROUTE_URL}"
curl -kI "${ROUTE_URL}"
```

### 9.6 Actualizar desde Git

Crear una rama:

```bash
git switch -c feature/change-banner
```

Modificar `lab-content/app/public/index.html`, confirmar, publicar y crear el Pull Request.

Después del merge:

```bash
git switch main
git pull --ff-only origin main
oc start-build ${APP_NAME} --follow
oc rollout status deployment/${APP_NAME} --timeout=5m
```

Refrescar la Route para comprobar el cambio.

### Diagnóstico

```bash
oc get events --sort-by='.lastTimestamp' | tail -30
oc describe buildconfig/${APP_NAME}
oc describe deployment/${APP_NAME}
oc logs deployment/${APP_NAME}
oc get endpoints ${APP_NAME}
```

---

## Módulo 10. De Git a GitOps

**Tiempo estimado:** 15 minutos

### Flujo imperativo

```text
Persona -> oc apply / oc start-build -> OpenShift
```

### Flujo declarativo GitOps

```text
Commit -> Pull Request -> Merge -> Argo CD -> Reconciliación -> OpenShift
```

En GitOps:

- Git conserva el estado deseado.
- La revisión ocurre antes de cambiar el clúster.
- Un controlador compara Git con el estado real.
- La reconciliación corrige diferencias.
- El rollback puede implementarse revirtiendo un commit.

Este workshop no requiere Argo CD para completarse, pero los manifiestos versionados dejan preparada la transición a OpenShift GitOps.

---

## Módulo 11. Reto final: From Commit to OpenShift

**Tiempo estimado:** 35 minutos

Sin copiar toda la secuencia del instructor, completar:

1. Actualizar `main`.
2. Crear `feature/<usuario>-final`.
3. Personalizar título, mensaje y nombre del participante.
4. Revisar `git status` y `git diff`.
5. Crear un commit siguiendo Conventional Commits.
6. Publicar la rama.
7. Crear un Pull Request.
8. Solicitar revisión.
9. Integrar el cambio.
10. Actualizar la rama local `main`.
11. Crear el tag `v1.1.0`.
12. Ejecutar un build en OpenShift.
13. Validar rollout, Service, endpoints y Route.
14. Compartir la URL y el identificador del commit desplegado.

### Evidencias

```bash
git log -1 --oneline
git tag --points-at HEAD
oc get build -l buildconfig=${APP_NAME}
oc get deployment ${APP_NAME}
oc get route ${APP_NAME}
```

### Criterios de éxito

- No hay cambios sin confirmar.
- La rama fue revisada antes del merge.
- `main` contiene el cambio final.
- El tag apunta al commit esperado.
- El build terminó como `Complete`.
- El Deployment está `Available`.
- La Route responde con HTTP 200.

---

## Limpieza

Eliminar solamente el proyecto del participante:

```bash
./scripts/cleanup.sh
```

O manualmente:

```bash
oc delete project "${PROJECT}"
```

Eliminar ramas remotas que ya no se necesitan:

```bash
git push origin --delete <RAMA>
```

---

## Hoja rápida de comandos

| Objetivo | Comando |
|---|---|
| Estado | `git status` |
| Diferencias locales | `git diff` |
| Diferencias preparadas | `git diff --staged` |
| Preparar archivo | `git add <archivo>` |
| Crear commit | `git commit -m "tipo: mensaje"` |
| Ver historial | `git log --graph --oneline --all` |
| Crear rama | `git switch -c <rama>` |
| Cambiar de rama | `git switch <rama>` |
| Publicar rama | `git push -u origin <rama>` |
| Descargar referencias | `git fetch origin` |
| Actualizar main | `git pull --ff-only origin main` |
| Guardar temporalmente | `git stash` |
| Revertir commit | `git revert <id>` |
| Crear tag | `git tag -a v1.0.0 -m "mensaje"` |
| Ver builds | `oc get builds` |
| Iniciar build | `oc start-build git-workshop --follow` |
| Ver rollout | `oc rollout status deploy/git-workshop` |
| Obtener Route | `oc get route git-workshop` |

---

## Cierre

Dominar Git no significa memorizar todos sus comandos. Significa comprender el movimiento de un cambio: se edita, se revisa, se selecciona, se confirma, se comparte, se valida y finalmente se integra. Cuando ese historial alimenta OpenShift, Git se convierte además en una pieza central de entrega, auditoría y operación.
