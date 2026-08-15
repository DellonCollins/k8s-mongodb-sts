# create resources
kubectl apply -f mongo-configmap.yaml,mongodb-pv.yaml,mongodb-sts.yaml,mongodb-service.yaml,mongo-express-d.yaml,mongo-express-service.yaml
kubectl create secret generic mongodb-config --from-env-file=mongodb.env

# initiate db replica set
kubectl exec -it mongodb-0 -- mongosh -u username -p password --eval "$(cat ./initiate_mongo_replica.txt)"
