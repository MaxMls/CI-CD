import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

if(!process.env.REPO_URL) {
    console.error('Error: REPO_URL is not defined in the environment variables.');
    process.exit(1);
}

const REPO_URL = process.env.REPO_URL;
const LOCAL_REPO_PATH = "./";  // Local path to your repo
const POLL_INTERVAL = 30000; // Poll every 30 seconds

let lastCommitSha = "";

// Function to check for new commits
async function checkForNewCommits() {
    const response = await fetch(REPO_URL);
    const data = await response.json();

    const latestCommitSha = data[0]?.sha;

    if (latestCommitSha && latestCommitSha !== lastCommitSha) {
        console.log("New commit detected. Pulling changes...");
        lastCommitSha = latestCommitSha;
        await updateRepo();
    } else {
        console.log("No new changes detected.");
    }
}

// Function to pull changes, rebuild, and restart the program
async function updateRepo() {
    try {
        // Pull latest changes
        await execAsync(`git -C ${LOCAL_REPO_PATH} pull`);
        console.log("Repository updated.");

        // Rebuild the project
        await execAsync(`npm run build`, { cwd: LOCAL_REPO_PATH });
        console.log("Project rebuilt.");

        // Restart the program (assuming it's a Node.js app using pm2)
        await execAsync(`pm2 restart your-app-name`);
        console.log("Program restarted.");
    } catch (error) {
        console.error("Error updating repo:", error);
    }
}

// Polling function
function startPolling() {
    setInterval(checkForNewCommits, POLL_INTERVAL);
}

startPolling();

// watch github repo for new commits, when there is a new commit:=
// 1. create .temp-ci/ folder
// 2. mv .git to .temp-ci/
// 3. cd .temp-ci/
// 4. discard all changes and get last version of the repo:
// git reset --hard
// git clean -df
// git pull
// npm i
// npm run build

// 5. cd ..
// 6. pm2 delete ecosystem.config.js
// 7. remove files from parent folder except .env and .temp-ci/: 
// find . -maxdepth 1 ! -name '.env' ! -name '.temp-ci' -exec rm -rf {} +
// 8. pm2 start ecosystem.config.js
// 6. move 