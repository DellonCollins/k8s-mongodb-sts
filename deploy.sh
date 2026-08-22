#!/usr/bin/env bash

minikube start

# enable volume snapshoting
minikube addons enable csi-hostpath-driver
minikube addons enable volumesnapshots

bash ./deploy_encryption
if [[ $? = 1 ]]; then 
	echo "encryption deployment failed"; 
	exit 1; 
fi

# create configs
echo -e "\nCreating secrets and configmap"
kubectl create secret generic mongodb-secret --from-env-file=mongodb.env
kubectl apply -f mongo-configmap.yaml

# create mongodb backend
echo -e "\nDeploying mongodb backend"
# kubectl apply -f mongodb-pv.yaml
kubectl apply -f mongodb-service.yaml,mongodb-sts.yaml
echo
kubectl rollout status --watch --timeout=600s statefulset/mongodb

# initiate db replica set after they are online

sleep 10
initiate_mongo_replica="$(cat ./initiate_mongo_replica.txt)"
repl_set_cmd="kubectl exec -it mongodb-0 -- mongosh -u 'username' -p 'password' --eval '$initiate_mongo_replica'"
echo -e "\nRun this command to initiate the replica set if initation fails"
echo -e "\n$repl_set_cmd"

eval $repl_set_cmd
if [[ $? -eq 0 ]] ; then 
	echo -e "\nReplicaSet Initiation Successful"
fi

# create mongo-express frontend
echo -e "\nDeploying mongo express frontend\n"
kubectl apply -f mongo-express-d.yaml,mongo-express-service.yaml
echo
kubectl rollout status --watch --timeout=600s deployment/mongo-express

# expose the mongo-express service when it's ready
minikube service mongo-express-service


