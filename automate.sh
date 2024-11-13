#!/bin/bash

# Step 1: Create the .temp-ci/ folder
mkdir -p .temp-ci

# Step 2: Move .git to .temp-ci/
mv .git .temp-ci/

# Step 3: Change to .temp-ci/
cd .temp-ci/

# Step 4: Discard all changes and get the latest version of the repo
git reset --hard
git clean -df
git pull

# Step 5: Install dependencies and build
npm install
npm run build

# Step 6: Go back to the parent directory
cd ..

# Step 7: Delete pm2 process
pm2 delete ecosystem.config.js

# Step 8: Remove files from the parent folder except .env and .temp-ci/
find . -maxdepth 1 ! -name '.env' ! -name '.temp-ci' -exec rm -rf {} +

# Step 9: Start the pm2 process again
pm2 start ecosystem.config.js

# Step 10: Move the .git folder back to the parent directory (Optional)
mv .temp-ci/.git .
