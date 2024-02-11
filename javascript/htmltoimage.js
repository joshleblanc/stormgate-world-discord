const nodeHtmlToImage = require('node-html-to-image');


const args = process.argv.slice(2)

async function toImage(html) {
    const image = await nodeHtmlToImage({
        html: html,
        transparent: true
    });

    process.stdout.write(image);
}

toImage(args.join(' '))