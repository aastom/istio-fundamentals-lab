#!/bin/bash

# This script generates continuous traffic to the Bookinfo application's
# productpage to simulate user activity. This is necessary to visualize
# traffic flow in Kiali and see metrics in Grafana.

# Find the Ingress Gateway URL and Port. This may vary based on your cluster provider.
# On Minikube, 'minikube service istio-ingressgateway -n istio-system --url' is a good way.
# On GKE or other cloud providers, 'kubectl -n istio-system get service istio-ingressgateway'
# will show an external IP.
export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$GATEWAY_URL" ]; then
  echo "Could not find Ingress Gateway IP. Please set GATEWAY_URL environment variable manually."
  echo "Example: export GATEWAY_URL=$(minikube ip):$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"
  exit 1
fi

echo "Generating load for Bookinfo at http://$GATEWAY_URL/productpage"
echo "(Press Ctrl+C to stop)"

while true; do
  curl -s -o /dev/null "http://$GATEWAY_URL/productpage"
  sleep 1
done