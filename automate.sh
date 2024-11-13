#!/bin/bash

# Step 1: Create the .temp-ci/ folder
mkdir -p .temp-ci || { echo "Failed to create .temp-ci folder"; exit 1; }
echo "Step 1: .temp-ci folder created."

# Step 2: Move .git to .temp-ci/
mv .git .temp-ci/ || { echo "Failed to move .git"; exit 1; }
echo "Step 2: .git moved to .temp-ci/."

# Step 3: Change to .temp-ci/
cd .temp-ci/ || { echo "Failed to change directory to .temp-ci"; exit 1; }
echo "Step 3: Changed directory to .temp-ci/."

# Step 4: Discard all changes and get the latest version of the repo
git reset --hard || { echo "Failed to reset git"; exit 1; }
echo "Step 4a: Git reset performed."
git clean -df || { echo "Failed to clean git"; exit 1; }
echo "Step 4b: Git clean performed."
git pull || { echo "Failed to pull latest changes from git"; exit 1; }
echo "Step 4c: Latest changes pulled from git."

# Step 5: Install dependencies and build
npm i || { echo "Failed to install dependencies"; exit 1; }
echo "Step 5a: Dependencies installed."
npm run build || { echo "Failed to build project"; exit 1; }
echo "Step 5b: Project built."

# Step 6: Go back to the parent directory
cd .. || { echo "Failed to change directory to parent"; exit 1; }
echo "Step 6: Changed directory to parent."

# Step 7: Delete pm2 process
pm2 delete ecosystem.config.js || { echo "Failed to delete pm2 process"; exit 1; }
echo "Step 7: pm2 process deleted."

# Step 8: Remove files from the parent folder except .env and .temp-ci/
find . -maxdepth 1 ! -name '.env' ! -name '.temp-ci' ! -name '.' ! -name '..' -exec rm -rf {} + || { echo "Failed to remove unwanted files"; exit 1; }
echo "Step 8a: Unwanted files removed."

shopt -s dotglob
mv .temp-ci/* . || { echo "Failed to move .temp-ci contents"; exit 1; }
echo "Step 8b: .temp-ci contents moved."
rm -d .temp-ci || { echo "Failed to remove .temp-ci directory"; exit 1; }
echo "Step 8c: .temp-ci directory removed."

# Step 9: Start the pm2 process again
pm2 start ecosystem.config.js || { echo "Failed to start pm2 process"; exit 1; }
echo "Step 9: pm2 process started."
