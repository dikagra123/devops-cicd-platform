const http = require("http");
const { spawn } = require("child_process");

const server = spawn("node", ["app.js"], {
    env: {
        ...process.env,
        PORT: "3999",
        APP_VERSION: "test",
        APP_COLOR: "test"
    }
});

setTimeout(() => {

    http.get("http://localhost:3999/health", (res) => {

        if (res.statusCode === 200) {
            console.log("Health check test passed!");
            server.kill();
            process.exit(0);
        } else {
            console.error("Health check test failed!");
            server.kill();
            process.exit(1);
        }

    }).on("error", (err) => {

        console.error(err);
        server.kill();
        process.exit(1);

    });

}, 2000);