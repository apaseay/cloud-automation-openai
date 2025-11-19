#!/bin/bash

# SETUP WORKLOAD IDENTITY FEDERATION
# This script configures GCP to trust your GitHub repository.

# CONFIGURATION
PROJECT_ID=$(gcloud config get-value project)
# TODO: Update this with your actual GitHub username and repo name
GITHUB_REPO="apaseay/cloud-automation-openai" 

SERVICE_ACCOUNT_ID="github-actions-sa"
POOL_ID="github-pool"
PROVIDER_ID="github-provider"

echo "Setting up Workload Identity for Project: $PROJECT_ID"
echo "GitHub Repo: $GITHUB_REPO"

# 1. Enable APIs
echo "Enabling required APIs..."
gcloud services enable iam.googleapis.com sts.googleapis.com iamcredentials.googleapis.com

# 2. Create Service Account
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
    echo "Creating Service Account..."
    gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" \
        --display-name="GitHub Actions Service Account"
else
    echo "Service Account already exists."
fi

# 3. Grant Permissions (Editor role for sandbox)
echo "Granting Editor role..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# 4. Create Workload Identity Pool
if ! gcloud iam workload-identity-pools describe "$POOL_ID" --location="global" &>/dev/null; then
    echo "Creating Identity Pool..."
    gcloud iam workload-identity-pools create "$POOL_ID" \
        --location="global" \
        --display-name="GitHub Actions Pool"
else
    echo "Identity Pool already exists."
fi

POOL_ID_FULL=$(gcloud iam workload-identity-pools describe "$POOL_ID" --location="global" --format="value(name)")

# 5. Create Workload Identity Provider
if ! gcloud iam workload-identity-pools providers describe "$PROVIDER_ID" --location="global" --workload-identity-pool="$POOL_ID" &>/dev/null; then
    echo "Creating Identity Provider..."
    gcloud iam workload-identity-pools providers create "$PROVIDER_ID" \
        --location="global" \
        --workload-identity-pool="$POOL_ID" \
        --display-name="GitHub Actions Provider" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --issuer-uri="https://token.actions.githubusercontent.com"
else
    echo "Identity Provider already exists."
fi

# 6. Bind GitHub Repo to Service Account
echo "Allowing GitHub repo to impersonate Service Account..."
gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${POOL_ID_FULL}/attribute.repository/${GITHUB_REPO}"

# 7. Output Values for CI/CD
PROVIDER_FULL_NAME=$(gcloud iam workload-identity-pools providers describe "$PROVIDER_ID" --location="global" --workload-identity-pool="$POOL_ID" --format="value(name)")

echo ""
echo "===================================================="
echo "SETUP COMPLETE!"
echo "===================================================="
echo "Update your .github/workflows/ci.yml with these values:"
echo ""
echo "workload_identity_provider: '$PROVIDER_FULL_NAME'"
echo "service_account: '$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com'"
echo ""
