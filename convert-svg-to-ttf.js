// Require necessary modules
import {
  createReadStream,
  createWriteStream,
  readFileSync,
  readdir,
  readdirSync,
  writeFileSync,
  lstatSync,
} from "fs";
import { basename, extname, join } from "path";
import svg2ttf from "svg2ttf";
import svgicons2svgfont from "svgicons2svgfont";

// Set the input and output directories
const inputDir = "input-icons";
const outputDir = "output";

// Read the subfolders of the input directory
readdir(inputDir, (err, folders) => {
  if (err) {
    console.error(err);
    return;
  }

  // For each subfolder
  folders.forEach((folder) => {
    const fontName = folder;
    const svgDir = join(inputDir, folder);

    // Skip any non directory files
    if (!lstatSync(svgDir).isSymbolicLink()) {
      return;
    }
    const outputFilename = join(outputDir, `${fontName}.ttf`);

    // Get an array of SVG files in the subfolder
    const svgFiles = readdirSync(svgDir).filter(
      (file) => extname(file).toLowerCase() === ".svg"
    );

    // Read the json file of the same name as the folder present in input-icons directory
    const jsonFile = join(inputDir, `${folder}.json`);
    const json = JSON.parse(readFileSync(jsonFile, "utf8"));

    // Map the SVG files to an array of glyphs
    const glyphs = svgFiles.map((file) => {
      const svgPath = join(svgDir, file);
      const glyphName = basename(svgPath, ".svg");
      const svg = readFileSync(svgPath, "utf8");
      return {
        name: glyphName,
        path: svgPath,
        contents: svg,
        codepoint: json[glyphName],
      };
    });

    // Create a new SVG font stream
    const fontStream = new svgicons2svgfont({
      fontName: fontName,
      fontHeight: 1000,
      normalize: true,
    });

    // Pipe the font stream to a file stream
    fontStream.pipe(createWriteStream(outputFilename)).on("finish", () => {
      // Read the font file as an SVG string
      const svg = readFileSync(outputFilename, "utf8");
      // Convert the SVG string to a TTF buffer
      const ttf = svg2ttf(svg, {});
      // Write the TTF buffer to a file with the same name as the SVG file
      writeFileSync(
        outputFilename.replace(/\.svg$/, ".ttf"),
        Buffer.from(ttf.buffer)
      );
    });

    // For each glyph, create a stream and add it to the font stream
    glyphs.forEach((glyph) => {
      const stream = createReadStream(glyph.path);
      stream.metadata = {
        name: glyph.name,
        unicode: [String.fromCodePoint(glyph.codepoint)],
      };
      fontStream.write(stream);
    });

    // End the font stream
    fontStream.end();
  });
});
