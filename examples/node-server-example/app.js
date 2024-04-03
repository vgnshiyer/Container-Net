var express = require('express');
const pino = require('pino');

var app = express();

const logger = pino({ level: 'info' });

logger.info('hello world');
logger.info('This is a nodejs app for testing');

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, () => {
  logger.info('Server running at http://localhost:3000');
});