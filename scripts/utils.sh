#!/bin/bash

# Color codes for terminal output
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_FATAL=4

# Default log level (can be overridden by environment variable)
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Get log file from config or use default
LOG_FILE=${LOG_FILE:-"terraform-backend.log"}

# Initialize log file with header
init_logging() {
    # Create log file if it doesn't exist
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi
    
    # Write session header
    {
        echo ""
        echo "=========================================="
        echo "Log Session Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Script: ${BASH_SOURCE[1]}"
        echo "User: $(whoami)"
        echo "Region: ${AWS_REGION:-Not Set}"
        echo "=========================================="
        echo ""
    } >> "$LOG_FILE"
}

# Core logging function
_log() {
    local level=$1
    local level_name=$2
    local color=$3
    local message=$4
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]##*/}:${BASH_LINENO[1]}"
    
    # Check if we should log this level
    if [ "$level" -lt "$LOG_LEVEL" ]; then
        return 0
    fi
    
    # Format log message
    local log_message="[$timestamp] [$level_name] [$caller] $message"
    local terminal_message="${color}[$timestamp] [$level_name]${NC} $message"
    
    # Write to log file (no color codes)
    echo "$log_message" >> "$LOG_FILE"
    
    # Output to terminal with colors
    echo -e "$terminal_message"
}

# Log level functions
log_debug() {
    _log $LOG_LEVEL_DEBUG "DEBUG" "$CYAN" "$1"
}

log_info() {
    _log $LOG_LEVEL_INFO "INFO" "$GREEN" "$1"
}

log_warn() {
    _log $LOG_LEVEL_WARN "WARN" "$YELLOW" "$1"
}

log_error() {
    _log $LOG_LEVEL_ERROR "ERROR" "$RED" "$1"
}

log_fatal() {
    _log $LOG_LEVEL_FATAL "FATAL" "$RED" "$1"
    exit 1
}

# Function to log command execution
log_command() {
    local cmd="$1"
    log_debug "Executing: $cmd"
}

# Function to save state
save_state() {
    local key=$1
    local value=$2
    local state_file="${STATE_FILE:-.tfstate.env}"
    
    # Create state file if it doesn't exist
    if [ ! -f "$state_file" ]; then
        touch "$state_file"
        log_debug "Created state file: $state_file"
    fi
    
    # Remove old value if exists
    if grep -q "^${key}=" "$state_file" 2>/dev/null; then
        sed -i "/^${key}=/d" "$state_file"
    fi
    
    # Add new value
    echo "${key}=${value}" >> "$state_file"
    log_info "State saved: $key=$value"
}

# Function to load state
load_state() {
    local key=$1
    local state_file="${STATE_FILE:-.tfstate.env}"
    
    if [ ! -f "$state_file" ]; then
        log_warn "State file not found: $state_file"
        return 1
    fi
    
    # Get value and strip ANSI color codes
    local value=$(grep "^${key}=" "$state_file" 2>/dev/null | cut -d'=' -f2- | sed 's/\x1b\[[0-9;]*m//g')
    
    if [ -z "$value" ]; then
        log_warn "Key not found in state file: $key"
        return 1
    fi
    
    echo "$value"
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_fatal "AWS CLI is not installed. Please install it first."
    fi
    log_info "AWS CLI found: $(aws --version)"
}

# Function to check AWS credentials
check_aws_credentials() {
    log_info "Checking AWS credentials..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_fatal "AWS credentials not configured. Run 'aws configure' first."
    fi
    
    local identity=$(aws sts get-caller-identity --output json 2>/dev/null)
    local account=$(echo "$identity" | grep -o '"Account": "[^"]*' | cut -d'"' -f4)
    local arn=$(echo "$identity" | grep -o '"Arn": "[^"]*' | cut -d'"' -f4)
    
    log_info "AWS Account: $account"
    log_debug "IAM Identity: $arn"
}

# Function to validate region
validate_region() {
    local region=$1
    log_info "Validating region: $region"
    
    if ! aws ec2 describe-regions --region-names "$region" &> /dev/null; then
        log_fatal "Invalid AWS region: $region"
    fi
    
    log_info "Region validated: $region"
}

# Function to log summary
log_summary() {
    local title=$1
    shift
    local items=("$@")
    
    echo "" | tee -a "$LOG_FILE"
    log_info "=========================================="
    log_info "$title"
    log_info "=========================================="
    
    for item in "${items[@]}"; do
        log_info "$item"
    done
    
    log_info "=========================================="
    echo "" | tee -a "$LOG_FILE"
}

# Function to start a section
log_section() {
    local section_name=$1
    echo "" | tee -a "$LOG_FILE"
    log_info ">>> Starting: $section_name"
}

# Function to end a section
log_section_end() {
    local section_name=$1
    local status=$2
    
    if [ "$status" = "success" ]; then
        log_info "<<< Completed: $section_name [SUCCESS]"
    else
        log_error "<<< Completed: $section_name [FAILED]"
    fi
    echo "" | tee -a "$LOG_FILE"
}

# Export functions
export -f init_logging
export -f _log
export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f log_fatal
export -f log_command
export -f save_state
export -f load_state
export -f check_aws_cli
export -f check_aws_credentials
export -f validate_region
export -f log_summary
export -f log_section
export -f log_section_end

# Initialize logging when sourced
init_logging
