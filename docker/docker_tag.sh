#!/bin/bash

# Define the variables
version="KUBER_VERSION" #"v1.27.14"
registry="REGISTRY_URL" #"repo.me.ir:443"

# Define the list of images
images=(
    "rancher/mirrored-coreos-etcd:v3.5.10"
    "rancher/rke-tools:v0.1.96"
    "rancher/mirrored-k8s-dns-kube-dns:1.22.28"
    "rancher/mirrored-k8s-dns-dnsmasq-nanny:1.22.28"
)

# Step 1: Pull all images
for image in "${images[@]}"; do
    echo "Pulling $image"
    docker pull $image
    if [ $? -ne 0 ]; then
        echo "Failed to pull $image. Exiting."
        exit 1
    fi
done

# Step 2: Tag all images
for image in "${images[@]}"; do
    # Get the image name and version
    name_version=$(echo $image | awk -F'/' '{print $NF}')
    
    # Tag the image with the new format
    new_tag="${registry}/repository/linux_devops/kubernetes-images/${version}/${name_version}"
    
    echo "Tagging $image as $new_tag"
    docker tag $image $new_tag
done

# Step 3: Push all images to the new registry
for image in "${images[@]}"; do
    # Get the image name and version
    name_version=$(echo $image | awk -F'/' '{print $NF}')
    
    # The new tag that was applied earlier
    new_tag="${registry}/repository/linux_devops/kubernetes-images/${version}/${name_version}"
    
    echo "Pushing $new_tag"
    docker push $new_tag
    if [ $? -ne 0 ]; then
        echo "Failed to push $new_tag. Exiting."
        exit 1
    fi
done

echo "All images have been pulled, tagged, and pushed successfully."
