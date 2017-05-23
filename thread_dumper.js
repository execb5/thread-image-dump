const fetch = require('node-fetch')
const cheerio = require('cheerio')
const fs = require('fs')
const term = require('terminal-kit').terminal

const DUMP_FOLDER = "dump"
if (!fs.existsSync(DUMP_FOLDER)) fs.mkdirSync(DUMP_FOLDER)

const thread_url = process.argv[2]

let progress = 0
let progressBar = term.progressBar({
	title: 'dumping:',
	eta: true,
	percent: true
})

fetch(thread_url)
    .then(response => response.text())
    .then(body => {
        let $ = cheerio.load(body)
        
        let subject = $('.subject')[1].children[0].data.replace(/[^\w\s]/gi, '')
        let dir = DUMP_FOLDER + '/' + subject 
        if (!fs.existsSync(dir)) fs.mkdirSync(dir)
        
        let images = $('.fileText a').toArray()
        images.forEach(img => {
            let href = 'http:' + img.attribs['href']
            let file_name = href.split('/').reverse()[0]
            let local_name = file_name.split('.')[0]
                + img.next.data + '.'
                + file_name.split('.')[1]
            fetch(href)
                .then(res => {
                    let dest = fs.createWriteStream(
                        './' + dir + '/' + local_name)
                    res.body.pipe(dest).on('finish', () => {
                        progress += (1 / images.length) + 0.01
                        progressBar.update(progress)
                    })
                })
        })
    })