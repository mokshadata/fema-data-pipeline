const fs = require('fs')

const R = require('rambda')
const MultiStream = require('multistream')

const GJV = require('geojson-validation')
const oboe = require('oboe')
const JSONStream = require('JSONStream')

// Set up streams.
// Input read stream from file of paths to unique geojson files.
const readStream = fs.createReadStream('./artifacts/01-unique-files.txt')
readStream.setEncoding('UTF8')

// Output write stream for resulting merged data file.
const outputStream = fs.createWriteStream('./outputs/merged-data.geojson')

// Set up a JSON stringify stream to process stream out to file and
// stringify it as JSON before writing.
const transformStream = JSONStream.stringify('[',',',']')
transformStream.pipe(outputStream)


const transformPathToReadStream = (filepath, index) => (() => {
  console.log(`Parsing file ${index} at ${filepath}`)
  return fs.createReadStream(filepath)
})

readStream.on('data', (data) => {

  const geojsonReadStreams = R.pipe(
    R.split('\n'),
    R.filter((line) => (line.length > 0)),
    R.map(transformPathToReadStream),
  )(data)

  const geojsonStream = new MultiStream(geojsonReadStreams)
  geojsonStream.on('end', () => {
    transformStream.end()
  })

  const collectedShapesIDs = []
  const corruptShapeIds = []

  // TODO pull out into functions and streams
  oboe(geojsonStream)
    .on('node', {
      'features.*': function(feature) {
        if (
          R.pipe(
            R.concat(corruptShapeIds),
            R.includes(feature.id),
            R.not,
          )(collectedShapesIDs)
        ) {

          GJV.valid(feature.geometry, (isValid, err) => {
            if (!isValid) {
              corruptShapeIds.push(feature.id)
              console.warn(err)
              return
            }
            transformStream.write(feature)
            collectedShapesIDs.push(feature.id)
            console.log(`${collectedShapesIDs.length} shapes!`)
          })

        }
        return oboe.drop
      }
    })

})
