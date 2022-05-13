export IPFS_CLUSTER_PATH=$(aws --region=ca-central-1 ssm get-parameters --names 'IPFS_CLUSTER_PATH' --query "Parameters[0].Value" --output text)
export CLUSTER_SECRET=$(aws --region=ca-central-1 ssm get-parameters --names 'CLUSTER_SECRET' --query "Parameters[0].Value" --output text)
export IPFS_CLUSTER_BOOTSTRAP_ID=$(aws --region=ca-central-1 ssm get-parameters --names 'IPFS_CLUSTER_BOOTSTRAP_ID' --query "Parameters[0].Value" --output text)
export CLUSTER_IPFSHTTP_NODEMULTIADDRESS=/dns4/ipfs/tcp/5001
export CLUSTER_CRDT_TRUSTEDPEERS='*' # Trust all peers in Cluster
export CLUSTER_RESTAPI_HTTPLISTENMULTIADDRESS=/ip4/0.0.0.0/tcp/9094 # Expose API
export CLUSTER_MONITORPINGINTERVAL=2s # Speed up peer discover
