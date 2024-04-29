const nodeHtmlToImage = require('node-html-to-image');
const fs = require('node:fs')

const args = process.argv.slice(2)

async function toImage(filePath) {
    const html = fs.readFileSync(filePath, 'utf8');
    const image = await nodeHtmlToImage({
        html: html,
        transparent: true
    });

    process.stdout.write(image);
}

toImage(args.join(' '))