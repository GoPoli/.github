# **Despliegue de GoPoli en Kubernetes**

Esta guía describe cómo desplegar GoPoli en un clúster local de Kubernetes: **Docker Desktop** con Kubernetes activado o **Minikube**. El manifiesto funciona en cualquier clúster con un `StorageClass` por defecto.

## **Requisitos Previos**

1. Un clúster local, cualquiera de los dos:
   - **Docker Desktop**: *Settings → Kubernetes → Enable Kubernetes*.
   - **Minikube**: [Instrucciones de instalación](https://minikube.sigs.k8s.io/docs/start/) y `minikube start`.
2. **kubectl**: [Instrucciones de instalación](https://kubernetes.io/docs/tasks/tools/)

Comprueba el contexto activo antes de aplicar:

```bash
kubectl config current-context
kubectl get nodes
```

---

## **Opción 1: Ejecución Rápida**

```bash
kubectl apply -f https://raw.githubusercontent.com/GoPoli/.github/main/kubernetes/k8s-deployment.yml
kubectl -n gopoli rollout status deploy/api-gopoli --timeout=5m
```

| Clúster | PWA | API |
| --- | --- | --- |
| Docker Desktop | [http://localhost:30300](http://localhost:30300) | [http://localhost:30080/health](http://localhost:30080/health) |
| Minikube | `kubectl -n gopoli port-forward svc/web-gopoli 30300:3000` | `kubectl -n gopoli port-forward svc/api-gopoli 30080:8080` |

En Minikube cada `port-forward` ocupa una terminal; usar los mismos puertos locales (30300 y 30080) mantiene válidas la URL de la API y el origen CORS del `ConfigMap`.

Inicia sesión con `demo.local@elpoli.edu.co`, `conductor.demo@elpoli.edu.co` o `pasajera.demo@elpoli.edu.co` (contraseña `gopoli-local-dev`).

---

## **Opción 2: Despliegue Paso a Paso**

#### **Paso 1: Descargar el manifiesto**

```bash
curl -L https://raw.githubusercontent.com/GoPoli/.github/main/kubernetes/k8s-deployment.yml -o k8s-deployment.yml
```

#### **Paso 2: Ajustar la configuración**

| Recurso | Clave | Qué cambiar |
| --- | --- | --- |
| `Secret` `gopoli-secrets` | `POSTGRES_PASSWORD`, `GOPOLI_JWT_SECRET` | Valores propios (el secreto JWT con al menos 32 caracteres) |
| `ConfigMap` `gopoli-config` | `GOPOLI_SEED_DEMO` | `false` si no quieres cuentas de demostración |
| `ConfigMap` `gopoli-config` | `NEXT_PUBLIC_API_URL`, `CORS_ALLOWED_ORIGINS` | URLs de la API y de la PWA vistas desde el navegador |

#### **Paso 3: Aplicar**

```bash
kubectl apply -f k8s-deployment.yml
kubectl -n gopoli get pods -w
```

#### **Paso 4: Verificar**

```bash
curl http://localhost:30080/health
kubectl -n gopoli logs deploy/db-gopoli | grep GoPoli
```

La última línea confirma si se cargaron los datos de demostración.

#### **Paso 5: Eliminar**

```bash
kubectl delete -f k8s-deployment.yml
```

Se elimina el namespace `gopoli` completo, incluido el volumen de datos.

---

## **Recursos del Manifiesto**

| Recurso | Nombre | Descripción |
| --- | --- | --- |
| `Namespace` | `gopoli` | Aísla los recursos y exige el estándar de seguridad de pods `restricted` |
| `Secret` | `gopoli-secrets` | Contraseña de PostgreSQL y secreto JWT |
| `ConfigMap` | `gopoli-config` | Base, zona horaria, CORS, URL pública de la API y datos demo |
| `PersistentVolumeClaim` | `pg-data` | 1 GiB para los datos de PostgreSQL |
| `Deployment` + `Service` | `db-gopoli` | PostgreSQL (`ClusterIP` 5432), estrategia `Recreate` |
| `Deployment` + `Service` | `api-gopoli` | API (`NodePort` 30080), sondas en `/health` |
| `Deployment` + `Service` | `web-gopoli` | PWA (`NodePort` 30300), sondas en `/login` |
| `NetworkPolicy` | `db-only-from-api` | Solo la API puede conectarse a PostgreSQL |

## **Seguridad de los Pods**

El namespace aplica `pod-security.kubernetes.io/enforce: restricted`, y los tres `Deployment` lo cumplen:

| Medida | Configuración |
| --- | --- |
| Usuario sin privilegios | `runAsNonRoot: true` con UID 70 (PostgreSQL), 10001 (API) y 1000 (PWA) |
| Sistema de archivos de solo lectura | `readOnlyRootFilesystem: true` con `emptyDir` para `/tmp`, el socket de PostgreSQL y la compilación de la PWA |
| Sin escalada ni capacidades | `allowPrivilegeEscalation: false` y `capabilities.drop: [ALL]` |
| Perfil seccomp | `RuntimeDefault` |
| Sin token de la API de Kubernetes | `automountServiceAccountToken: false` |
| Recursos acotados | `requests` y `limits` de CPU y memoria |

La `NetworkPolicy` solo se aplica si el clúster usa un plugin de red que la soporte (Calico, Cilium); en Docker Desktop y en Minikube sin CNI se ignora sin error.

## **Detalles por Servicio**

### Base de Datos

`PGDATA` apunta a un subdirectorio del volumen para evitar conflictos con archivos del aprovisionador (`lost+found`), y `fsGroup: 70` da al usuario `postgres` permiso de escritura sobre el volumen. Las sondas usan `pg_isready` por TCP, así que el pod solo está listo cuando terminaron los scripts de inicialización.

### API

La API lee la contraseña y el secreto JWT desde `gopoli-secrets` y el resto desde `gopoli-config`, y se conecta al servicio interno `db-gopoli:5432`. La `startupProbe` le da hasta 3 minutos para arrancar antes de que actúe la `livenessProbe`.

### PWA

La PWA recibe `NEXT_PUBLIC_API_URL` al arrancar: la imagen copia la compilación a un `emptyDir` y reemplaza la URL, por lo que cambiarla solo requiere reiniciar el `Deployment`:

```bash
kubectl -n gopoli rollout restart deploy/web-gopoli
```

---

## **Imágenes locales**

Los `Deployment` usan `imagePullPolicy: IfNotPresent`. En Docker Desktop el clúster comparte las imágenes del motor de Docker, así que una imagen construida en local (`docker build -t ghcr.io/gopoli/gopoli-api:latest .`) se usa sin publicarla. En Minikube cárgala con `minikube image load ghcr.io/gopoli/gopoli-api:latest`.

## **Paquetes privados**

Si las imágenes de GHCR son privadas, crea un secreto de registro y referéncialo en cada `Deployment` con `imagePullSecrets`:

```bash
kubectl -n gopoli create secret docker-registry ghcr \
  --docker-server=ghcr.io \
  --docker-username=<usuario> \
  --docker-password=<token-read-packages>
```
