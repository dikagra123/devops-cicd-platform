const http = require("http");
const { spawn } = require("child_process");

const server = spawn("node", ["app.js"], {
    env: {
        ...process.env,
        PORT: "3999",
        APP_VERSION: "test",
        APP_COLOR: "test"
    },
    stdio: "inherit"
});

server.on("error", (err) => {
    console.error("Failed to start app.js:", err);
    process.exit(1);
});

server.on("exit", (code) => {
    if (code !== null && code !== 0) {
        console.error(`app.js exited early with code ${code}`);
    }
});

function checkHealth(retriesLeft) {
    http.get("http://localhost:3999/health", (res) => {
        if (res.statusCode === 200) {
            console.log("Health check test passed!");
            server.kill();
            process.exit(0);
        } else {
            console.error("Health check test failed! Status:", res.statusCode);
            server.kill();
            process.exit(1);
        }
    }).on("error", (err) => {
        if (retriesLeft > 0) {
            setTimeout(() => checkHealth(retriesLeft - 1), 500);
        } else {
            console.error("Server never became reachable:", err.message);
            server.kill();
            process.exit(1);
        }
    });
}

setTimeout(() => checkHealth(20), 500);
