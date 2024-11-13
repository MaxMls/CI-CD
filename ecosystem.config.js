module.exports = {
    apps: [
        {
            cwd: __dirname,
            name: "ci-cd",
            script: "npm",
            args: "start",
            exp_backoff_restart_delay: 100,
        },
    ],
};
