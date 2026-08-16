# create resources
kubectl apply -f mongo-configmap.yaml,mongodb-pv.yaml,mongodb-service.yaml,mongodb-sts.yaml,mongo-express-service.yaml,mongo-express-d.yaml
kubectl create secret generic mongodb-secret --from-env-file=mongodb.env

# initiate db replica set


# expose the mongo-express service
minikube service mongo-express-service

# initiate db replica set
repl_set_cmd='kubectl exec -it mongodb-0 -- mongosh -u username -p password --eval "$(cat ./initiate_mongo_replica.txt)"'
echo Run this command to initiate the replica set once all pods are online
echo $repl_set_cmd