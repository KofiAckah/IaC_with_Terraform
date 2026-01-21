#!/bin/bash

# --- Terraform Backend Configuration ---

# Project Configuration
PROJECT_NAME="iac-terraform"
ENVIRONMENT="dev"

# AWS Configuration
AWS_REGION="eu-west-1"

# Backend Resources
BUCKET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-tfstate"
DYNAMODB_TABLE="${PROJECT_NAME}-${ENVIRONMENT}-tfstate-lock"

# --- Output & Logging ---
LOG_FILE="terraform-backend.log"
STATE_FILE=".tfstate.env"

# --- Tags ---
PROJECT_TAG="IaC-Terraform"

# Export variables
export PROJECT_NAME ENVIRONMENT AWS_REGION
export BUCKET_NAME DYNAMODB_TABLE
export LOG_FILE STATE_FILE PROJECT_TAG
