'use strict';

const fs = require('fs');
const path = require('path');

const indexPath = path.join(__dirname, 'public', 'index.html');
const contents = fs.readFileSync(indexPath, 'utf8');

const required = [
  '<!DOCTYPE html>',
  '<h1',
  'Git from Scratch',
  '/healthz'
];

const missing = required.filter((item) => !contents.includes(item));
if (missing.length > 0) {
  console.error(`Validation failed. Missing: ${missing.join(', ')}`);
  process.exit(1);
}

console.log('Static application validation passed.');
