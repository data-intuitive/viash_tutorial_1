// read helper libraries & functions
const fs = require("fs");
const decompress = require(resources_dir + "/library.js").decompress;
const savetomap = require(resources_dir + "/library.js").savetomap;

// read data from file
const json = savetomap(fs.readFileSync(par["input"]));

// convert to tsv
const headers = Object.keys(json.tiles[0]);
const header = headers.join("\t") + "\n";
const lines = json.tiles.map(o => {
  return Object.values(o).map(b => JSON.stringify(b)).join("\t") + "\n";
});
const tsvLines = header + lines.join('')

// save to file
fs.writeFileSync(par["output"], tsvLines);
