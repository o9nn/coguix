#!/usr/bin/env bash
# Development Tools for Guix Contributors
# This script provides helpful utilities for Guix development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to check syntax of all Scheme files
check_syntax() {
    print_header "Checking Scheme Syntax"
    
    local errors=0
    
    while IFS= read -r file; do
        if ! guile --no-auto-compile -s "$file" 2>&1 | grep -qi "error"; then
            print_success "Syntax OK: $file"
        else
            print_error "Syntax error in: $file"
            ((errors++))
        fi
    done < <(find "$PROJECT_ROOT/gnu" "$PROJECT_ROOT/guix" -name "*.scm" 2>/dev/null)
    
    if [ $errors -eq 0 ]; then
        print_success "All Scheme files have valid syntax!"
        return 0
    else
        print_error "Found $errors files with syntax errors"
        return 1
    fi
}

# Function to validate package definitions
validate_packages() {
    print_header "Validating Package Definitions"
    
    local warnings=0
    
    while IFS= read -r file; do
        echo "Checking: $file"
        
        # Check for required fields
        if ! grep -q "synopsis" "$file"; then
            print_warning "Missing synopsis in $file"
            ((warnings++))
        fi
        
        if ! grep -q "description" "$file"; then
            print_warning "Missing description in $file"
            ((warnings++))
        fi
        
        if ! grep -q "license" "$file"; then
            print_warning "Missing license in $file"
            ((warnings++))
        fi
        
        if ! grep -q "home-page" "$file"; then
            print_warning "Missing home-page in $file"
            ((warnings++))
        fi
    done < <(find "$PROJECT_ROOT/gnu/packages" -name "*.scm" 2>/dev/null | head -20)
    
    if [ $warnings -eq 0 ]; then
        print_success "Package validation completed with no warnings!"
    else
        print_warning "Found $warnings potential issues"
    fi
}

# Function to run quick tests
run_quick_tests() {
    print_header "Running Quick Tests"
    
    cd "$PROJECT_ROOT"
    
    # Test that key modules can be loaded
    echo "Testing module loading..."
    
    if guile -c "(use-modules (guix packages))" 2>/dev/null; then
        print_success "guix packages module OK"
    else
        print_error "Failed to load guix packages module"
    fi
    
    if guile -c "(use-modules (gnu packages))" 2>/dev/null; then
        print_success "gnu packages module OK"
    else
        print_error "Failed to load gnu packages module"
    fi
}

# Function to count packages
count_packages() {
    print_header "Package Statistics"
    
    local total_files=$(find "$PROJECT_ROOT/gnu/packages" -name "*.scm" | wc -l)
    local total_packages=$(grep -r "define-public" "$PROJECT_ROOT/gnu/packages" 2>/dev/null | wc -l)
    
    echo "Total package files: $total_files"
    echo "Total public packages: $total_packages"
    echo ""
    echo "Top 10 largest package files:"
    find "$PROJECT_ROOT/gnu/packages" -name "*.scm" -exec wc -l {} \; | sort -rn | head -10
}

# Function to check for common issues
check_common_issues() {
    print_header "Checking for Common Issues"
    
    echo "Checking for hardcoded paths..."
    local hardcoded=$(grep -r "/usr/\|/opt/" "$PROJECT_ROOT/gnu/packages" 2>/dev/null | wc -l)
    if [ $hardcoded -gt 0 ]; then
        print_warning "Found $hardcoded potential hardcoded paths"
    else
        print_success "No hardcoded paths found"
    fi
    
    echo ""
    echo "Checking for TODO/FIXME/XXX comments..."
    local todos=$(grep -r "TODO\|FIXME\|XXX" "$PROJECT_ROOT/guix" "$PROJECT_ROOT/gnu" 2>/dev/null | wc -l)
    echo "Found $todos TODO/FIXME/XXX comments"
    
    echo ""
    echo "Checking for trailing whitespace..."
    local whitespace=$(git diff --check HEAD^ HEAD 2>&1 | wc -l)
    if [ $whitespace -gt 0 ]; then
        print_warning "Found trailing whitespace issues"
    else
        print_success "No trailing whitespace issues"
    fi
}

# Function to generate development report
generate_report() {
    print_header "Generating Development Report"
    
    local report_file="$PROJECT_ROOT/dev-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "Guix Development Report"
        echo "Generated: $(date)"
        echo ""
        echo "=== Repository Status ==="
        git status --short
        echo ""
        echo "=== Recent Commits ==="
        git log --oneline -10
        echo ""
        echo "=== Package Statistics ==="
        count_packages
        echo ""
        echo "=== Common Issues ==="
        check_common_issues
    } > "$report_file"
    
    print_success "Report generated: $report_file"
}

# Function to setup development environment
setup_dev_env() {
    print_header "Setting Up Development Environment"
    
    echo "Installing required dependencies..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y guile-3.0 guile-3.0-dev autoconf automake \
            texinfo graphviz help2man gettext pkg-config
        print_success "Dependencies installed"
    else
        print_warning "apt-get not found, please install dependencies manually"
    fi
    
    echo ""
    echo "Running bootstrap..."
    cd "$PROJECT_ROOT"
    ./bootstrap
    
    print_success "Development environment setup completed!"
}

# Main menu
show_menu() {
    echo ""
    print_header "Guix Development Tools"
    echo ""
    echo "1) Check Scheme syntax"
    echo "2) Validate package definitions"
    echo "3) Run quick tests"
    echo "4) Count packages"
    echo "5) Check for common issues"
    echo "6) Generate development report"
    echo "7) Setup development environment"
    echo "8) Run all checks"
    echo "9) Exit"
    echo ""
}

# Run all checks
run_all_checks() {
    check_syntax
    echo ""
    validate_packages
    echo ""
    run_quick_tests
    echo ""
    check_common_issues
    echo ""
    print_success "All checks completed!"
}

# Main script logic
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Select an option: " choice
        
        case $choice in
            1) check_syntax ;;
            2) validate_packages ;;
            3) run_quick_tests ;;
            4) count_packages ;;
            5) check_common_issues ;;
            6) generate_report ;;
            7) setup_dev_env ;;
            8) run_all_checks ;;
            9) echo "Goodbye!"; exit 0 ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
else
    # Command-line mode
    case "$1" in
        syntax) check_syntax ;;
        validate) validate_packages ;;
        test) run_quick_tests ;;
        count) count_packages ;;
        issues) check_common_issues ;;
        report) generate_report ;;
        setup) setup_dev_env ;;
        all) run_all_checks ;;
        *)
            echo "Usage: $0 [syntax|validate|test|count|issues|report|setup|all]"
            echo "Run without arguments for interactive mode"
            exit 1
            ;;
    esac
fi
