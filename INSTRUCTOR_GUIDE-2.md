# Instructor Guide

## Git from Scratch: Master Version Control Like a Pro

## Propósito

Esta guía ayuda al instructor a preparar y facilitar el workshop. El contenido del participante se encuentra en `WORKSHOP.md` y en el Showroom bajo `documentation/modules/ROOT/pages/`.

## Preparación recomendada

### Entre 3 y 7 días antes

- Crear o validar el repositorio del workshop.
- Definir si se utilizará GitHub, GitLab o Gitea.
- Validar que cada participante pueda crear ramas y Pull Requests.
- Proteger `main` cuando el laboratorio utilice un repositorio compartido.
- Asignar un proyecto de OpenShift por participante o permitir su creación.
- Validar que OpenShift pueda clonar el repositorio.
- Validar acceso a `registry.access.redhat.com`.
- Ejecutar el flujo completo de build y deployment.
- Preparar un repositorio de respaldo.

### El día del workshop

- Ejecutar `./scripts/preflight.sh` en una estación equivalente.
- Crear un despliegue de prueba con `./scripts/deploy-from-git.sh`.
- Confirmar que la Route responde.
- Verificar cuotas y límites del clúster.
- Tener una rama preparada para la demostración de conflictos.
- Mantener abierto el panel de Builds, Pods y Routes.

## Agenda de facilitación

| Tiempo | Actividad | Enfoque del instructor |
|---:|---|---|
| 0:00–0:10 | Bienvenida | Objetivos, dinámica y reglas de seguridad |
| 0:10–0:20 | Preflight | Resolver acceso antes de comenzar Git |
| 0:20–0:40 | Modelo de Git | Working tree, staging y repository |
| 0:40–1:00 | Primer commit | `status`, `diff`, `add`, `commit`, `log` |
| 1:00–1:35 | Ramas | Aislamiento, comparación e historial |
| 1:35–1:45 | Pausa | — |
| 1:45–2:10 | Remotos | `fetch`, `pull`, `push`, tracking |
| 2:10–2:35 | Pull Request | Revisión, comentarios y merge |
| 2:35–3:05 | Conflictos | Provocar, leer, resolver y abortar |
| 3:05–3:25 | Recuperación | `restore`, `stash`, `revert`, tags |
| 3:25–3:50 | OpenShift | BuildConfig, ImageStream, rollout y Route |
| 3:50–4:00 | Cierre | Evidencias, preguntas y siguientes pasos |

Para ejecutar el reto final completo, ampliar a 4 horas 30 minutos o reducir las demostraciones previas.

## Método didáctico

Utilizar en cada módulo:

1. Explicar el concepto.
2. Demostrar el flujo.
3. Permitir que el participante lo repita.
4. Introducir un error controlado.
5. Diagnosticar con evidencia.
6. Recuperar el estado.
7. Relacionar el ejercicio con un entorno real.

## Decisiones de diseño

### Aplicación sin dependencias de npm

`lab-content/app/server.js` utiliza módulos nativos de Node.js. Esto evita depender de un registry npm durante el build.

### Docker strategy

La plantilla utiliza un `BuildConfig` con Docker strategy y un `Containerfile`. De esta forma, el código siempre se obtiene desde Git y la imagen se construye dentro de OpenShift.

### Un proyecto por participante

Es la modalidad recomendada. Evita colisiones en nombres de Builds, Deployments y Routes.

## Demostración del modelo mental de Git

Dibujar:

```text
archivo.txt
   |
   | editar
   v
Working tree
   |
   | git add
   v
Staging area
   |
   | git commit
   v
Repository
   |
   | git push
   v
Remote
```

Preguntar antes de revelar la respuesta:

- ¿`git add` sube el cambio al servidor?
- ¿Un commit existe en el remoto inmediatamente?
- ¿`git fetch` modifica el working tree?

## Estrategia para Pull Requests

En grupos grandes, crear parejas de revisión. Cada participante debe revisar al menos un Pull Request distinto del propio.

Checklist de revisión:

- ¿El diff corresponde al objetivo?
- ¿Hay secretos o datos sensibles?
- ¿El mensaje es comprensible?
- ¿La aplicación sigue iniciando?
- ¿La documentación quedó actualizada?

## Conflicto controlado

Evite provocar un conflicto directamente en `main` del repositorio compartido. Utilice un clon temporal o dos ramas privadas del instructor.

Comandos de recuperación:

```bash
git status
git diff --name-only --diff-filter=U
git merge --abort
```

## Troubleshooting de OpenShift

### El BuildConfig no puede clonar Git

```bash
oc describe buildconfig/git-workshop
oc get builds
oc logs build/<BUILD_NAME>
```

Revisar:

- DNS desde el clúster.
- Certificado TLS del servidor Git.
- Autenticación de repositorios privados.
- URL y rama configuradas.

### No existe acceso al registry base

El build requiere `registry.access.redhat.com/ubi9/nodejs-20-minimal`. Validar conectividad o sustituir `FROM` por una imagen base aprobada y disponible en el registry corporativo.

### El build termina, pero no hay rollout

```bash
oc get imagestreamtag git-workshop:latest
oc get deployment git-workshop -o yaml
oc describe deployment git-workshop
```

Validar la anotación `image.openshift.io/triggers`.

### La Route no responde

```bash
oc get pods -o wide
oc get service git-workshop
oc get endpoints git-workshop
oc describe route git-workshop
oc logs deployment/git-workshop
```

El servidor escucha en `0.0.0.0:8080`. Un cambio a `127.0.0.1` impediría el acceso desde el Service.

## Seguridad

Detener el ejercicio si un participante confirma un secreto real. Rotar el secreto y eliminarlo del historial con un procedimiento autorizado. Eliminar el archivo en un commit nuevo no borra las versiones anteriores.

## Evidencias para evaluación

Solicitar:

```bash
git log --oneline --decorate -5
git branch -vv
git tag --points-at HEAD
oc get build,deploy,svc,route
```

## Extensiones opcionales

- Agregar un webhook para iniciar builds después del push.
- Crear una Pipeline de OpenShift Pipelines/Tekton.
- Integrar Gitleaks.
- Proteger `main` y exigir revisiones.
- Crear una Argo CD Application apuntando a un overlay Kustomize.
- Firmar commits y tags.
