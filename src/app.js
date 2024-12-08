const express = require("express");
const bodyParser = require("body-parser");
const { executeProcedure } = require("./database.js");
const { transformData } = require("./utils.js");

const app = express();
const port = 3000;

app.use(bodyParser.json());

app.get("/todos", async (req, res) => {
    const result = await executeProcedure("READ");
    res.json(transformData(result));
});

app.post("/todos", async (req, res) => {
    const { id, name, description } = req.body;
    const result = await executeProcedure("ADD", id, name, description);
    res.status(201).json(transformData(result));
});

app.put("/todos/:id", async (req, res) => {
    const id = req.params.id;
    const { name, description } = req.body;
    const result = await executeProcedure("EDIT", id, name, description);
    res.json(transformData(result));
});

app.delete("/todos/:id", async (req, res) => {
    const id = req.params.id;

    const result = await executeProcedure("DELETE", id);
    res.json(transformData(result));
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
