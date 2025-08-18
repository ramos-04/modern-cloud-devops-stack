const express = require('express');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');
const shortid = require('shortid');
const fs = require('fs'); // Import the file system module

const app = express();
const port = 80; // Application listens on port 80

let AWS_REGION;
let DYNAMODB_TABLE_NAME;

const configPath = '/mnt/secrets-store/app-config.json';

try {
  // Read the JSON file from the specified path
  const configFile = fs.readFileSync(configPath, 'utf8');
  const config = JSON.parse(configFile);

  // Assign values from the parsed JSON object
  AWS_REGION = config.AWS_REGION;
  DYNAMODB_TABLE_NAME = config.DYNAMODB_TABLE_NAME;

  // Basic validation to ensure configurations were read
  if (!DYNAMODB_TABLE_NAME || !AWS_REGION) {
    console.error('Error: DYNAMODB_TABLE_NAME or AWS_REGION not found in the config.json file.');
    process.exit(1);
  }
} catch (error) {
  // Handle file reading or parsing errors
  console.error(`Error reading or parsing configuration file at ${configPath}:`, error);
  process.exit(1);
}

/*
// AWS Region and DynamoDB Table Name from environment variables
const AWS_REGION = process.env.AWS_REGION || 'us-east-1';
const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;

if (!DYNAMODB_TABLE_NAME) {
  console.error('Error: DYNAMODB_TABLE_NAME environment variable is not set.');
  process.exit(1);
}
*/

// Initialize DynamoDB client
const client = new DynamoDBClient({ region: AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

app.use(express.json()); // For parsing application/json

// Root endpoint for testing
app.get('/', (req, res) => {
  res.send('URL Shortener is running! Use /shorten to create short URLs and /<short_code> to redirect.');
});

// Endpoint to shorten a URL
app.post('/shorten', async (req, res) => {
  const { originalUrl } = req.body;

  if (!originalUrl) {
    return res.status(400).json({ error: 'originalUrl is required' });
  }

  const shortCode = shortid.generate();

  const params = {
    TableName: DYNAMODB_TABLE_NAME,
    Item: {
      short_code: shortCode,
      original_url: originalUrl,
      created_at: new Date().toISOString(),
    },
  };

  try {
    await docClient.send(new PutCommand(params));
    // Construct the full short URL using the ALB DNS name (or other base URL)
    // In a real app, you'd pass the base URL from env or config
    const baseUrl = req.protocol + '://' + req.get('host'); 
    res.status(201).json({ shortUrl: `${baseUrl}/${shortCode}` });
  } catch (error) {
    console.error('Error shortening URL:', error);
    res.status(500).json({ error: 'Could not shorten URL' });
  }
});

// Endpoint to redirect from short URL to original URL
app.get('/:shortCode', async (req, res) => {
  const { shortCode } = req.params;

  const params = {
    TableName: DYNAMODB_TABLE_NAME,
    Key: {
      short_code: shortCode,
    },
  };

  try {
    const data = await docClient.send(new GetCommand(params));
    if (data.Item && data.Item.original_url) {
      res.redirect(data.Item.original_url);
    } else {
      res.status(404).send('Short URL not found');
    }
  } catch (error) {
    console.error('Error retrieving original URL:', error);
    res.status(500).json({ error: 'Could not retrieve URL' });
  }
});

app.listen(port, () => {
  console.log(`URL Shortener app listening on port ${port}`);
  console.log(`DynamoDB Table Name: ${DYNAMODB_TABLE_NAME}`);
  console.log(`AWS Region: ${AWS_REGION}`);
});
