# Istio Fundamentals Lab

This repository contains all the configuration and scripts needed to execute a hands-on learning plan for Istio. The goal is to provide a "crawl-walk-run" path to understanding Istio's core traffic management and observability features.

## 📚 Documentation
*   **Drive Folder:** [Link to be added]
*   **Documentation Bundle:** [Link to be added]

---

## Overview

This lab walks you through:
1.  **Core Concepts**: What a service mesh is and why it's used.
2.  **Basic Routing**: Exposing a service to external traffic with a `Gateway` and `VirtualService`.
3.  **Canary Deployments**: Splitting traffic between different versions of a service using a `DestinationRule` and `VirtualService`.
4.  **Observability**: Using Kiali, Grafana, and Jaeger to visualize the mesh and trace requests.

## Concepts & Trade-Offs

### Why a Service Mesh?
In a microservices architecture, you have many small services communicating over the network. This introduces challenges:
*   **Observability**: How do you trace a request that spans five services?
*   **Security**: How do you enforce that service A can talk to service B, but not service C?
*   **Traffic Control**: How do you safely roll out a new version of a service without causing an outage?

A service mesh like Istio addresses these by inserting a proxy (the "sidecar") next to each service. All traffic goes through the proxy, which is controlled by a central "control plane." This gives you a single place to manage security, routing, and telemetry for your entire network.

### The "Performance Tax"
This power comes at a cost. Every service gets a sidecar proxy, which consumes additional CPU and memory. Every network call now has an extra "hop" through the local proxy. This is the **performance tax**. For a small number of services, the overhead can outweigh the benefits. You should reach for a service mesh when the complexity of your microservices environment justifies the cost of the tooling.

## Prerequisites

1.  A working Kubernetes cluster.
2.  Istio installed on the cluster. It is **highly recommended** to use the `demo` profile, as it includes the necessary observability tools (Kiali, Grafana, Jaeger).

You can install it with `istioctl`:
```sh
istioctl install --set profile=demo -y
```
Refer to the [Official Istio Documentation](https://istio.io/latest/docs/setup/getting-started/) for detailed setup instructions.

---

## The Lab: A Step-by-Step Guide

### Step 0: Prepare the Namespace
Enable automatic Istio sidecar injection on the `default` namespace. This tells Istio to automatically add the Envoy proxy to any pods you deploy here.
```sh
kubectl label namespace default istio-injection=enabled
```

### Step 1: Deploy the Application Playground
Deploy the `bookinfo` sample application.
```sh
kubectl apply -f app/bookinfo.yaml
```
This deploys four microservices: `productpage`, `details`, `ratings`, and `reviews` (with three different versions: v1, v2, v3).

### Step 2: Ingress and Basic Routing (Crawl)
Apply the first manifest to let traffic into the mesh and route it to `productpage-v1`.
```sh
kubectl apply -f manifests/01-gateway.yaml
```
*   The `Gateway` opens port 80 on the ingress load balancer.
*   The `VirtualService` attaches to that gateway and routes all incoming traffic to the `v1` subset of the `productpage` service.

At this point, you can get your gateway URL and open `/productpage` in a browser. You should see the Bookinfo application, with no ratings stars.

### Step 3: Define Service Subsets (Walk)
Apply the destination rules. These define the `v1`, `v2`, and `v3` subsets that Istio can route to.
```sh
kubectl apply -f manifests/02-destination-rules.yaml
```
**Note:** This step doesn't change any behavior. It only gives Istio the metadata it needs for the next step.

### Step 4: Implement the Canary Release (Run)
Now, split traffic to the `reviews` service. 90% will go to `v1` (no stars) and 10% will go to `v2` (black stars).
```sh
kubectl apply -f manifests/03-canary-reviews.yaml
```
If you refresh the `/productpage` in your browser, you will now see the black stars appear roughly 10% of the time. You have successfully performed a canary release!

### Step 5: Experience the "Aha!" Moment: Observability
1.  **Generate Load**: Run the `generate-load.sh` script to simulate user traffic.
    ```sh
    ./scripts/generate-load.sh
    ```
2.  **Open the Dashboards**:
    ```sh
    istioctl dashboard kiali
    istioctl dashboard grafana
    istioctl dashboard jaeger
    ```
    *   In **Kiali**, go to the "Graph" view for the `default` namespace. You will see a service diagram showing the 90/10 traffic split on the `reviews` service.
    *   In **Grafana**, find the "Istio Service Dashboard". You can see request rates, latency, and other metrics for each service.
    *   In **Jaeger**, you can find traces for `/productpage` and see exactly how a request flows through the different services and versions.

### Step 6: Cleanup
Run the cleanup script to remove all the resources you created.
```sh
./scripts/cleanup.sh
```

## Repository Structure

```
istio-fundamentals-lab/
├── README.md               # This guide.
├── app/
│   └── bookinfo.yaml       # Manifest to deploy the bookinfo sample application.
├── manifests/
│   ├── 01-gateway.yaml     # Ingress Gateway and initial VirtualService.
│   ├── 02-destination-rules.yaml # DestinationRules for all services.
│   └── 03-canary-reviews.yaml    # VirtualService for the reviews canary release.
└── scripts/
    ├── generate-load.sh    # Simple script to generate HTTP traffic.
    └── cleanup.sh          # Script to delete all lab resources.
```
