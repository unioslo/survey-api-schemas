const $RefParser = require("@apidevtools/json-schema-ref-parser");
const fs = require('fs').promises;

const args = process.argv.slice(2);
// two args needed: input output
const fnin = args[0];
const fnout = args[1];

(async function() {
    try {
        let schema = await $RefParser.dereference(fnin);
        await fs.writeFile(fnout, JSON.stringify(schema, null, "  "));
    } catch (e) {
        console.error(e)
    }
})();
