#!/bin/bash

# Source the configuration and utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/utils.sh"

# Function to check if S3 bucket already exists
check_existing_bucket() {
    local existing_bucket=$(load_state "S3_BUCKET_NAME" 2>/dev/null)
    
    if [ -n "$existing_bucket" ]; then
        log_info "Found existing S3 bucket in state file: $existing_bucket"
        
        # Verify the bucket actually exists in AWS
        if aws s3api head-bucket --bucket "$existing_bucket" --region "$AWS_REGION" 2>/dev/null; then
            log_info "S3 bucket exists in AWS. Skipping creation."
            BUCKET_NAME="$existing_bucket"
            return 0
        else
            log_warn "S3 bucket in state file does not exist in AWS. Will create new bucket."
            return 1
        fi
    fi
    
    return 1
}

# Function to create S3 bucket
create_s3_bucket() {
    log_section "S3 Bucket Creation"
    
    # Check if bucket already exists
    if check_existing_bucket; then
        log_section_end "S3 Bucket Creation" "success"
        return 0
    fi
    
    log_info "Creating S3 bucket: $BUCKET_NAME"
    
    # Create bucket
    log_command "aws s3api create-bucket"
    
    if [ "$AWS_REGION" = "us-east-1" ]; then
        # us-east-1 doesn't need LocationConstraint
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    else
        # Other regions need LocationConstraint
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    if [ $? -ne 0 ]; then
        log_error "Failed to create S3 bucket"
        log_section_end "S3 Bucket Creation" "failed"
        return 1
    fi
    
    log_info "S3 bucket created successfully"
    save_state "S3_BUCKET_NAME" "$BUCKET_NAME"
    
    # Enable versioning
    log_info "Enabling versioning on bucket"
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled \
        --region "$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to enable versioning"
        log_section_end "S3 Bucket Creation" "failed"
        return 1
    fi
    
    log_info "Versioning enabled successfully"
    
    # Enable encryption
    log_info "Enabling server-side encryption"
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }' \
        --region "$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to enable encryption"
        log_section_end "S3 Bucket Creation" "failed"
        return 1
    fi
    
    log_info "Encryption enabled successfully"
    
    # Block public access
    log_info "Configuring public access block"
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
        --region "$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to configure public access block"
        log_section_end "S3 Bucket Creation" "failed"
        return 1
    fi
    
    log_info "Public access blocked successfully"
    
    log_section_end "S3 Bucket Creation" "success"
    return 0
}

# Function to check if DynamoDB table already exists
check_existing_dynamodb() {
    local existing_table=$(load_state "DYNAMODB_TABLE_NAME" 2>/dev/null)
    
    if [ -n "$existing_table" ]; then
        log_info "Found existing DynamoDB table in state file: $existing_table"
        
        # Verify the table actually exists in AWS
        if aws dynamodb describe-table --table-name "$existing_table" --region "$AWS_REGION" &> /dev/null; then
            log_info "DynamoDB table exists in AWS. Skipping creation."
            DYNAMODB_TABLE="$existing_table"
            return 0
        else
            log_warn "DynamoDB table in state file does not exist in AWS. Will create new table."
            return 1
        fi
    fi
    
    return 1
}

# Function to create DynamoDB table
create_dynamodb_table() {
    log_section "DynamoDB Table Creation"
    
    # Check if table already exists
    if check_existing_dynamodb; then
        log_section_end "DynamoDB Table Creation" "success"
        return 0
    fi
    
    log_info "Creating DynamoDB table: $DYNAMODB_TABLE"
    
    # Create table
    log_command "aws dynamodb create-table"
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION" \
        --tags Key=Environment,Value="$ENVIRONMENT" Key=ManagedBy,Value=Terraform Key=Project,Value="$PROJECT_NAME" \
        2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to create DynamoDB table"
        log_section_end "DynamoDB Table Creation" "failed"
        return 1
    fi
    
    log_info "DynamoDB table created successfully"
    save_state "DYNAMODB_TABLE_NAME" "$DYNAMODB_TABLE"
    
    # Wait for table to be active
    log_info "Waiting for DynamoDB table to become active..."
    aws dynamodb wait table-exists \
        --table-name "$DYNAMODB_TABLE" \
        --region "$AWS_REGION" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        log_error "Failed waiting for DynamoDB table"
        log_section_end "DynamoDB Table Creation" "failed"
        return 1
    fi
    
    log_info "DynamoDB table is now active"
    
    log_section_end "DynamoDB Table Creation" "success"
    return 0
}

# Main execution
main() {
    log_info "=========================================="
    log_info "Terraform Backend Setup Script"
    log_info "=========================================="
    log_info "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Region: $AWS_REGION"
    log_info "Project: $PROJECT_NAME"
    log_info "Environment: $ENVIRONMENT"
    log_info ""
    
    # Pre-flight checks
    log_section "Pre-flight Checks"
    check_aws_cli
    check_aws_credentials
    validate_region "$AWS_REGION"
    log_section_end "Pre-flight Checks" "success"
    
    # Create S3 bucket
    create_s3_bucket || exit 1
    
    # Create DynamoDB table
    create_dynamodb_table || exit 1
    
    # Display summary
    log_summary "Backend Setup Summary" \
        "S3 Bucket: $BUCKET_NAME" \
        "DynamoDB Table: $DYNAMODB_TABLE" \
        "Region: $AWS_REGION" \
        "" \
        "Add the following to your backend.tf:" \
        "" \
        "terraform {" \
        "  backend \"s3\" {" \
        "    bucket         = \"$BUCKET_NAME\"" \
        "    key            = \"terraform.tfstate\"" \
        "    region         = \"$AWS_REGION\"" \
        "    dynamodb_table = \"$DYNAMODB_TABLE\"" \
        "    encrypt        = true" \
        "  }" \
        "}" \
        "" \
        "State file: $STATE_FILE" \
        "Log file: $LOG_FILE"
    
    log_info "=========================================="
    log_info "Backend setup completed successfully!"
    log_info "=========================================="
}

# Run main function
main
