#!/bin/bash

echo "========================================="
echo "CloudFormation Templates Validation"
echo "========================================="
echo ""

# Check if cfn-lint is installed
if ! command -v cfn-lint &> /dev/null; then
    echo "cfn-lint is not installed. Installing..."
    pip install cfn-lint
fi

echo "Validating templates with cfn-lint..."
echo ""

# Validate main stack
echo "1. Validating main-stack.yaml..."
if cfn-lint main-stack.yaml; then
    echo "✓ main-stack.yaml is valid"
else
    echo "✗ main-stack.yaml has errors"
fi
echo ""

# Validate nested stacks
for template in nested-stacks/*.yaml; do
    filename=$(basename "$template")
    echo "2. Validating $filename..."
    if cfn-lint "$template"; then
        echo "✓ $filename is valid"
    else
        echo "✗ $filename has errors"
    fi
    echo ""
done

echo "========================================="
echo "Validation completed!"
echo "========================================="
