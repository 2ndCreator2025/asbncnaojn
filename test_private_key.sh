#!/bin/bash

# 🔑 Private Key Format Tester
# This script helps you test your private key format before using it in GitHub Actions

echo "🔑 Private Key Format Tester"
echo "============================="

if [ $# -eq 0 ]; then
    echo "Usage: $0 '<your_private_key_with_\n_characters>'"
    echo "Example: $0 '-----BEGIN PRIVATE KEY-----\nMIGT...\n-----END PRIVATE KEY-----'"
    exit 1
fi

PRIVATE_KEY="$1"
echo "📏 Input length: ${#PRIVATE_KEY} characters"
echo ""

# Test Method 1: Direct processing with sed
echo "🧪 Method 1: Processing with sed (same as workflow)..."
mkdir -p test_keys
printf '%s\n' "$PRIVATE_KEY" | sed 's/\\n/\n/g' > test_keys/test_key_method1.p8
chmod 600 test_keys/test_key_method1.p8

echo "📄 Method 1 result:"
echo "   First line: $(head -1 test_keys/test_key_method1.p8)"
echo "   Last line:  $(tail -1 test_keys/test_key_method1.p8)"
echo "   Line count: $(wc -l < test_keys/test_key_method1.p8)"

if head -1 test_keys/test_key_method1.p8 | grep -q "BEGIN PRIVATE KEY"; then
    echo "   ✅ Valid private key header detected"
    METHOD1_VALID=true
else
    echo "   ❌ Invalid private key header"
    METHOD1_VALID=false
fi

echo ""

# Test Method 2: Base64 decode
echo "🧪 Method 2: Testing base64 decode..."
if echo "$PRIVATE_KEY" | base64 -d > test_keys/test_key_method2.p8 2>/dev/null; then
    chmod 600 test_keys/test_key_method2.p8
    echo "📄 Method 2 result:"
    echo "   First line: $(head -1 test_keys/test_key_method2.p8)"
    echo "   Last line:  $(tail -1 test_keys/test_key_method2.p8)"
    echo "   Line count: $(wc -l < test_keys/test_key_method2.p8)"
    
    if head -1 test_keys/test_key_method2.p8 | grep -q "BEGIN PRIVATE KEY"; then
        echo "   ✅ Valid private key header detected (base64 decoded)"
        METHOD2_VALID=true
    else
        echo "   ❌ Invalid private key header after base64 decode"
        METHOD2_VALID=false
    fi
else
    echo "   ❌ Not valid base64 data"
    METHOD2_VALID=false
fi

echo ""
echo "📊 Summary:"
echo "=========="

if [ "$METHOD1_VALID" = true ]; then
    echo "✅ Your private key format is CORRECT for GitHub Actions!"
    echo "   You can use it directly in the APPLE_API_PRIVATE_KEY secret."
    echo ""
    echo "📋 Full content for GitHub secret:"
    echo "$PRIVATE_KEY"
elif [ "$METHOD2_VALID" = true ]; then
    echo "✅ Your private key is base64 encoded and will work!"
    echo "   The workflow will automatically detect and decode it."
else
    echo "❌ Neither method worked. Your private key format needs fixing."
    echo ""
    echo "🔧 Try these fixes:"
    echo "   1. Ensure your key has proper BEGIN/END markers"
    echo "   2. Replace actual newlines with \\n"
    echo "   3. Or base64 encode your .p8 file: base64 -i AuthKey_XXX.p8"
    echo ""
    echo "📄 Method 1 output:"
    cat test_keys/test_key_method1.p8
fi

# Cleanup
rm -rf test_keys
echo ""
echo "🧹 Test files cleaned up."

