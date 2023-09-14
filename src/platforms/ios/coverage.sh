#!/bin/bash

# Get test code coverage from given target based on xcresult file

# Expected target name in the form of: TrustPaymentsCoreTests, Tests and extension will be added when needed
TARGET=$(echo $1 | sed 's/Tests//g')

# Expected minimum acceptable percentage for the coverage given as while ints eg: 55
MIN_COVERAGE=$2
TARGET_FRAMEWORK=$TARGET.framework

# Gather code coverage data
# Transform coverage data into json format, select only data for given target and then extract lineCoverage property's value
COVERAGE=$(xcrun xccov view --report --only-targets --json  fastlane/test_output/report.xcresult | jq --arg TARGET_FRAMEWORK "$TARGET_FRAMEWORK" '[.[] | select(.name==$TARGET_FRAMEWORK)'] | jq '.[0] | .lineCoverage')

# Convert given coverage into percentage representation
COVERAGE_PERCENTAGE=$(printf %.0f $(echo "$COVERAGE*100" | bc))

echo "Current code coverage: "$COVERAGE_PERCENTAGE"%, expected at least: "$MIN_COVERAGE"%"

if [ $COVERAGE_PERCENTAGE -ge $MIN_COVERAGE ]
then
    exit 0
else
    exit 1
fi

