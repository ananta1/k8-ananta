kubectl create sa ananta
secret=$(kubectl get sa ananta -o json | jq -r .secrets[].name)
kubectl get secret $secret -o json | jq -r '.data["ca.crt"]' | base64 -d > ca.crt
user_token=$(kubectl get secret $secret -o json | jq -r '.data["token"]' | base64 -d)
c=$(kubectl config current-context)
echo $c
name=$(kubectl config get-contexts $c | awk '{print $3}' | tail -n 1)
echo $name
endpoint=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"$name\")].cluster.server}")
echo $endpoint
kubectl config set-cluster ananta-cluster   --embed-certs=true   --server=$endpoint   --certificate-authority=./ca.crt
kubectl config set-credentials ananta-cred --token=$user_token
kubectl config set-context ananta-context  --cluster=ananta-cluster  --user=ananta-cred
kubectl create rolebinding ananta-view --clusterrole=view --serviceaccount=default:ananta
kubectl config use-context ananta-context
