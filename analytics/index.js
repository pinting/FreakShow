const aws = require("aws-sdk");
const uuid = require("uuid");
const dotenv = require("dotenv");

dotenv.config();

const dynamoDB = new aws.DynamoDB.DocumentClient();

module.exports.create = (event, context, callback) => {
    const timestamp = new Date().getTime();
    const data = JSON.parse(event.body);

    if (typeof data.userId !== "string" || typeof data.scenePath !== "string") {
        callback(null, {
            statusCode: 400,
            headers: { "Content-Type": "text/plain" },
            body: "",
        });
    }
    else {
        const params = {
            TableName: process.env.DYNAMODB_TABLE,
            Item: {
                id: uuid.v1(),
                userId: data.userId,
                scenePath: data.scenePath,
                createdAt: timestamp
            },
        };
        
        dynamoDB.put(params, error => {
            if (error) {
                console.error(error);

                callback(null, {
                    statusCode: error.statusCode || 501,
                    headers: { "Content-Type": "text/plain" },
                    body: "",
                });
            }
            else {
                callback(null, {
                    statusCode: 200,
                    headers: { "Content-Type": "text/plain" },
                    body: JSON.stringify(params.Item),
                });
            }
        });
    }
};

module.exports.stats = (event, context, callback) => {
    const params = {
        TableName: process.env.DYNAMODB_TABLE,
    };

    dynamoDB.scan(params, (error, result) => {
        if (error) {
            console.error(error);

            callback(null, {
                statusCode: error.statusCode || 501,
                headers: { "Content-Type": "text/plain" },
                body: ""
            });
        }
        else {
            callback(null, {
                statusCode: 200,
                headers: { "Content-Type": "text/plain" },
                body: JSON.stringify(result.Items)
            });
        }
    });
};