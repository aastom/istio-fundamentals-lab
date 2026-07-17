#!/bin/bash

# This script deletes all the Kubernetes and Istio resources created during the lab.
# It helps to reset the environment to a clean state.

echo "Deleting Istio traffic management resources..."
kubectl delete virtualservice productpage reviews
kubectl delete gateway bookinfo-gateway
kubectl delete destinationrule productpage reviews ratings details

echo "Deleting Bookinfo application..."
kubectl delete -f ../app/bookinfo.yaml

echo "Cleanup complete. You may want to disable sidecar injection if you enabled it for the namespace:"
echo "kubectl label namespace default istio-injection-"