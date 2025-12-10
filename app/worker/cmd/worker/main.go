package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {
	queueURL := os.Getenv("QUEUE_URL")
	if queueURL == "" {
		log.Fatal("QUEUE_URL not set")
	}
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil { log.Fatal(err) }
	sqsClient := sqs.NewFromConfig(cfg)

	log.Println("Worker started. Polling SQS...")
	for {
		out, err := sqsClient.ReceiveMessage(context.Background(), &sqs.ReceiveMessageInput{
			QueueUrl:            &queueURL,
			MaxNumberOfMessages: 5,
			WaitTimeSeconds:     10,
		})
		if err != nil {
			log.Println("Receive error:", err)
			continue
		}
		for _, m := range out.Messages {
			fmt.Println("Processing message:", *m.Body)
			// TODO: parse body, fetch from S3, create thumbnail, update Aurora
			_, _ = sqsClient.DeleteMessage(context.Background(), &sqs.DeleteMessageInput{
				QueueUrl:      &queueURL,
				ReceiptHandle: m.ReceiptHandle,
			})
		}
		time.Sleep(1 * time.Second)
	}
}
