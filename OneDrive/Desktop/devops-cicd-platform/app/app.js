const express = require("express");

const app = express();

const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || "1.0.0";
const COLOR = process.env.APP_COLOR || "blue";

app.get("/", (req, res) => {
    res.json({
        application: "DevOps Deployment Platform",
        version: VERSION,
        environment: process.env.NODE_ENV || "development",
        deployment: COLOR,
        message: "Application is running successfully"
    });
});

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "UP",
        version: VERSION,
        deployment: COLOR
    });
});

app.listen(PORT, () => {
    console.log(
        `Application ${VERSION} running on port ${PORT} (${COLOR})`
    );
});