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

# Initialize error tracking arrays
failed_pulls=()
failed_tags=()
failed_pushes=()

# Step 1: Pull images only if they are not already present
for image in "${images[@]}"; do
    # Check if the image is already present locally
    if [[ "$(docker images -q $image 2> /dev/null)" == "" ]]; then
        echo "##### Pulling $image #####"
        docker pull $image
        if [ $? -ne 0 ]; then
            echo "##### Failed to pull $image. Skipping to the next image. #####"
            failed_pulls+=("$image")
            continue
        fi
    else
        echo "##### $image already exists locally. Skipping pull. #####"
    fi
done

# Step 2: Tag all images
for image in "${images[@]}"; do
    # Get the image name and version
    name_version=$(echo $image | awk -F'/' '{print $NF}')
    
    # Tag the image with the new format
    new_tag="${registry}/repository/linux_devops/kubernetes-images/${version}/${name_version}"
    
    echo "##### Tagging $image as $new_tag #####"
    docker tag $image $new_tag
    if [ $? -ne 0 ]; then
        echo "##### Failed to tag $image. Skipping to the next image. #####"
        failed_tags+=("$image")
        continue
    fi
done

# Step 3: Push all images to the new registry with a 5-second delay between each push
for image in "${images[@]}"; do
    # Get the image name and version
    name_version=$(echo $image | awk -F'/' '{print $NF}')
    
    # The new tag that was applied earlier
    new_tag="${registry}/repository/linux_devops/kubernetes-images/${version}/${name_version}"
    
    echo "##### Pushing $new_tag #####"
    docker push $new_tag
    if [ $? -ne 0 ]; then
        echo "##### Failed to push $new_tag. Skipping to the next image. #####"
        failed_pushes+=("$new_tag")
        continue
    fi
    
    # Sleep for 5 seconds between pushes
    echo "##### Sleeping for 5 seconds before pushing the next image... #####"
    sleep 5
done

# Summary
if [ ${#failed_pulls[@]} -eq 0 ] && [ ${#failed_tags[@]} -eq 0 ] && [ ${#failed_pushes[@]} -eq 0 ]; then
    echo "##### All images have been processed successfully. #####"
else
    echo "##### Some images had problems during processing. #####"
    if [ ${#failed_pulls[@]} -gt 0 ]; then
        echo "##### Failed pulls: #####"
        printf '%s\n' "${failed_pulls[@]}"
    fi
    if [ ${#failed_tags[@]} -gt 0 ]; then
        echo "##### Failed tags: #####"
        printf '%s\n' "${failed_tags[@]}"
    fi
    if [ ${#failed_pushes[@]} -gt 0 ]; then
        echo "##### Failed pushes: #####"
        printf '%s\n' "${failed_pushes[@]}"
    fi
fi
