#!/usr/bin/env bash

minikube start

bash ./deploy_encryption

# create configs
echo "\nCreating secrets and configmap"
kubectl create secret generic mongodb-secret --from-env-file=mongodb.env
kubectl apply -f mongo-configmap.yaml

# create mongodb backend
echo -e "\nDeploying mongodb backend"
kubectl apply -f mongodb-pv.yaml,mongodb-service.yaml,mongodb-sts.yaml
kubectl rollout status --watch --timeout=600s statefulset/mongodb


# initiate db replica set after they are online

sleep 10
initiate_mongo_replica="$(cat ./initiate_mongo_replica.txt)"
repl_set_cmd="kubectl exec -it mongodb-0 -- mongosh -u 'username' -p 'password' --eval '$initiate_mongo_replica'"
echo -e "\nRun this command to initiate the replica set if initation fails"
echo -e "\n$repl_set_cmd"

eval $repl_set_cmd
mongo_repl_set_init_status=$?

# create mongo-express frontend
echo -e "\nDeploying mongo express frontend\n"
kubectl apply -f mongo-express-d.yaml,mongo-express-service.yaml
kubectl rollout status --watch --timeout=600s deployment/mongo-express

# expose the mongo-express service when it's ready
minikube service mongo-express-service


