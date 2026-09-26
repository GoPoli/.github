# **Despliegue de GoPoli en Kubernetes (Minikube)**

Esta guía describe cómo desplegar GoPoli en un clúster local de Kubernetes con **Minikube**. El manifiesto también funciona en Docker Desktop con Kubernetes activado o en cualquier clúster con un `StorageClass` por defecto.

## **Requisitos Previos**

1. **Minikube**: [Instrucciones de instalación](https://minikube.sigs.k8s.io/docs/start/)
2. **kubectl**: [Instrucciones de instalación](https://kubernetes.io/docs/tasks/tools/)
3. **Docker** (opcional): [Instrucciones de instalación](https://docs.docker.com/get-docker/)

> [!NOTE]
> Inicia Minikube antes de continuar:
>
> ```bash
> minikube start
> ```

---

## **Opción 1: Ejecución Rápida**

```bash
kubectl apply -f https://raw.githubusercontent.com/GoPoli/.github/main/kubernetes/k8s-deployment.yml
```

Espera a que los pods estén listos:

```bash
kubectl -n gopoli get pods -w
```

Expón la API y la PWA en tu equipo:

```bash
kubectl -n gopoli port-forward svc/api-gopoli 8080:8080
kubectl -n gopoli port-forward svc/web-gopoli 3000:3000
```

Cada `port-forward` ocupa una terminal. Abre [http://localhost:3000](http://localhost:3000) e inicia sesión con `demo.local@elpoli.edu.co` / `gopoli-local-dev`.

---

## **Opción 2: Despliegue Paso a Paso**

#### **Paso 1: Descargar el manifiesto**

```bash
curl -L https://raw.githubusercontent.com/GoPoli/.github/main/kubernetes/k8s-deployment.yml -o k8s-deployment.yml
```

#### **Paso 2: Ajustar los secretos**

Edita el `Secret` `gopoli-secrets` y cambia `POSTGRES_PASSWORD` y `GOPOLI_JWT_SECRET` (mínimo 32 caracteres).

#### **Paso 3: Aplicar**

```bash
kubectl apply -f k8s-deployment.yml
```

#### **Paso 4: Acceder por NodePort (alternativa a port-forward)**

Los servicios exponen puertos fijos: API en `30080` y PWA en `30300`.

```bash
minikube service -n gopoli api-gopoli --url
minikube service -n gopoli web-gopoli --url
```

Si accedes por NodePort, la PWA debe conocer la URL de la API vista desde el navegador:

```bash
kubectl -n gopoli set env deployment/web-gopoli NEXT_PUBLIC_API_URL=http://$(minikube ip):30080
```

#### **Paso 5: Eliminar**

```bash
kubectl delete -f k8s-deployment.yml
```

Se elimina el namespace `gopoli` completo, incluido el volumen de datos.

---

## **Recursos del Manifiesto**

| Recurso | Nombre | Descripción |
| --- | --- | --- |
| `Namespace` | `gopoli` | Aísla todos los recursos del proyecto |
| `Secret` | `gopoli-secrets` | Contraseña de PostgreSQL y secreto JWT |
| `PersistentVolumeClaim` | `pg-data` | 1 GiB para los datos de PostgreSQL |
| `Deployment` + `Service` | `db-gopoli` | PostgreSQL (`ClusterIP` 5432), estrategia `Recreate` |
| `Deployment` + `Service` | `api-gopoli` | API (`NodePort` 30080), readiness en `/carreras` |
| `Deployment` + `Service` | `web-gopoli` | PWA (`NodePort` 30300), readiness en `/login` |

### Base de Datos

```yaml
containers:
  - name: postgres
    image: ghcr.io/gopoli/gopoli-db:latest
    env:
      - name: PGDATA
        value: /var/lib/postgresql/data/pgdata
```

`PGDATA` apunta a un subdirectorio del volumen para evitar conflictos con archivos del aprovisionador (`lost+found`).

### API

La API lee la contraseña de la base y el secreto JWT desde `gopoli-secrets` y se conecta al servicio interno `db-gopoli:5432`. Kubernetes solo le envía tráfico cuando `GET /carreras` responde.

### PWA

La PWA recibe `NEXT_PUBLIC_API_URL` como variable de entorno; la imagen la inyecta al arrancar, por lo que cambiarla solo requiere reiniciar el `Deployment`.

---

## **Paquetes privados**

Si las imágenes de GHCR son privadas, crea un secreto de registro y referéncialo en cada `Deployment` con `imagePullSecrets`:

```bash
kubectl -n gopoli create secret docker-registry ghcr \
  --docker-server=ghcr.io \
  --docker-username=<usuario> \
  --docker-password=<token-read-packages>
```
