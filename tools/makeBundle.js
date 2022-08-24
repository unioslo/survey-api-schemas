const $RefParser = require("@apidevtools/json-schema-ref-parser");
const fs = require('fs').promises;

const args = process.argv.slice(2);
// to args needed: input output
const fnin = args[0]
const fnout = args[1]

let parser = new $RefParser();
(async function() {
    try {
        let schema = await parser.dereference(fnin);
        await fs.writeFile(fnout, JSON.stringify(schema, null, "  "));
    } catch (e) {
        console.error(e)
    }
})();
