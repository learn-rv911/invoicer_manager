#!/bin/bash

# Design System Lint Checker
# Prevents inline colors and text styles outside of core/ui/

echo "🔍 Checking for inline colors and styles..."

# Directories to check (exclude core/ui and generated files)
SEARCH_DIRS="lib/presentation lib/application lib/data"

# Patterns to check
VIOLATIONS=0

# Check for Color( usage outside of core/ui
echo ""
echo "📌 Checking for Color( usage..."
COLOR_VIOLATIONS=$(grep -r "Color(" $SEARCH_DIRS --include="*.dart" --exclude-dir=".dart_tool" || true)
if [ -n "$COLOR_VIOLATIONS" ]; then
  echo "❌ Found Color( usage in:"
  echo "$COLOR_VIOLATIONS"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅ No Color( violations found"
fi

# Check for inline TextStyle( usage
echo ""
echo "📌 Checking for TextStyle( usage..."
TEXTSTYLE_VIOLATIONS=$(grep -r "TextStyle(" $SEARCH_DIRS --include="*.dart" --exclude-dir=".dart_tool" | grep -v "\.copyWith" || true)
if [ -n "$TEXTSTYLE_VIOLATIONS" ]; then
  echo "❌ Found TextStyle( usage in:"
  echo "$TEXTSTYLE_VIOLATIONS"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅ No TextStyle( violations found"
fi

# Check for hex color strings (0xFF or 0x)
echo ""
echo "📌 Checking for hex color codes..."
HEX_VIOLATIONS=$(grep -r "0x[0-9A-Fa-f]\{8\}" $SEARCH_DIRS --include="*.dart" --exclude-dir=".dart_tool" || true)
if [ -n "$HEX_VIOLATIONS" ]; then
  echo "⚠️  Found hex color codes in:"
  echo "$HEX_VIOLATIONS"
  echo "   (Review these - they should use design system colors)"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅ No hex color codes found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $VIOLATIONS -eq 0 ]; then
  echo "✅ All checks passed! Design system is properly used."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "❌ Found $VIOLATIONS violation(s). Please use design system tokens."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "💡 Suggestions:"
  echo "   - Use context.colors.primary instead of Color(0xFF2563EB)"
  echo "   - Use AppTextTokens.bodyMedium instead of TextStyle(...)"
  echo "   - Use AppSpacing.space16 instead of magic numbers"
  echo "   - See MIGRATION.md for complete guide"
  echo ""
  exit 1
fi

