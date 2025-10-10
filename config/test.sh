#!/usr/bin/env bash
# Test suite for ricing configuration system

# Don't exit on error - we want to count failures
# set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

# Test helper
test_command() {
    local description=$1
    local command=$2
    local expected_exit=$3
    
    echo -n "Testing: $description... "
    
    if eval "$command" > /dev/null 2>&1; then
        actual_exit=0
    else
        actual_exit=$?
    fi
    
    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Expected exit code: $expected_exit, got: $actual_exit"
        ((FAILED++))
        return 1
    fi
}

test_output() {
    local description=$1
    local command=$2
    local expected_output=$3
    
    echo -n "Testing: $description... "
    
    actual_output=$(eval "$command" 2>&1)
    
    if echo "$actual_output" | grep -q "$expected_output"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Expected output to contain: $expected_output"
        echo "  Got: $actual_output"
        ((FAILED++))
        return 1
    fi
}

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         Ricing Configuration System Test Suite          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo

# Test 1: Python availability
test_command "Python 3 is available" "python3 --version" 0

# Test 2: PyYAML module
test_command "PyYAML module available" "python3 -c 'import yaml'" 0

# Test 3: Settings file exists
test_command "Default settings.yaml exists" "test -f config/settings.yaml" 0

# Test 4: Scripts are executable
test_command "settings-manager is executable" "test -x config/settings-manager" 0
test_command "open-settings is executable" "test -x config/open-settings" 0
test_command "apply-settings is executable" "test -x config/apply-settings" 0
test_command "install.sh is executable" "test -x config/install.sh" 0

# Test 5: Settings manager help
test_output "settings-manager --help works" "python3 config/settings-manager --help" "Ricing Settings Manager"

# Test 6: Get default setting
test_output "Get appearance.border_radius" "python3 config/settings-manager --get appearance.border_radius" "^[0-9]"

# Test 7: Set and verify setting
echo -n "Testing: Set and verify setting... "
python3 config/settings-manager --set appearance.border_radius 25 > /dev/null
RESULT=$(python3 config/settings-manager --get appearance.border_radius)
if [ "$RESULT" -eq "25" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "  Expected: 25, got: $RESULT"
    ((FAILED++))
fi

# Test 8: Boolean setting
echo -n "Testing: Boolean setting toggle... "
python3 config/settings-manager --set appearance.blur_enabled true > /dev/null
RESULT=$(python3 config/settings-manager --get appearance.blur_enabled)
if [ "$RESULT" = "True" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "  Expected: True, got: $RESULT"
    ((FAILED++))
fi

# Test 9: String setting
echo -n "Testing: String setting... "
python3 config/settings-manager --set waybar.position bottom > /dev/null
RESULT=$(python3 config/settings-manager --get waybar.position)
if [ "$RESULT" = "bottom" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "  Expected: bottom, got: $RESULT"
    ((FAILED++))
fi

# Test 10: Apply settings
test_output "apply-settings runs" "python3 config/apply-settings" "APPLYING RICING SETTINGS"

# Test 11: Config file syntax
echo -n "Testing: YAML syntax validation... "
if python3 -c "import yaml; yaml.safe_load(open('config/settings.yaml'))" 2>/dev/null; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    ((FAILED++))
fi

# Test 12: User config creation
echo -n "Testing: User config creation... "
if [ -f "$HOME/.config/ricing/settings.yaml" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠ SKIPPED${NC} (no user config)"
fi

# Test 13: Installed scripts (if installed)
if [ -f "$HOME/.local/bin/settings-manager" ]; then
    test_command "Installed settings-manager works" "settings-manager --help" 0
    test_command "Installed open-settings exists" "test -f $HOME/.local/bin/open-settings" 0
    test_command "Installed apply-settings exists" "test -f $HOME/.local/bin/apply-settings" 0
else
    echo -e "${YELLOW}⚠ Installation tests skipped (scripts not installed)${NC}"
fi

# Test 14: Documentation exists
test_command "config/README.md exists" "test -f config/README.md" 0
test_command "config/USAGE.md exists" "test -f config/USAGE.md" 0

# Test 15: README mentions configuration
test_output "Main README mentions config" "grep -i 'configuration' README.md" "configuration"

# Summary
echo
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                       Test Summary                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
